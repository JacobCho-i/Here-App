//
//  RequestTableViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/29/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RequestTableViewController: UITableViewController {
    
    private var emailList:[String] = []
    private var secEmailList:[String] = []
    private var accEmailList:[String] = []
    private var notColored = true
    
    private var numRequest:Int = 0
    private var numReceive:Int = 0
    private var numAccept:Int = 0
    
    private let database = Database.database().reference()
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    override func viewDidLoad() {
        setColor()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .usersLoaded, object: nil)
        reload()
        tableView.register(RequestTableViewCell.self, forCellReuseIdentifier: RequestTableViewCell.identifier)
        self.navigationController?.tabBarItem.badgeColor = primary
        view.backgroundColor = secondary
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        let image = UIImage(systemName: "arrow.clockwise")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(reload))
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        tableView.tintColor = primary
        navigationItem.rightBarButtonItem?.tintColor = primary
        tableView.separatorColor = .clear
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        print(secEmailList)
    }
    
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    @objc func receiveCheck() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        var count = 0
        var newval:[String] = []
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getRequested { users in
            for user in users {
                DatabaseManager.shared.getReceiveOther(email: user) { ausers in
                    if ausers.contains(safeEmail) {
                        newval.append(user)
                    }
                    count += 1
                    if count == users.count {
                        self.emailList = newval
                        self.numRequest = newval.count
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func update() {
        acceptCheck()
        receiveCheck()
    }
    
    @objc func acceptCheck() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        var count = 0
        var index = 0
        var newval:[String] = accEmailList
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("request") {
                DatabaseManager.shared.getRequested { users in
                    var newVal:[String] = users
                    for user in users {
                        DatabaseManager.shared.getRequestOther(email: user) { ausers in
                            print("\(ausers[0]) \(user) \(safeEmail) \(ausers.contains(safeEmail))")
                            if ausers.contains(safeEmail) {
                                if !self.accEmailList.contains(user) {
                                    newval.append(user)
                                }
                                if self.emailList.contains(user) {
                                    newVal.remove(at: index)
                                    index -= 1
                                }
                            }
                            index += 1
                            count += 1
                            print(users.count)
                            if count == users.count {
                                print("set")
                                self.accEmailList = newval
                                self.numAccept = newval.count
                                self.emailList = newVal
                                self.numRequest = newVal.count
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func reload() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        var count = 0
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("request") {
                self.database.child(safeEmail).child("request").observeSingleEvent(of: .value) { (user) in
                    if let users = user.value as? [String] {
                        self.numRequest = users.count
                        self.emailList = users
                        count += 1
                        if count == 3 {
                            NotificationCenter.default.post(name: .usersLoaded, object: self)
                        }
                    }
                }
                
            } else {
                self.numRequest = 0
                count += 1
                if count == 3 {
                    NotificationCenter.default.post(name: .usersLoaded, object: self)
                }
            }
            if snapshot.hasChild("receive") {
                self.database.child(safeEmail).child("receive").observeSingleEvent(of: .value) { (user) in
                    if let users = user.value as? [String] {
                        self.numReceive = users.count
                        DatabaseManager.shared.checkBlock { (bool) in
                            var newUser = users
                            if (bool) {
                                DatabaseManager.shared.getBlock { (users2) in
                                    var pos = 0
                                    for each in users {
                                        print(users2.contains(each))
                                        if users2.contains(each) {
                                            newUser.remove(at: pos)
                                            pos -= 1
                                        }
                                        pos += 1
                                    }
                                    self.secEmailList = newUser
                                    self.numReceive = newUser.count
                                    count += 1
                                    if count == 3 {
                                        NotificationCenter.default.post(name: .usersLoaded, object: self)
                                    }
                                }
                            } else {
                                self.secEmailList = users
                                self.numReceive = users.count
                                count += 1
                                if count == 3 {
                                    NotificationCenter.default.post(name: .usersLoaded, object: self)
                                }
                            }
                        }
                    }
                }
                
            } else {
                self.numReceive = 0
                count += 1
                if count == 3 {
                    NotificationCenter.default.post(name: .usersLoaded, object: self)
                }
            }
            if snapshot.hasChild("accept") {
                self.database.child(safeEmail).child("accept").observeSingleEvent(of: .value) { (user) in
                    if let users = user.value as? [String] {
                        self.numAccept = users.count
                        DatabaseManager.shared.checkBlock { (bool) in
                            var newUser = users
                            if (bool) {
                                DatabaseManager.shared.getBlock { (users2) in
                                    var pos = 0
                                    for each in users {
                                        print(users2.contains(each))
                                        if users2.contains(each) {
                                            newUser.remove(at: pos)
                                            pos -= 1
                                        }
                                        pos += 1
                                    }
                                    self.accEmailList = newUser
                                    self.numAccept = newUser.count
                                    count += 1
                                    if count == 3 {
                                        NotificationCenter.default.post(name: .usersLoaded, object: self)
                                    }
                                }
                            } else {
                                self.accEmailList = users
                                self.numAccept = users.count
                                count += 1
                                if count == 3 {
                                    NotificationCenter.default.post(name: .usersLoaded, object: self)
                                }
                            }
                        }
                        
                    }
                }
                
            } else {
                count += 1
                if count == 3 {
                    NotificationCenter.default.post(name: .usersLoaded, object: self)
                }
                self.numAccept = 0
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RequestTableViewCell.identifier, for: indexPath) as! RequestTableViewCell
        cell.backgroundColor = secondary
        let backgroundView = UIView()
        backgroundView.backgroundColor = secondary
        cell.selectedBackgroundView = backgroundView
        
        if (indexPath.section == 0) {
        let email = emailList[indexPath.row]
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        var username = ""
        DatabaseManager.shared.grabUsername(safeEmail: safeEmail) { (firstNameString) in
            username += firstNameString
            DatabaseManager.shared.grabLast(safeEmail: safeEmail) { (lastNameString) in
                username += " \(lastNameString)"
                let path = "images/\(safeEmail)_profile_picture.png"
                cell.configure(path: path, name: username, section: 0)
                }
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row < secEmailList.count) {
            let email = secEmailList[indexPath.row]
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            var username = ""
            DatabaseManager.shared.grabUsername(safeEmail: safeEmail) { (firstNameString) in
                username += firstNameString
                DatabaseManager.shared.grabLast(safeEmail: safeEmail) { (lastNameString) in
                    username += " \(lastNameString)"
                    let path = "images/\(safeEmail)_profile_picture.png"
                    cell.configure(path: path, name: username, section: 1)
                    }
                }
            }
        }
        if (indexPath.section == 2) {
            if (indexPath.row < accEmailList.count) {
            let email = accEmailList[indexPath.row]
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            var username = ""
            DatabaseManager.shared.grabUsername(safeEmail: safeEmail) { (firstNameString) in
                username += firstNameString
                DatabaseManager.shared.grabLast(safeEmail: safeEmail) { (lastNameString) in
                    username += " \(lastNameString)"
                    let path = "images/\(safeEmail)_profile_picture.png"
                    cell.configure(path: path, name: username, section: 2)
                    }
                }
            }
        }
        
        
        //here
        
        //cell.configure(image: profilePic, name: self.name)
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
        let footView = UIView()
        footView.backgroundColor = secondary
            let text = UILabel()
            text.text = "Requesting"
            let font = UIFont(name: "Symbol", size: 18)!
            let fontMetrics = UIFontMetrics(forTextStyle: .title1)
            text.font = fontMetrics.scaledFont(for: font)
            footView.addSubview(text)
            text.textColor = primary
        footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 60)
            text.frame = CGRect(x: 30, y: 10, width: view.width-60, height: 20)
            if emailList.count == 0 {
                footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 0)
                text.frame = CGRect(x: 30, y: 10, width: view.width-60, height: 0)
            }
            return footView
            
        }
        if (section == 1) {
            let footView = UIView()
            footView.backgroundColor = secondary
            let text = UILabel()
            text.text = "Request Received"
            let font = UIFont(name: "Symbol", size: 18)!
            let fontMetrics = UIFontMetrics(forTextStyle: .title1)
            text.font = fontMetrics.scaledFont(for: font)
            text.textColor = primary
            footView.addSubview(text)
            footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 60)
            text.frame = CGRect(x: 30, y: 10, width: view.width-60, height: 20)
            if secEmailList.count == 0 {
                footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 0)
                text.frame = CGRect(x: 30, y: 10, width: view.width-60, height: 0)
            }
            return footView
            
        }
        if (section == 2) {
            let footView = UIView()
            footView.backgroundColor = secondary
            let text = UILabel()
            text.text = "Accpted Users"
            let font = UIFont(name: "Symbol", size: 18)!
            let fontMetrics = UIFontMetrics(forTextStyle: .title1)
            text.font = fontMetrics.scaledFont(for: font)
            text.textColor = primary
            footView.addSubview(text)
            footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 60)
            text.frame = CGRect(x: 30, y: 10, width: view.width-60, height: 20)
            if accEmailList.count == 0 {
                footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 0)
                text.frame = CGRect(x: 30, y: 10, width: view.width-60, height: 0)
            }
            return footView
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return numRequest
        }
        if section == 1 {
            return numReceive
        }
        if section == 2 {
            return numAccept
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                if (indexPath.section == 0) {
                    var username = ""
                    DatabaseManager.shared.grabUsername(safeEmail: self.emailList[indexPath.row]) { (firstNameString) in
                        username += firstNameString
                        DatabaseManager.shared.grabLast(safeEmail: self.emailList[indexPath.row]) { (lastNameString) in
                            username += " \(lastNameString)"
                            DatabaseManager.shared.getStatus(email: self.emailList[indexPath.row]) { (status) in
                                let path = "images/\(self.emailList[indexPath.row])_profile_picture.png"
                                
                                let vc = ProfileUserViewController(with: username, status: status, path: path, isMine: false, email: self.emailList[indexPath.row], request: 3, passcord: false)
                                self.navigationController?.pushViewController(vc, animated: true)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
                if indexPath.section == 1 {
                    var username = ""
                    DatabaseManager.shared.grabUsername(safeEmail: self.secEmailList[indexPath.row]) { (firstNameString) in
                        username += firstNameString
                        DatabaseManager.shared.grabLast(safeEmail: self.secEmailList[indexPath.row]) { (lastNameString) in
                            username += " \(lastNameString)"
                            DatabaseManager.shared.getStatus(email: self.secEmailList[indexPath.row]) { (status) in
                                if indexPath.section == 1 {
                                    let path = "images/\(self.secEmailList[indexPath.row])_profile_picture.png"
                                    let vc = ProfileUserViewController(with: username, status: status, path: path, isMine: false, email: self.secEmailList[indexPath.row], request: 4, passcord: false)
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                            
                        }
                        
                    }
                }
                
                
                if (indexPath.section == 2) {
                    let email = self.accEmailList[indexPath.row]
                    DatabaseManager.shared.grabFullname(safeEmail: self.accEmailList[indexPath.row]) { (firstNameString) in
                            self.createNewConversation(name: firstNameString, email: email)
                    }
                }
        //IDEA
        //when rerolled, reset nameList, emailList, and numList,
        //and change imageview and uitextlabel accoredingly.
        
    }
    
    private func createNewConversation(name: String, email: String) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //let name = DatabaseManager.shared.getUserName(email: email)
        print("this once")
        DatabaseManager.shared.conversationExist(with: safeEmail, completion: { [weak self] result in
            print("this twice")
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                print("this")
                let vc = ChatViewController(with: safeEmail, id: conversationId, passcord:nil)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                print("activated")
                let vc = ChatViewController(with: safeEmail, id: nil, passcord:nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    
        
        
    }
}
