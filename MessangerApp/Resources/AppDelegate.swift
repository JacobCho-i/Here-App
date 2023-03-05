//
//  AppDelegate.swift
//  MessangerApp
//
//  Created by choi jun hyung on 8/24/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) ->Bool{
        
        NotificationHelper.sharedManager.requestUserPermission()
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        //GIDSignIn.sharedInstance?.clientID = FirebaseApp.app()?.options.clientID
        //GIDSignIn.sharedInstance?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(becomeIdle), name: UIApplication.didEnterBackgroundNotification, object: nil)
        return true
    }
    @objc func becomeIdle() {
        DatabaseManager.shared.becomeIdle()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        return
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("yo")
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        
        return GIDSignIn.sharedInstance.handle(url)
              
    }
        
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                //NotificationCenter.default.post(name: .loginError, object: nil, userInfo: ["error": error])
            }
            return
        }
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
        
        guard let email = user.profile?.email,
              let firstName = user.profile?.givenName,
              let LastName = user.profile?.familyName else {
                return
        }
        
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(LastName)", forKey: "name")
        
        DatabaseManager.shared.userExists(with: email, completion: {exists in
            if !exists {
                // insert to database
                let authentication = user.authentication
                guard let token = authentication.idToken else {
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: token,
                                                               accessToken: authentication.accessToken)
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                    guard authResult != nil, error == nil else {
                        print("failed to log in with google credential")
                        return
                    }
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: LastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        switch success {
                        case .success(let bool):
                            if bool {
                                UserDefaults.standard.setValue(false, forKey: "setPassword")
                                guard let profile = user.profile else {
                                    return
                                }
                                if profile.hasImage {
                                    guard let url = profile.imageURL(withDimension: 200) else {
                                        return
                                    }
                                    
                                    URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                                    guard let data = data else {
                                        return
                                    }
                                    print("before")
                                    let filename = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                        switch result{
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                            print("logged in ")
                                            NotificationCenter.default.post(name: .listenConv, object: nil)
                                            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                                            print(downloadUrl)
                                        case .failure(let error) :
                                            let profilePic = UIImageView()
                                            profilePic.image = UIImage(systemName: "person.circle")
                                            profilePic.tintColor = .orange
                                            print("Storage manager error: \(error)")
                                            NotificationCenter.default.post(name: .listenConv, object: nil)
                                            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                                        }
                                    })
                                        print("logged in ")
                                        NotificationCenter.default.post(name: .listenConv, object: nil)
                                        NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                                    }).resume()
                                }
                            }
                        case .failure(let error):
                            NotificationCenter.default.post(name: .loginError, object: nil, userInfo: ["error": error])
                        }
                        
                    })
                    
                })
                
            } else {
                let authentication = user.authentication
                guard let token = authentication.idToken else {
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: token,
                                                               accessToken: authentication.accessToken)
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                    guard authResult != nil, error == nil else {
                        print("failed to log in with google credential")
                        return
                    }
                    NotificationCenter.default.post(name: .listenConv, object: nil)
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                    print("Successfully signed in with Google cred.")
                    
                })
            }
        })
        
    }
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
            print("Google user was disconnected")
            // Perform any operations when the user disconnects from app here.
            // ...
        }
    
}




func registerForPushNotifications() {
  //1
  UNUserNotificationCenter.current()
    //2
    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      //3
      print("Permission granted: \(granted)")
    }
}
