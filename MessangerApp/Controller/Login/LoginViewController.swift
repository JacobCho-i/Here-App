//
//  LoginViewController.swift
//  Messanger
//
//  Created by choi jun hyung on 7/7/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD



final class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        //field.layer.cornerRadius = 12
        //field.layer.borderWidth = 1
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        //field.layer.borderWidth = 1
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        //button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        
        //change logo here
        imageView.image = UIImage(named: "logosFinal")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let facebookLoginButton: FBLoginButton = {
       let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    private func setColor() {
        guard let theme = UserDefaults.standard.value(forKey: "theme") as? String else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
            third = UIColor(named: "whiteThemeBackgroundColor")!
            textcolor = UIColor(named: "whiteThemeText")!
            return
        }
        if (theme == "orange") {
            primary = UIColor(named: "OrangePri")!
            secondary = UIColor(named: "OrangeSec")!
            third = UIColor(named: "OrangeThi")!
            textcolor = UIColor(named: "OrangeTex")!
        } else if (theme == "pink") {
            primary = UIColor(named: "mainThemePrimary")!
            secondary = UIColor(named: "mainThemeSecondary")!
            third = UIColor(named: "mainThemeThird")!
            textcolor = UIColor(named: "mainThemeText")!
        } else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
            third = UIColor(named: "whiteThemeBackgroundColor")!
            textcolor = UIColor(named: "whiteThemeText")!
        }
    }
    
    @objc func showAlert(notification: Notification) {
        guard let error = notification.userInfo!["error"] as? Error else {
            return
        }
        let alert = UIAlertController(title: "Notification", message: "Error while attempting to log in \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func sign() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                return
            }
            guard let user = user else {
                return
            }
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.setValue("pink", forKey: "theme")
        setColor()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        NotificationCenter.default.addObserver(forName: .loginError, object: nil, queue: nil, using: showAlert(notification:))
        emailField.textColor = primary
        
        passwordField.textColor = primary
        scrollView.backgroundColor = third
        let att1 = NSAttributedString(string: "Email Address...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
        emailField.attributedPlaceholder = att1
        self.navigationController?.navigationBar.tintColor = primary
        let att2 = NSAttributedString(string: "Password...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
        passwordField.attributedPlaceholder = att2
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: {[weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        navigationController?.navigationBar.barTintColor = secondary
        googleLoginButton.addTarget(self, action: #selector(sign), for: .touchUpInside)
        //GIDSignIn.sharedInstance.presentingViewController = self
        //GIDSignIn.sharedInstance.addScopes([""], presenting: self, callback: .none)
        
        
        //let loginButton = FBLoginButton()
        //loginButton.center = view.center
        //view.addSubview(loginButton)
        //loginButton.permissions = ["public_profile", "email"]
        title = "Log In"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // add subviews
        
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(googleLoginButton)
        scrollView.addSubview(resetPasswordButton)
        emailField.backgroundColor = .clear
        passwordField.backgroundColor = .clear
        //emailField.layer.borderColor = primary.cgColor
        passwordField.layer.borderColor = primary.cgColor
        loginButton.backgroundColor = primary
        //scrollView.addSubview(facebookLoginButton)
        
        
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        resetPasswordButton.setTitleColor(primary, for: .normal)
        let size = scrollView.width/3
        resetPasswordButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        imageView.frame = CGRect (x: (scrollView.width-size)/2,
                                  y: 20,
                                  width: size,
                                  height: size)
        emailField.frame = CGRect (x: 30,
                                   y: 20,
                                   width: scrollView.width-60,
                                   height: 52)
        passwordField.frame = CGRect (x: 30,
                                   y: emailField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        loginButton.frame = CGRect (x: 30,
                                    y: passwordField.bottom+10,
                                    width: scrollView.width-60,
                                    height: 52)
        
        //facebookLoginButton.frame = CGRect (x: 30,
                                    //y: loginButton.bottom+10,
                                    //width: scrollView.width-60,
        //height: 52)
        
        
        googleLoginButton.frame = CGRect (x: 30,
                                          y: loginButton.bottom+10,
                                          width: scrollView.width-60,
                                          height: 52)
        resetPasswordButton.frame = CGRect (x: 120,
                                            y: googleLoginButton.bottom+10,
                                            width: scrollView.width-240,
                                            height: 52)
        let underline = UIView()
        underline.frame = CGRect(x: view.width/2-(view.width-60)/2, y: emailField.bottom-10, width: view.width-60, height: 3.3)
        underline.layer.cornerRadius = 4
        underline.backgroundColor = primary
        let underline2 = UIView()
        underline2.frame = CGRect(x: view.width/2-(view.width-60)/2, y: passwordField.bottom-10, width: view.width-60, height: 3.3)
        underline2.layer.cornerRadius = 4
        underline2.backgroundColor = primary
        scrollView.addSubview(underline)
        scrollView.addSubview(underline2)
        
    }
    
    @objc private func resetPassword() {
        
        emailField.resignFirstResponder()
        
        guard  let email = emailField.text, !email.isEmpty else {
            let alert = UIAlertController(title: "Notification", message: "Please fill out the email first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            guard let error = error else {
                let alert = UIAlertController(title: "Notification", message: "Please check your email and reset your password there.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            self.handleError(error: error)
        }
    }
    
    func handleError(error: Error) {
        print(error.localizedDescription)
        let errorAuthStatus = AuthErrorCode.init(rawValue: error._code)!
        switch errorAuthStatus {
        case .wrongPassword:
            print("wrong password")
        case .emailAlreadyInUse:
            print("Email is in juse")
        case .invalidEmail:
            print("invalid email")
        case .userDisabled:
            print("user disabled")
        case .tooManyRequests:
            let alert = UIAlertController(title: "Notification", message: "There was error sending verification email: Too many request at once", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        
        default:
            let alert = UIAlertController(title: "Notification", message: "can't perform this action due to error", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    @objc private func loginButtonTapped() {
        
        //emailField.resignFirstResponder()
        //passwordField.resignFirstResponder()
        
        guard let reEmail = emailField.text, let rePassword = passwordField.text else {
            return
        }
        guard !(reEmail == "demo-trial" && rePassword == "demo123") else {
            print("print")
            UserDefaults.standard.setValue("demo-mode", forKey: "name")
            UserDefaults.standard.setValue("demo-mode", forKey: "email")
            //self.navigationController?.dismiss(animated: true, completion: nil)
            print("helloworld")
            Auth.auth().signIn(withEmail: "demo@here.net", password: "demo123") { _, error in
                guard error == nil else {
                    print("helloworld \(error.debugDescription)")
                    return
                }
                let alert = UIAlertController(title: "Notification", message: "Demo mode is a sole purpose of showing what this app does, so using this mode only provides limited features of this app. If you would like to use all of features, please register and create an account.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
                return
                
            }
            return
//            DatabaseManager.shared.getDemoNum { result in
//                switch result {
//                case .success(let id):
//                    DatabaseManager.shared.userExists(with: "demo@here.net-\(id)", completion: { [weak self] exists in
//                        guard let strongSelf = self else {
//                            return
//                        }
//
//                        DispatchQueue.main.async {
//                            strongSelf.spinner.dismiss()
//                        }
//
//                        guard !exists else {
//                            // user already exists
//                            strongSelf.alertUserLoginError()
//                            print("exists")
//                            return
//                        }
//                        let newid = id + 1
//                        DatabaseManager.shared.incDemoNum(num: newid) { success in
//                            guard success == true else {
//                                let alert = UIAlertController(title: "Notification", message: "failed to log in as demo user due to a problem connecting to the server", preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:  nil))
//                                self?.present(alert, animated: true)
//                                return
//                            }
//                        }
//            Auth.auth().createUser(withEmail: "demo@here.net", password: "demo123") { [weak self] authResults, error in
//                guard let sself = self else {
//                    print("break point 1")
//                    return
//                }
//                guard authResults != nil, error == nil else {
//                    print("error creating user errored")
//                return
//              }
//                DispatchQueue.main.async {
//                    sself.spinner.dismiss()
//                }
//
//                    let chatUser = ChatAppUser(firstName: "Demo",
//                                               lastName: "User",
//                                               emailAddress: "demo@here.net-\(id)")
//                            DatabaseManager.shared.insertUser(with: chatUser, completion: {(success) in
//                                if !success {
//                                    let alert = UIAlertController(title: "Notification", message: "failed to log in as demo user due to a problem connecting to the server", preferredStyle: .alert)
//                                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:  nil))
//                                    sself.present(alert, animated: true)
//                                    print("failed log in")
//                                    return
//                                } else {
                                    
//                                }
//                            })
//                }
                        
                    //})
//                case .failure(_):
//                    let alert = UIAlertController(title: "Notification", message: "failed to log in as demo user due to a problem connecting to the server", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:  nil))
//                    self.present(alert, animated: true)
//                    print("failed log in again")
//                    return
//                    }
//                }
            }
        guard  let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            print("bad")
            alertUserLoginError()
            return
        }
        spinner.show(in: view)
        
        //Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                guard let sself = self else {
                    return
                }
                guard let error = error else {
                    return
                }
                print("badbadbad")
                sself.rehandleError(error: error)
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getdataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                            return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Failed to read data with error: \(error)")
                    guard let sself = self else {
                        return
                    }
                    sself.rehandleError(error: error)
                    print("error")
                }
            })
            
            
            UserDefaults.standard.set(email, forKey: "email")
            
            
            print("Logged In User: \(user)")
            
            
        })
    }
    
    func rehandleError(error: Error) {
        
        let alert = UIAlertController(title: "Notification", message: "Cannot Log in: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "Please enter all information and set the password at least 6 character in order to create a new account", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
 
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
    
    
}
