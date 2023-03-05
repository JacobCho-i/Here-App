//
//  BlockedUsersTableViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/30/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseDatabase
class BlockedUsersTableViewController: UITableViewController {

    private var emailList:[String] = []
    private var notColored = true
    
    private var numBlock:Int = 0
    
    
    private let database = Database.database().reference()
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    override func viewDidLoad() {
        setColor()
        reload()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        
        tableView.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)
        self.navigationController?.tabBarItem.badgeColor = primary
        view.backgroundColor = secondary
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        let image = UIImage(systemName: "arrow.clockwise")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(reload))
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        tableView.tintColor = primary
        navigationItem.rightBarButtonItem?.tintColor = primary
        tableView.separatorColor = .clear
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        tableView.reloadData()
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
        return 1
    }
    
    
    @objc func reload() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("block") {
                self.database.child(safeEmail).child("block").observeSingleEvent(of: .value) { (user) in
                    if let users = user.value as? [String] {
                        self.numBlock = users.count
                        self.emailList = users
                        self.tableView.reloadData()
                        print("found user")
                    }
                }
                
            } else {
                self.numBlock = 0
                print("no user")
            }
        }
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserTableViewCell.identifier, for: indexPath) as! BlockedUserTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = secondary
        cell.selectedBackgroundView = backgroundView
        
        let email = emailList[indexPath.row]
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        var username = ""
        DatabaseManager.shared.grabUsername(safeEmail: safeEmail) { (firstNameString) in
            username += firstNameString
            DatabaseManager.shared.grabLast(safeEmail: safeEmail) { (lastNameString) in
                username += " \(lastNameString)"
                let path = "images/\(safeEmail)_profile_picture.png"
                cell.configure(path: path, name: username)
                }
            }
        
        
        
        //here
        
        //cell.configure(image: profilePic, name: self.name)
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footView = UIView()
        footView.backgroundColor = secondary
            let text = UILabel()
            text.text = "Blocked Users"
        text.textColor = primary
            let font = UIFont(name: "Symbol", size: 18)!
            let fontMetrics = UIFontMetrics(forTextStyle: .title1)
            text.font = fontMetrics.scaledFont(for: font)
            footView.addSubview(text)
        footView.frame = CGRect(x: 0, y: 0, width: view.width, height: 60)
            text.frame = CGRect(x: 30, y: 15, width: view.width-60, height: 20)
            return footView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numBlock
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            var username = ""
            DatabaseManager.shared.grabUsername(safeEmail: self.emailList[indexPath.row]) { (firstNameString) in
                username += firstNameString
                DatabaseManager.shared.grabLast(safeEmail: self.emailList[indexPath.row]) { (lastNameString) in
                    username += " \(lastNameString)"
                        DatabaseManager.shared.getStatus(email: self.emailList[indexPath.row]) { (status) in
                            let path = "images/\(self.emailList[indexPath.row])_profile_picture.png"
                            let vc = ProfileUserViewController(with: username, status: status, path: path, isMine: false, email: self.emailList[indexPath.row], request: 5, passcord: false)
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                    
                }
            }
        
        //IDEA
        //when rerolled, reset nameList, emailList, and numList,
        //and change imageview and uitextlabel accoredingly.
        
    }
    
    private func createNewConversation(name: String, email: String) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //let name = DatabaseManager.shared.getUserName(email: email)
        
        DatabaseManager.shared.conversationExists(with: safeEmail, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: safeEmail, id: conversationId, passcord:nil)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: safeEmail, id: nil, passcord:nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        
    }

}
