//
//  ViewController.swift
//  Messanger
//
//  Created by choi jun hyung on 7/7/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import UserNotifications
import Connectivity
import FirebaseDatabase


///Controller that shows lists of conversations

final class ConversationsViewController: UIViewController {
    
    private let spinners = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    

    private var blockUsers:[String] = [String]()
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
        
    let connectivity: Connectivity = Connectivity()
    
    let connectionMark = UIImageView()
    
    var notificationButtonTapped = false
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Start a conversation!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    @IBAction func sendEmail(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        user.sendEmailVerification { (error) in
            guard let error = error else {
                return print("user varification email sent")
            }
            self.handleError(error: error)
        }
        
    }
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    
    private func setColor() {
        guard let theme = UserDefaults.standard.value(forKey: "theme") as? String else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
            //third = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            third = UIColor(named: "whiteThemeBackgroundColor")!
            return
        }
        if (theme == "orange") {
            primary = UIColor(named: "OrangePri")!
            secondary = UIColor(named: "OrangeSec")!
            third = UIColor(named: "OrangeThi")!
        } else if (theme == "pink") {
            primary = UIColor(named: "mainThemePrimary")!
            secondary = UIColor(named: "mainThemeSecondary")!
            third = UIColor(named: "mainThemeThird")!
        } else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
            //third = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            third = UIColor(named: "whiteThemeBackgroundColor")!
        }
    }
    
    @objc func openVC(notification: Notification) {
        
        guard let vc = notification.userInfo!["vc"] as? ProfileUserViewController else {
            spinners.dismiss()
            return
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        spinners.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let updatedValue: [String:Any] = [
//            "date": "some dates",
//            "is_read": false,
//            "message": "some messs",
//            "type": "text"
//        ]
//        Database.database().reference().child("conversation_an7695092417-gmail-com_junhyungch-gmail-com_Aug 5, 2021 at 8:54:52 AM GMT").child("messages").child("\(0)").setValue(3) { error, _ in
//            print(error.debugDescription)
//        }
        validateAuth()
        validateEmail()
        setColor()
        spinners.backgroundColor = secondary
        spinners.tintColor = primary
        noConversationsLabel.textColor = primary
        NotificationCenter.default.addObserver(forName: .loadProfile, object: nil, queue: nil, using: openVC(notification:))
        NotificationCenter.default.addObserver(self, selector: #selector(listenConv), name: .listenConv, object: nil)
        NotificationCenter.default.addObserver(forName: .uponUserQuittingChatView, object: nil, queue: nil, using: userRead(notification:))
        NotificationCenter.default.addObserver(self, selector: #selector(spinner), name: .spinner, object: nil)
//        let primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
//        let secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
//        let third:UIColor = #colorLiteral(red: 1, green: 0.9404397011, blue: 0.9045404792, alpha: 1)
        view.backgroundColor = secondary
        DatabaseManager.shared.checkOnlineStatus()
        DatabaseManager.shared.isOnline()
        
        self.connectionMark.isHidden = true
        self.configureConnectivityNotifier()
        print(1)
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print(2)
            return
        }
        guard let name = UserDefaults.standard.value(forKey: "name") as? String else {
            print(3)
            return
        }
        
        print("\(name) \(email)")
        self.navigationController?.navigationBar.barTintColor = third
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        self.navigationController?.tabBarController?.tabBar.tintColor = primary
        self.navigationController?.tabBarController?.tabBar.barTintColor = third
        self.navigationController?.tabBarController?.tabBar.unselectedItemTintColor = secondary
        let glass = UIImage(systemName: "magnifyingglass")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: glass, style: .done,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        navigationItem.rightBarButtonItem?.tintColor = primary
        navigationItem.leftBarButtonItem?.tintColor = primary
        
        let envelope = UIImage(systemName: "envelope.open")
        let newEnvelope = UIImage(systemName: "envelope.badge")
        envelope?.withTintColor(primary)
        newEnvelope?.withTintColor(primary)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: envelope, style: .done, target: self, action: #selector(presentRequestView))
        navigationItem.leftBarButtonItem?.tintColor = primary
        DatabaseManager.shared.checkAnyReceive(completion: {(new) in
            if (new) {
                self.navigationItem.leftBarButtonItem?.image = newEnvelope
            }
        })
        
        
        //let rightIcon = UIImage(systemName: "plus")
        //let rightBarButton = UIBarButtonItem(image: rightIcon, style: .done, target: self, action: #selector(didTapComposeButton))
        //self.navigationItem.rightBarButtonItem = rightBarButton
                
        
        //LATER
        //let notificationIcon = UIImage(systemName: "bell.fill")
        //let leftBarButton = UIBarButtonItem(image: notificationIcon, style: .done, target: self, action: #selector(didTapNotification))
        //leftBarButton.isEnabled = NotificationHelper.sharedManager.userAllowsNotification
        
        
        //self.navigationItem.leftBarButtonItem = leftBarButton
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        view.addSubview(connectionMark)
        setupTableView()
        startListeningForConversations()
        
        connectionMark.frame = CGRect(x: (self.view.frame.width / 2) - 25,
                                      y: 44,
                                      width: 50,
                                      height: 50)
        connectionMark.image = UIImage(systemName: "wifi.slash")
        connectionMark.tintColor = primary
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: {_ in
            print("reached")
            self.startListeningForConversations()
            self.startListeningForConversations()
        })
        let content = UNMutableNotificationContent()
        content.title = "Tester Test"
        content.body = "Yo whats going on"
        //center = UNUserNotificationCenter.current()
        
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.tintColor = primary
        
        //let date = Date().addingTimeInterval(5)
        
        //let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        //let uuidString = UUID().uuidString
        //let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        //center.add(request) { (error) in
        //}
        //center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
    }
    
    //TODO: Casey said to move me whereever you want
    @objc func reloadTheNames() {
        self.tableView.reloadData()
    }
    
    @objc func presentRequestView() {
        let vc = RequestTableViewController()
        vc.title = "Users"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func spinner() {
        spinners.show(in: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UserDefaults.standard.setValue(true, forKey: "setPassword")
        
        //DatabaseManager.shared.insertDummy()
        
        startConnectivityChecks()
        validatePassword()
        self.navigationController?.navigationBar.isHidden = false
        setColor()
        tableView.reloadData()
        let glass = UIImage(systemName: "magnifyingglass")
        glass?.withTintColor(primary)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: glass, style: .done,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        navigationItem.rightBarButtonItem?.tintColor = primary
        let envelope = UIImage(systemName: "envelope.open")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: envelope, style: .done, target: self, action: #selector(presentRequestView))
        
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.barTintColor = third
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        self.navigationController?.tabBarController?.tabBar.tintColor = primary
        self.navigationController?.tabBarController?.tabBar.barTintColor = third
        self.navigationController?.tabBarController?.tabBar.unselectedItemTintColor = secondary
        tableView.rowHeight = fontExamine()
        startListeningForConversations()
        setupTableView()
        DatabaseManager.shared.checkAnyReceive(completion: {(new) in
            let envelope = UIImage(systemName: "envelope.open")
            let newEnvelope = UIImage(systemName: "envelope.badge")

            envelope?.withTintColor(self.primary)
            newEnvelope?.withTintColor(self.primary)
            if (new) {
                self.navigationItem.leftBarButtonItem?.image = newEnvelope
                self.navigationItem.leftBarButtonItem?.tintColor = self.primary
            } else {
                self.navigationItem.leftBarButtonItem?.image = envelope
                self.navigationItem.leftBarButtonItem?.tintColor = self.primary
            }
        })
        guard let emai = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let email = DatabaseManager.safeEmail(emailAddress: emai)
        DatabaseManager.shared.getAllConversations(for: email, completion: { [weak self] result in
            switch result {
            case .success(let  conversationss):
                print("successfully got conversation models")
                guard !conversationss.isEmpty else {
                    //self?.noConversationsLabel.isHidden = true
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
            case .failure(let error):
                print(error.localizedDescription)
            }})
        //self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //self.tableView.backgroundColor = UIColor(hex: "DDEEFB")
    }
    //here
    @objc func listenConv() {
        print("listened")
        startListeningForConversations()
        tableView.reloadData()
    }
    
    func handleError(error: Error) {
        
        let errorAuthStatus = AuthErrorCode.init(rawValue: error._code)!
        switch errorAuthStatus {
        case .wrongPassword:
            print("wrong password")
        case .emailAlreadyInUse:
            print("Email is in use")
        case .invalidEmail:
            print("invalid email")
        case .userDisabled:
            print("user disabled")
        case .tooManyRequests:
            print("tooManyRequests")
        
        default:
            fatalError("errors not supported here")
        }
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            print("no email")
            return
        }
        print("starting conversation fetch...")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { result in
            switch result {
            case .success(let  conversationss):
                print("successfully got conversation models")
                guard !conversationss.isEmpty else {
                    //self?.noConversationsLabel.isHidden = true
                    self.tableView.isHidden = true
                    self.noConversationsLabel.isHidden = false
                    return
                }
                var newconv = conversationss
                print(1)
                DatabaseManager.shared.checkBlock { (bool) in
                    if (bool) {
                        print(2)
                        DatabaseManager.shared.getBlock { (users) in
                            print(3)
                            var positinToRemove = 0
                            for conversation in conversationss {
                                    let id = conversation.otherUserEmail
                                if (positinToRemove >= conversationss.count){
                                    print(4)
                                    break
                                }
                                print(5)
                                if users.contains(id) {
                                    newconv.remove(at: positinToRemove)
                                    positinToRemove -= 1
                                }
                                positinToRemove += 1
                            }
                            print(6)
                            DispatchQueue.main.async {
                                print(7)
                                self.tableView.isHidden = false
                                self.noConversationsLabel.isHidden = true
                                self.tableView.reloadData()
                            }
                            self.conversations = newconv
                        }
                        
                    } else {
                        print(8)
                        self.conversations = conversationss
                        DispatchQueue.main.async {
                            self.tableView.isHidden = false
                            self.noConversationsLabel.isHidden = true
                            self.tableView.backgroundColor = self.secondary
                            self.tableView.reloadData()
                        }
                    }
                }
                
            case .failure(let error):
                self.tableView.isHidden = true
                self.noConversationsLabel.isHidden = false
                print("failed to get convos:\(error)")
                //alertuiview
            }
        })
    }
    
    @objc private func didTapNotification(){
        if notificationButtonTapped {
            //notificationEnabled = true
            NotificationHelper.sharedManager.requestUserPermission()
        } else {
                
            self.notificationButtonTapped = true
            //notificationEnabled = false
            
        }
                
            
        
    }
    
    func fontExamine() -> CGFloat {
        let labell = UILabel()
        let font = UIFont(name: "Symbol", size: 20)!
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        labell.font = fontMetrics.scaledFont(for: font)
        labell.adjustsFontForContentSizeCategory = true
        if (2.5 * (labell.font.pointSize) > 120 ) {
            return 2.5 * (labell.font.pointSize)
        } else {
            return 120
        }
    }
    
    @objc private func didTapComposeButton() {
        
                let vc = NewConversationViewController()
                //vc.view.backgroundColor = third
                vc.completion = { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    let currentConversation = strongSelf.conversations
                    if let targetConversation = currentConversation.first(where: {
                        $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
                    }) {
                        let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id, passcord: nil)
                        vc.isNewConversation = false
                        
                        //exp
                        
                        
                        vc.title = targetConversation.name
                        vc.navigationItem.largeTitleDisplayMode = .never
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        strongSelf.createNewConversation(result: result)
                    }
                }
                let navVC = UINavigationController(rootViewController: vc)
                self.present(navVC, animated: true)
        
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        //let name = DatabaseManager.shared.getUserName(email: email)
        DatabaseManager.shared.getStatus(email: email) { status in
            let path = "images/\(email)_profile_picture.png"
            let vc = ProfileUserViewController(with: name, status: status, path: path, isMine: false, email: email, request: 2, passcord: false)
            vc.title = "User Profile"
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func goodConnection() {
        self.connectionMark.isHidden = true
    }
        
    private func badConnection() {
        self.connectionMark.isHidden = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        validateEmail()
        
    }
        
    private func validateAuth(){
            if FirebaseAuth.Auth.auth().currentUser == nil {
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.navigationController?.navigationBar.barTintColor = secondary
                present(nav, animated: false)
            }
        
    }
    
    private func validatePassword() {
//            let vc = PasswordView(email: "", opening: false, passcord: "", reset: true, create: true)
//            vc.title = "Set Password"
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true)
        guard let password = UserDefaults.standard.value(forKey: "setPassword") as? Bool else {
            print("noval")
            return
        }
        if !password {
            let alert = UIAlertController(title: "Notification", message: "Password is required in order to use some features in this app. Please set a password for this app by using 'change password' feature in the setting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
                UserDefaults.standard.setValue(true, forKey: "setPassword")
            }))
            self.present(alert, animated: true)
            
        }
    }
    
    private func validateDemo(){
        guard let name = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        if name == "demo-mode" {
            let vc = ChangeNameViewController()
            vc.title = "Set your name"
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
    
    private func validateEmail(){
        guard let user = Auth.auth().currentUser else {
                   return
               }
        guard let isDemoUser = user.email?.hasPrefix("demo@here.net") else {
            return
        }
        if !isDemoUser {
               user.reload { (error) in
                   switch user.isEmailVerified {
                   case true:
                        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                            return
                        }
                        DatabaseManager.shared.getUserID(email: email) { (id) in
                        DatabaseManager.shared.verifiedAppend(int: id)
                            
                    }
                   case false:
                        let vc = VerifyViewController(registering: false)
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: false)
                }
            }
        }
    }
    

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    //here
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
        for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model, indexpath: indexPath)
        let backgroundView = UIView()
        backgroundView.backgroundColor = secondary
        cell.selectedBackgroundView = backgroundView
        if (self.tableView.numberOfRows(inSection: 0) == DatabaseManager.shared.namelist.count) {
        cell.userNameLabel.text = DatabaseManager.shared.namelist[indexPath.row]
        }
        cell.accessoryType = .detailButton
        cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //cell.backgroundColor = .red
        
        cell.accessoryView?.layer.borderWidth = 10
        cell.contentView.clipsToBounds = true
        //cell.clipsToBounds = true
        
        cell.layer.borderWidth = 10
        cell.layer.cornerRadius = 35
        let color = secondary
        cell.layer.borderColor = color.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let model = conversations[indexPath.row]
        let name = model.name
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        DatabaseManager.shared.getStatus(email: model.otherUserEmail) { (status) in
            DatabaseManager.shared.checkPasscord(index: "\(indexPath.row)") { (hasPasscord) in
                if (hasPasscord) {
                    let vc = ProfileUserViewController(with: name, status: status, path: path, isMine: false, email: model.otherUserEmail, request: 6, passcord: true)
                    vc.navigationController?.navigationBar.tintColor = self.third
                    vc.navigationItem.largeTitleDisplayMode = .never
                    vc.title = "User Profile"
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = ProfileUserViewController(with: name, status: status, path: path, isMine: false, email: model.otherUserEmail, request: 6, passcord: false)
                    vc.navigationController?.navigationBar.tintColor = self.third
                    vc.navigationItem.largeTitleDisplayMode = .never
                    vc.title = "User Profile"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
                
            
            
        }
    }
    
    func userRead(notification: Notification) {
        guard let id = notification.userInfo!["id"] as? String else {
            return
        }
        DatabaseManager.shared.getConvID(convId: id) { index in
            print(index)
            DatabaseManager.shared.userRead(indexpath: index)
        }
        
//        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ConversationTableViewCell
//        cell.userread()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        spinners.show(in: view)
        let cell = tableView.cellForRow(at: indexPath) as! ConversationTableViewCell
        cell.userread()
        self.tableView.isUserInteractionEnabled = false
        tableView.deselectRow(at: indexPath, animated: true)
                let model = self.conversations[indexPath.row]
        DatabaseManager.shared.getConvID(convId: model.id) { convId in
            DatabaseManager.shared.userRead(indexpath: convId)
        }
        DatabaseManager.shared.grabFullname(safeEmail: model.otherUserEmail) { name in
            DatabaseManager.shared.checkPasscord(index: "\(indexPath.row)") { (passcord) in
                if passcord {
                    DatabaseManager.shared.getPasscord(index: "\(indexPath.row)") { (pass) in
                        print("naw naw")
                        let vc = ChatViewController(with: model.otherUserEmail, id: model.id, passcord: pass)
                        vc.title = name
                        vc.navigationItem.largeTitleDisplayMode = .never
                        self.spinners.dismiss()
                        self.navigationController?.pushViewController(vc, animated: true)
                        self.tableView.isUserInteractionEnabled = true
                        
                    }
                } else {
                    self.spinners.dismiss()
                    self.openConversation(model, indexpath: indexPath.row)
                    self.tableView.isUserInteractionEnabled = true
                }
        }
        }
                
    }

    func openConversation(_ model: Conversation, indexpath: Int){
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id, passcord:nil)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        DatabaseManager.shared.userRead(indexpath: indexpath)
        navigationController?.pushViewController(vc, animated: true)
        DatabaseManager.shared.addIndex(indexPath: indexpath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let num = fontExamine()
        return num
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { [self] action,view,completionHandler in
                let actionSheet = UIAlertController(title: "Delete conversation",
                                                    message: "Do you want to delete this conversation?",
                                                    preferredStyle: .alert)
                actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                    style: .cancel,
                                                    handler: nil))
                actionSheet.addAction(UIAlertAction(title: "Yes", style: .default, handler:  { _ in
                    let conversationId = self.conversations[indexPath.row].id
                    tableView.beginUpdates()
                    self.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                        switch success{
                        case .success(_):
                            print("ok")
                        case .failure(let error):
                            let alert = UIAlertController(title: "Notification", message: "Failed deleting a conversation: \(error.localizedDescription)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            
                            }
                    })
                    tableView.endUpdates()
                }))
                self.present(actionSheet, animated: true)
                completionHandler(true)
            })
            delete.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    //    return .delete
    //}
    
     
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("hi")
        }
    }
}

extension ConversationsViewController {
    func configureConnectivityNotifier() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
             self?.updateConnectionStatus(connectivity.status)
        }
        
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        
        startConnectivityChecks()
    }

    func startConnectivityChecks() {
        connectivity.startNotifier()
    }
    
    func stopConnectivityChecks() {
        connectivity.stopNotifier()
    }
    
//    connectivity.whenConnected = connectivityChanged
//    connectivity.whenDisconnected = connectivityChanged

    func updateConnectionStatus(_ status: Connectivity.Status) {

        switch status {
        case .connected:
            self.goodConnection()
            print("connected")
        case .connectedViaWiFi:
            self.goodConnection()
            print("wifi connected")
        case .connectedViaWiFiWithoutInternet:
            self.badConnection()
            print("connected wifi without internet")
        case .connectedViaCellular:
            self.goodConnection()
            print("connected with cellular")
        case .connectedViaCellularWithoutInternet:
            self.badConnection()
            print("cellular but no internet")
        case .notConnected:
            self.badConnection()
            print("not connected")
        case .determining:
            print("determining...")
        }
    }
}
