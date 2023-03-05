//
//  DatabaseManager.swift
//  Messanger
//
//  Created by choi jun hyung on 7/28/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import MessageKit
import CoreLocation


/// Manager object to read and write data to real time firebase database
final class DatabaseManager {
    
    ///share instance of class
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private init() {}
//    typealias CompletionHandler = <#type expression#>
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: "@", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    
    private var index = 0
    private var id = 0
    
    private var Firstname = ""
    private var Lastname = ""
    public var namelist:[String] = []
}

extension DatabaseManager {
    
    ///returns dictionary node at child path
    public func getdataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

extension DatabaseManager{
    
    /// checks if user exists for given email
    /// Parameters
    /// - 'email':            Target email to be checked
    /// - 'completion':   Async closure to retuen with result
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String:Any] != nil else {
                completion(false)
                return
            }
            
            if snapshot.hasChild("deleted") {
                completion(false)
            } else {
                completion(true)
                
            }
        })
        
    }
    
    public func checkOnlineStatus() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        Database.database().reference().observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(safeEmail) {
                let presenceRef = Database.database().reference(withPath: "\(safeEmail)/online_status")
                let lastOnline = Date()
                presenceRef.onDisconnectSetValue("offline")
                let lastOnlineRef = Database.database().reference(withPath: "\(safeEmail)/last_online")
                let lastOnlineString = ChatViewController.dateFormatter.string(from: lastOnline)
                lastOnlineRef.onDisconnectSetValue(lastOnlineString)
            }
        })
    }
    
    public func isOnline() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        Database.database().reference().observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(safeEmail) {
                self.database.child("\(safeEmail)/online_status").setValue("online")
            }})
    }
    
    public func checkOnline(otherUserEmail: String, completion: @escaping (String) -> Void) {
        database.child("\(otherUserEmail)/online_status").observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? String {
                if value == "online" {
                    completion(value)
                }
                if value == "Idle" {
                    completion(value)
                }
                if value == "offline" {
                    self.database.child("\(otherUserEmail)/last_online").observeSingleEvent(of: .value) { snapshot in
                        if let newVal = snapshot.value as? String {
                            completion(newVal)
                        }
                    }
                }
            }
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Result<Bool, Error>) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "status": " ",
            "blocked_user": []
        
        ], withCompletionBlock: { [weak self] error, _ in
            print(1111111)
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                completion(.failure(error!))
                return
            }
                DatabaseManager.shared.setupUserID(completion: {(success) in
                    switch success {
                    case .success(_):
                        print("passed")
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                })
                strongSelf.database.observeSingleEvent(of: .value) { snapshot in
                    if snapshot.hasChild("users") {
                        strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                             if var usersCollection = snapshot.value as? [[String: Any]] {
                                let newElement = [
                                    "name": user.firstName + " " + user.lastName,
                                    "email": user.safeEmail
                                ]
                                usersCollection.append(newElement)
                                let count = usersCollection.count
                                strongSelf.database.child("users").child("\(count-1)").setValue(newElement, withCompletionBlock: {error, _ in
                                    guard error == nil else {
                                        completion(.failure(error!))
                                        return
                                    }
                                })
                                completion(.success(true))
                             }
                             else {
                                completion(.failure(DatabaseError.failedToFetch))
                             }
                         })
                    } else {
                        completion(.failure(DatabaseError.failedToFetch))
                    }
                }
                
            
            
        })
    }
    
    /// Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    private func setupUserID(completion: @escaping (Result<Bool, Error>) -> Void) {
        print("this called")
        self.setUserID(completion: { [weak self] result in
            switch result {
            
            case .success(let num):
                print("that called")
                //guard let num = num as? Int else {
                //    return
                //}
//                guard let newNum = num as? Int else {
//                    return
//                }
                guard let newNum = num as? Int else {
                    return
                }
                self?.addUserID(id: newNum, completion: {(success) in
                    switch success {
                    case .success(_):
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                print("Failed to read data with error: \(error)")
                completion(.failure(error))
            }
        })
    }
    
    
    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Failed to fetch data due to the problem connecting to the server"
            }
        }
    }
    
    public func grabUsername(safeEmail: String, completion:@escaping (String) -> Void) {
        database.child(safeEmail).child("first_name").observeSingleEvent(of: .value, with: { (snapshot) in
            if let firstName = snapshot.value as? String {
                //self.Firstname = firstName
                self.namelist.append(firstName)
                completion(firstName)
                //print(self.Firstname)
                return
            }
        })
//        let nc = NotificationCenter.default
//        nc.post(name: Notification.Name("notif"), object: nil)
    }
    
    public func grabFullname(safeEmail: String, completion:@escaping (String) -> Void) {
        var fullName = ""
        database.child(safeEmail).child("first_name").observeSingleEvent(of: .value, with: { (snapshot) in
            if let firstName = snapshot.value as? String {
                //self.Firstname = firstName
                fullName += firstName
                self.database.child(safeEmail).child("last_name").observeSingleEvent(of: .value, with: { (snapsho) in
                                if let lastName = snapsho.value as? String {
                                    fullName += " \(lastName)"
                                    completion(fullName)
                                        }})
                //print(self.Firstname)
                return
            }
        })
//        let nc = NotificationCenter.default
//        nc.post(name: Notification.Name("notif"), object: nil)
    }
    
    //
    public func findUser(index: Int, completion:@escaping (String) -> Void) {
        database.child("users").child("\(index)").child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                if let name = snapshot.value as? String {
                    completion(name)
                    return
                }
            })
    //        let nc = NotificationCenter.default
    //        nc.post(name: Notification.Name("notif"), object: nil)
        }
    
    public func getEmail(index: Int, completion:@escaping (String) -> Void) {
        database.child("users").child("\(index)").child("email").observeSingleEvent(of: .value, with: { (snapshot) in
                if let email = snapshot.value as? String {
                    completion(email)
                    return
                }
            })
    //        let nc = NotificationCenter.default
    //        nc.post(name: Notification.Name("notif"), object: nil)
        }
    
    public func grabLast(safeEmail: String, completion:@escaping (String) -> Void) {
            database.child(safeEmail).child("last_name").observeSingleEvent(of: .value, with: { (snapshot) in
                if let lastName = snapshot.value as? String {
                    //self.Lastname = lastName
                    //print(self.Lastname)
                    completion(lastName)
                    return
                }
            })
    //        let nc = NotificationCenter.default
    //        nc.post(name: Notification.Name("notif"), object: nil)
        }
    
    public func updateName() -> String {
        let name = "\(self.Firstname)  \(self.Lastname)"
        return name
    }
    
    //here
    public func changeUsername(safeEmail: String, firstName: String, lastName: String, id: Int, completion: @escaping (Result<Any?, Error>) -> Void) {
        var count = 0
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        if email.hasPrefix("demo@here.net") {
            database.child(safeEmail).child("first_name").setValue(firstName, withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                count += 1
                if count == 2 {
                    completion(.success(nil))
                }
            })
            database.child(safeEmail).child("last_name").setValue(lastName, withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                count += 1
                if count == 2 {
                    completion(.success(nil))
                }
            })
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
        } else {
            print("nah")
        database.child(safeEmail).child("first_name").setValue(firstName, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            count += 1
            if count == 3 {
                completion(.success(nil))
            }
        })
        database.child(safeEmail).child("last_name").setValue(lastName, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            count += 1
            if count == 3 {
                completion(.success(nil))
            }
        })
        let fullName = "\(firstName) \(lastName)"
        database.child("users").child("\(id)").child("name").setValue(fullName, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            count += 1
            if count == 3 {
                completion(.success(nil))
            }
        })
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
        }
    }
    
    public func userRead(indexpath: Int) {
        //let model = conversations[indexPath.row]
        //database.child(safeEmail).child("conversations")
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("conversations").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("\(indexpath)") {
                self.database.child(safeEmail).child("conversations").child("\(indexpath)").child("latest_message").child("is_read").setValue(true)
            } else {
                return
            }
            
        }
         
            
        
    }
    
    public func addIndex(indexPath: Int) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        database.child(safeEmail).child("recent_conversation").setValue(indexPath)
    }
    
    public func getRecentConversation(email:String, completion: @escaping (Int) -> Void) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safeEmail).child("recent_conversation").observeSingleEvent(of: .value, with: { (snapshot) in
            if let id = snapshot.value as? Int {
                completion(id)
            }
        })
    }
    //mark
    public func setUserID(completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let num = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                print("failed to perceive")
                return
            }
            let userid = num.count
            completion(.success(userid))
//            return
        })
    }
    public func getDate(id: String, index: Int, completion: @escaping (String) -> Void) {
        database.observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("\(id)") {
                self.database.child("\(id)").child("messages").observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [[String:Any]] else {
                        return
                    }
                    let data = value[0]
                    guard let date = data["date"] as? String else {
                        return
                    }
                    completion(date)
                }
            } else {
            }
        }
        
    }
//
    public func addUserID(id: Int, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("userID").setValue(id, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            self.database.child(safeEmail).child("StringID").setValue("\(id)") { error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(true))
            }
        })
    }
    
    public func setPasscord(otherEmail: String, passcord: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("conversations").observeSingleEvent(of: .value) { (snapshot) in
            if let conversations = snapshot.value as? [[String: Any]] {
            var convIndex = 0
            for conversation in conversations {
                if let id = conversation["other_user_email"] as? String,
                    id == otherEmail {
                    break
                }
                convIndex += 1
            }
            if (convIndex == conversations.count) {
                return
            }
                self.database.child(safeEmail).child("conversations").child("\(convIndex)").child("passcord").setValue(passcord) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    completion(.success(true))
                }
            }
        }
    }
    
    public func checkPasscord(index: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //let safeOtherEmail = DatabaseManager.safeEmail(emailAddress: otherEmail)
        database.child(safeEmail).child("conversations").child(index).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("passcord") {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func getPasscord(index: String, completion: @escaping (String) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("conversations").child(index).child("passcord").observeSingleEvent(of: .value) { (snapshot) in
            if let passcord = snapshot.value as? String {
                completion(passcord)
            }
            
        }
    }
    
    public func checkUsers(id: Int, completion: @escaping(Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let SE = DatabaseManager.safeEmail(emailAddress: email)
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            if let collection = snapshot.value as? [[String: String]]{
                if collection.count-1 < id {
                    let data = [
                        "name": UserDefaults.standard.value(forKey: "name") as? String ?? " ",
                        "email": UserDefaults.standard.value(forKey: "email") as? String ?? " "
                    ]
                    self.database.child("user").child("\(id)").setValue(data)
                    completion(true)
                }
                
            }
        }
    }
    
    public func getUserID(email:String, completion:@escaping (Int) -> Void) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        
        self.database.child(safeEmail).child("userID").observe(.value, with: { (snapshot) in
            
            if let id = snapshot.value as? Int {
                //self.id = id
                completion(id)
                return
            }
        })
    }
    
    public func getMyID(completion:@escaping (Int) -> Void) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        
        self.database.child(safeEmail).child("userID").observe(.value, with: { (snapshot) in
            
            if let id = snapshot.value as? Int {
                completion(id)
                return
            }
        })
    }
    
    
    public func getDeletedUsers(completion:@escaping ([Int]) -> Void) {
        self.database.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.hasChild("deleted") {
                let empty:[Int] = []
                completion(empty)
                return
            }
        }
        self.database.child("deleted").observeSingleEvent(of: .value, with: { (snapshot) in
            if let id = snapshot.value as? [Int] {
                completion(id)
                return
            }
        })
    }
    
    public func reportUser(email: String, reason: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        getIndexNum { (indexNum) in
            guard let selfEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: selfEmail)
            let newElement = [
                "sender_email": safeEmail,
                "email": email,
                "reason": reason
            ]
            self.database.child("report").child("\(indexNum)").setValue(newElement) { error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
            }
            
            completion(.success(true))
        }
        
        
    }
    
    public func getIndexNum(completion:@escaping (Int) -> Void) {
        self.database.child("report").observeSingleEvent(of: .value, with: { (snapshot) in
            if let id = snapshot.value as? [[String: String]] {
                completion(id.count)
                return
            }
        })
    }
    
    public func getVerified(completion:@escaping ([Int]) -> Void) {
        self.database.child("verified").observeSingleEvent(of: .value, with: { (snapshot) in
            if let id = snapshot.value as? [Int] {
                completion(id)
                return
            }
        })
    }
    
    public func deleteUserID(int: Int, completion: @escaping (Result<Any?, Error>) -> Void) {
        var count = 0
        database.child("users").child("\(int)").child("name").setValue(" ", withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            count += 1
            if count == 3 {
                completion(.success(nil))
            }
        })
        database.child("users").child("\(int)").child("email").setValue(" ", withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            count += 1
            if count == 3 {
                completion(.success(nil))
            }
        })
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let goodemail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(goodemail).child("deleted").setValue(true) { error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            count += 1
            if count == 3 {
                completion(.success(nil))
            }
        }
        
        
    }
    public func deleteAppend(int: Int, email: String, completion: @escaping (Result<Any?, Error>) -> Void){
        var DeletedUserCollections = [Int]()
        getDeletedUsers { (users) in
            DeletedUserCollections = users
            DeletedUserCollections.append(int)
            let count = DeletedUserCollections.count - 1
            
            self.database.child("deleted").child("\(count)").setValue(int, withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(nil))
            })
        }
        
        
    }
    
    public func getRequested(completion:@escaping ([String]) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safeEmail).child("request").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [String] {
                completion(request)
                return
            }
        })
    }
    
    public func getRequestOther(email: String, completion:@escaping ([String]) -> Void) {
        self.database.child(email).child("request").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [String] {
                completion(request)
                return
            }
        })
    }
    
    public func getBlock(completion:@escaping ([String]) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safeEmail).child("block").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [String] {
                completion(request)
                return
            }
        })
    }
    
    public func checkBlock(completion:@escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safeEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("block_id") {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    public func getBlockId(completion:@escaping ([Int]) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safeEmail).child("block_id").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [Int] {
                completion(request)
                return
            }
        })
    }
    
    public func addBlock(otherEmail: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        var count = 0
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("block") {
                self.getBlock { (users) in
                    var newUsers = users
                    newUsers.append(otherEmail)
                    self.database.child(safeEmail).child("block").setValue(newUsers, withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(.failure(error!))
                            return
                        }
                        count += 1
                        if count == 2 {
                            completion(.success(true))
                        }
                    })
                }
            } else {
                let block:[String] = ["\(otherEmail)"]
                self.database.child(safeEmail).child("block").setValue(block, withCompletionBlock: {error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                })
            }
        }
        guard !otherEmail.hasPrefix("demo-here-net") else {
            completion(.success(true))
            return
        }
        getUserID(email: otherEmail) { (userid) in
            self.database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild("block_id") {
                    self.getBlockId { (users) in
                        var newUsers = users
                        newUsers.append(userid)
                        self.database.child(safeEmail).child("block_id").setValue(newUsers, withCompletionBlock: {error, _ in
                            guard error == nil else {
                                completion(.failure(error!))
                                return
                            }
                            count += 1
                            if count == 2 {
                                completion(.success(true))
                            }
                        })
                    }
                } else {
                    let block:[Int] = [userid]
                    self.database.child(safeEmail).child("block_id").setValue(block, withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(.failure(error!))
                            return
                        }
                        count += 1
                        if count == 2 {
                            completion(.success(true))
                        }
                    })
                }
            }
        }
//        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
//            if snapshot.hasChild("accept") {
//                self.database.child(safeEmail).child("accept").observeSingleEvent(of: .value) { (user) in
//                    if let newUser = user.value as? [String] {
//                        var newUsers:[String] = newUser
//                        if(newUsers.contains(otherEmail)) {
//                            if let newIndex = newUsers.index(of: otherEmail) {
//                                newUsers.remove(at: newIndex)
//                            }
//                            if newUsers.count == 0 {
//                                self.database.child(safeEmail).child("accept").removeValue()
//                            } else {
//                                self.database.child(safeEmail).child("accept").setValue(newUsers)
//                            }
//                        }
//
//                    }
//
//                }
//            }
//        }
        
    }
    
    public func removeBlock(otherEmail: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        var count = 0
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        getBlock { (users) in
            
            var newUsers = users
            if let newIndex = users.firstIndex(of: otherEmail) {
                newUsers.remove(at: newIndex)
            }
            if newUsers.count == 0 {
                self.database.child(safeEmail).child("block").removeValue { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
            } else {
                self.database.child(safeEmail).child("block").setValue(newUsers) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
            }
        }
        guard !otherEmail.hasPrefix("demo-here-net") else {
            completion(.success(true))
            return
        }
        getUserID(email: otherEmail) { (userid) in
            self.getBlockId { (users) in
                var newUsers = users
                if let newIndex = users.firstIndex(of: userid) {
                    newUsers.remove(at: newIndex)
                }
                if newUsers.count == 0 {
                    self.database.child(safeEmail).child("block_id").removeValue { error, _ in
                        guard error == nil else {
                            completion(.failure(error!))
                            return
                        }
                        count += 1
                        if count == 2 {
                            completion(.success(true))
                        }
                    }
                    
                } else {
                    self.database.child(safeEmail).child("block_id").setValue(newUsers) { error, _ in
                        guard error == nil else {
                            completion(.failure(error!))
                            return
                        }
                        count += 1
                        if count == 2 {
                            completion(.success(true))
                        }
                    }
                    
                }
            }
        }
        
    }
    
    public func getReceive(completion:@escaping ([String]) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safeEmail).child("receive").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [String] {
                completion(request)
                return
            }
        })
    }
    
    public func getReceiveOther(email: String, completion:@escaping ([String]) -> Void) {
        self.database.child(email).child("receive").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [String] {
                completion(request)
                return
            }
        })
    }
    
    public func checkRequested(otherEmail: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //let safeOtherEmail = DatabaseManager.safeEmail(emailAddress: otherEmail)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("request") {
                self.getRequested { (users) in
                    if (users.contains(otherEmail)) {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    public func checkReceive(otherEmail: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //let safeOtherEmail = DatabaseManager.safeEmail(emailAddress: otherEmail)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("receive") {
                self.getReceive(completion: { (users) in
                    if (users.contains(otherEmail)) {
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            } else {
                completion(false)
            }
        }
    }
    
    public func checkAnyReceive(completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("receive") {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    public func deleteRequest(otherEmail: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        var count = 0
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        getRequested { (users) in
            var newUsers = users
            if let newIndex = users.firstIndex(of: otherEmail) {
                    newUsers.remove(at: newIndex)
            }
            if newUsers.count == 0 {
                self.database.child(safeEmail).child("request").removeValue { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
            } else {
                self.database.child(safeEmail).child("request").setValue(newUsers) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
                
            }
        }
        addOtherRequest(OtherEmail: otherEmail) { (receive) in
            var newUsers = receive
            if let newIndex = receive.firstIndex(of: safeEmail) {
                    newUsers.remove(at: newIndex)
            }
            if newUsers.count == 0 {
                self.database.child(otherEmail).child("receive").removeValue { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
                
            } else {
                self.database.child(otherEmail).child("receive").setValue(newUsers) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
                
            }
        }
    }
    
    
    public func accepted(otherEmail: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        var count = 0
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("receive") {
                self.getReceive { receive_users in
            var pos = 0
            var newval = receive_users
            for ruser in receive_users {
                if otherEmail == ruser {
                    newval.remove(at: pos)
                    break
                }
                pos += 1
            }
            
            self.database.child(safeEmail).child("receive").setValue(newval) { error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                count += 1
                if count == 2{
                    completion(.success(true))
                }
            }
            
        }
    }}
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("request") {
                self.getRequested { request_users in
                    var newVal = request_users
                    newVal.append(otherEmail)
                    self.database.child(safeEmail).child("request").setValue(newVal) { error, _ in
                        guard error == nil else {
                            completion(.failure(error!))
                            return
                        }
                        count += 1
                        if count == 2 {
                            completion(.success(true))
                        }
                    }
                }
            } else {
                let newVal:[String] = [otherEmail]
                self.database.child(safeEmail).child("request").setValue(newVal) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
            }
        }
        
    }
    
    public func getAccepted(email: String, completion:@escaping ([String]) -> Void) {
        self.database.child(email).child("accept").observeSingleEvent(of: .value, with: { (snapshot) in
            if let request = snapshot.value as? [String] {
                completion(request)
                return
            }
        })
        
    }
    
    public func getDemoNum(completion: @escaping (Result<Int,Error>) -> Void){
        database.child("demoNum").observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? Int {
                completion(.success(data))
            } else {
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
        return
    }
    
//    public func incDemoNum(num:Int, completion: @escaping (Bool) -> Void){
//        database.child("demoNum").setValue(num) { error, _ in
//            guard error == nil else {
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//        return
//    }
    
    
    public func deleteReceive(otherEmail: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        getReceive { (users) in
            var newUsers = users
            if let newIndex = users.firstIndex(of: otherEmail) {
                    newUsers.remove(at: newIndex)
                }
            if newUsers.count == 0 {
                self.database.child(safeEmail).child("receive").removeValue { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    completion(.success(true))
                    
                }
            } else {
                self.database.child(safeEmail).child("receive").setValue(newUsers) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    completion(.success(true))
                    
                }
            }
        }
    }
    
    public func addOtherRequest(OtherEmail: String, completion: @escaping ([String]) -> Void) {
    let safeEmail = DatabaseManager.safeEmail(emailAddress: OtherEmail)
    self.database.child(safeEmail).child("receive").observeSingleEvent(of: .value, with: { (snapshot) in
        if let request = snapshot.value as? [String] {
            completion(request)
            return
            }
        })
    }
    
    public func addOtherReceive(OtherEmail: String, completion: @escaping ([String]) -> Void) {
    let safeEmail = DatabaseManager.safeEmail(emailAddress: OtherEmail)
    self.database.child(safeEmail).child("request").observeSingleEvent(of: .value, with: { (snapshot) in
        if let request = snapshot.value as? [String] {
            completion(request)
            return
            }
        })
    }
    
    public func requestUser(otherEmail: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        var count = 0
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let safeOtherEmail = DatabaseManager.safeEmail(emailAddress: otherEmail)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("request") {
                self.getRequested { (users) in
                    var newUsers: [String] = users
                    if (!newUsers.contains(safeOtherEmail)) {
                        newUsers.append(safeOtherEmail)
                        self.database.child(safeEmail).child("request").setValue(newUsers) { error, _ in
                            guard error == nil else {
                                completion(.failure(error!))
                                return
                            }
                            count += 1
                            if count == 2 {
                                completion(.success(true))
                            }
                        }
                    }
                }
            } else {
                let user:[String] = ["\(safeOtherEmail)"]
                self.database.child(safeEmail).child("request").setValue(user) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
                
            }
        }
        database.child(safeOtherEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("receive") {
                self.addOtherRequest(OtherEmail: safeOtherEmail, completion: { (users) in
                    var newUsers:[String] = users
                    if (!newUsers.contains(safeEmail)) {
                    newUsers.append(safeEmail)
                        self.database.child(safeOtherEmail).child("receive").setValue(newUsers) { error, _ in
                            guard error == nil else {
                                completion(.failure(error!))
                                return
                            }
                            count += 1
                            if count == 2 {
                                completion(.success(true))
                            }
                        }
                        
                    }
                })
            } else {
                let user:[String] = ["\(safeEmail)"]
                self.database.child(safeOtherEmail).child("receive").setValue(user) { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    count += 1
                    if count == 2 {
                        completion(.success(true))
                    }
                }
            }
        }
        
    }
    
    
    public func verifiedAppend(int: Int) {
        var VerifiedUserCollections = [Int]()
            getVerified { (users) in
                VerifiedUserCollections = users
                if (!VerifiedUserCollections.contains(int)) {
                    VerifiedUserCollections.append(int)
                    let index = VerifiedUserCollections.count - 1
                    print("index \(int)")
                    self.database.child("verified").child("\(index)").setValue(int) { error, _ in
                        guard error == nil else {
                            return
                        }
                    }
                }
                
                
        }
    }
    public func uploadStatus(status: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("\(safeEmail)").child("status").setValue(status, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(true))
        })
    }
    
    public func getStatus(email: String, completion:@escaping (String) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("\(safeEmail)").child("status").observeSingleEvent(of: .value) { (snapshot) in
            if let status = snapshot.value as? String {
                completion(status)
            }
        }
    }
    
    public func checkDelete(email: String, completion: @escaping (Bool) -> Void) {

        database.child(email).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("deleted") {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func getIndex() -> Int{
        return self.index
    }
    
    public func getId() -> Int{
        return self.id
    }
    
    
//    public func getUserName(email: String) -> String {
//        let firstName = database.child(email).child("first_name").key as! String
//        let lastName = database.child(email).child("last_name").key as! String
//        let result = "\(firstName) + \(lastName)"
////        let result = UserDefaults.standard.value(forKey: "name")
//        return result
//    }
}

extension DatabaseManager {
    
    public func checkingAuth(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let emai = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let email = DatabaseManager.safeEmail(emailAddress: emai)
        database.child("\(email)/target_email").setValue(otherUserEmail) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            DatabaseManager.shared.checkAuth { oemail in
                if otherUserEmail == oemail {
                    self.createNewConservation(with: otherUserEmail, name: name, firstMessage: firstMessage) { succeed in
                        completion(succeed)
                    }
                }
            }
        }
        
        
    }
    
    public func createNewConservation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            return
        }
        let saftEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(saftEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            var mesType = ""
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
                mesType = "text"
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                mesType = "photo"
                
                }
                break
            case .video(_):
                mesType = "video"
                break
            case .location(_):
                mesType = "location"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation__\(firstMessage.messageId)"
            
            let newConversationData: [String:Any] = [
                "id" : conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message":message,
                    "is_read": false,
                    "type": mesType
                ]
            ]
            
            
            let recipient_newConversationData: [String:Any] = [
                "id" : conversationId,
                "other_user_email": saftEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message":message,
                    "is_read": false,
                    "type": mesType
                ]
            ]
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversatoins = snapshot.value as? [[String: Any]] {
                    conversatoins.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversatoins)
                }
                else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                userNode["conversations"] = conversations
                conversations.append(newConversationData)
                
                ref.child("conversations").setValue(conversations, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                    })
            } else {
                let newdata = [
                    newConversationData
                ]
                
                ref.child("conversations").setValue(newdata, withCompletionBlock: { [weak self] error, _ in
                guard error == nil else {
                    completion(false)
                    return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                })
            }
        })
    }
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping  (Bool) -> Void) {
       // {
            //"id":String,
           // "type":text,photo,video,
          //  "content":String,
        //    "date":Date(),
      //      "sender_email":String,
    //        "isRead":true/false,
  //
//        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        print(collectionMessage)
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        //database.child("\(email)/conversations").removeAllObservers()
        database.child("\(email)/conversations").observe(. value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool,
                    let type = latestMessage["type"] as? String
                    
                    
                    else {
                        return nil
                }
                
                let latestMmessageObject = LatestMessage(date: date,
                                                         text: message,
                                                         isRead: isRead,
                                                         type: type)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMmessageObject)
            })
            
            completion(.success(conversations))
        })
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(. value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string:content),
                        let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }
                else if type == "video" {
                    guard let videoUrl = URL(string:content),
                        let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                else if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponents[0]),
                        let latitude = Double(locationComponents[1]) else {
                        return nil
                    }
                    
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            })
            
            completion(.success(messages))
        })
    }
    
    public func becomeIdle() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let sEmail = DatabaseManager.safeEmail(emailAddress: email)
        Database.database().reference().observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(sEmail) {
                self.database.child(sEmail).child("online_status").setValue("Idle")
            }})
    }
    
    public func getConvID(convId: String, completion: @escaping (Int) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).child("conversations").observeSingleEvent(of: .value) { snapshot in
            if let conversations = snapshot.value as? [[String:Any]] {
                var position = 0
                for conv in conversations {
                    guard let con = conv["id"] as? String else {
                        return
                    }
                    if convId == con {
                        break
                    }
                    position += 1
                }
                completion(position)
            }
        }
    }
    
    public func checkAuth(completion: @escaping (String) -> Void) {
        guard let emai = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let email = DatabaseManager.safeEmail(emailAddress: emai)
        database.child(email).child("target_email").observeSingleEvent(of: .value) { snapshot in
            if let val = snapshot.value as? String {
                completion(val)
            }
        }
    }
    
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        guard !(email == "demo-mode") else {
            return
        }
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(.success(false))
            return
        }
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String:Any]] else {
                completion(.success(false))
                return
                
            }
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            var mesType = ""
            switch newMessage.kind {
                
            case .text(let messageText):
                message = messageText
                mesType = "text"
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                    mesType = "photo"
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                    mesType = "video"
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                mesType = "location"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(.success(false))
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                strongSelf.database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String:Any]]()
                    let updatedValue: [String:Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message,
                        "type": mesType
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String:Any]] {
                        // new conversation entry
                        var targetConversation: [String:Any]?
                        var position = 0
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation  {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String:Any] = [
                                "id" : conversation,
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                        
                        }
                    else {
                        let newConversationData: [String:Any] = [
                            "id" : conversation,
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                strongSelf.database.child("\(currentUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(.failure(error!))
                            return
                        }
                        
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String:Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message,
                                "type": mesType
                            ]
                            var databaseEntryConversations = [[String:Any]]()
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }
                            
                            if var otherUserConversations = snapshot.value as? [[String:Any]] {
                                var targetConversation: [String:Any]?
                                var position = 0

                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation  {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    
                                    strongSelf.database.child("\(otherUserEmail)").child("conversations").child("\(position)").child("latest_message").setValue(updatedValue) { error, _ in
                                        if error != nil {
                                            print("error here")
                                            completion(.failure(error!))
                                        }
                                        print(error.debugDescription)
                                    }
                                }
                                else {
                                    let newConversationData: [String:Any] = [
                                        "id" : conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                    strongSelf.database.child("\(currentUserEmail)/target_email").setValue(otherUserEmail) { error, _ in
                                        guard error == nil else {
                                            completion(.failure(error!))
                                            return
                                        }
                                        DatabaseManager.shared.checkAuth { oemail in
                                            if otherUserEmail == oemail {
                                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                                guard error == nil else {
                                                    print("error hm here")
                                                    completion(.failure(error!))
                                                    return
                                                }
                                                completion(.success(true))
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                let newConversationData: [String:Any] = [
                                    "id" : conversation,
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                                strongSelf.database.child("\(currentUserEmail)/target_email").setValue(otherUserEmail) { error, _ in
                                    guard error == nil else {
                                        completion(.failure(error!))
                                        return
                                    }
                                    DatabaseManager.shared.checkAuth { oemail in
                                        if otherUserEmail == oemail {
                                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                                guard error == nil else {
                                                    print("here everybody drop it")
                                                    completion(.failure(error!))
                                                    return
                                                }
                                                completion(.success(true))
                                            })
                                        }
                                    }
                                }
                            }
                        })
                    })
                })
            }
        })
    }
    public func deleteConversation(conversationId: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Deleting conversation with id: \(conversationId)")
        
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
        
            if var conversations = snapshot.value as? [[String: Any]] {
                var positinToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                        id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positinToRemove += 1
                }
                
                conversations.remove(at: positinToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    print("deleted conversation")
                    completion(.success(true))
                })
            }
        }
    }
    
    public func blockConversation(otherEmail: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
        
            if var conversations = snapshot.value as? [[String: Any]] {
                var positinToRemove = 0
                for conversation in conversations {
                    if let id = conversation["other_user_email"] as? String,
                        id == otherEmail {
                        print("found conversation to delete")
                        break
                    }
                    positinToRemove += 1
                }
                if (positinToRemove == conversations.count) {
                    return
                }
                conversations.remove(at: positinToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to write new conversation array")
                        return
                    }
                    print("deleted conversation")
                    completion(true)
                })
            }
        }
    }
        
    public func conversationExist(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        var count = 0
        var ncount = 0
        var incomplete = true
        database.child("\(safeSenderEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String:Any]] else {
                if (incomplete) {
                completion(.failure(DatabaseError.failedToFetch))
                    incomplete = false
                return
                }
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeRecipientEmail == targetSenderEmail
            }) {
                guard let id = conversation["id"] as? String else {
                    ncount += 1
                    if ncount == 2 {
                        if (incomplete) {
                        completion(.failure(DatabaseError.failedToFetch))
                            incomplete = false
                        return
                        }
                    }
                    return
                }
                if (incomplete) {
                completion(.success(id))
                    incomplete = false
                    return
                    
                }
            }
            count += 1
            if count == 2{
                if (incomplete) {
                completion(.failure(DatabaseError.failedToFetch))
                    incomplete = false
                return
                }
            }
            return
        })
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String:Any]] else {
                if (incomplete) {
                completion(.failure(DatabaseError.failedToFetch))
                    incomplete = false
                }
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                guard let id = conversation["id"] as? String else {
                    ncount += 1
                    if ncount == 2 {
                        if (incomplete) {
                        completion(.failure(DatabaseError.failedToFetch))
                            incomplete = false
                            return
                        }
                    }
                    return
                }
                if (incomplete) {
                completion(.success(id))
                    incomplete = false
                    return
                    
                }
            }
            count += 1
            if count == 2{
                if (incomplete) {
                completion(.failure(DatabaseError.failedToFetch))
                    incomplete = false
                return
                }
            }
            
            return
        })
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            print("hm")
            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }
}

    struct ChatAppUser {
        let firstName: String
        let lastName: String
        let emailAddress: String
        
        var safeEmail: String {
            var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }
        
        var profilePictureFileName: String {
            return "\(safeEmail)_profile_picture.png"
        }
    }

