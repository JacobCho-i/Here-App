//
//  ProfileUserViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/26/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import JGProgressHUD

class ProfileUserViewController: UIViewController {

    private var username:String = String()
    static var userStatus:String = String()
    private var url:String = String()
    private var mine:Bool = Bool()
    private var otherEmail:String = String()
    private var hasPasscord: Bool = Bool()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var isRequesting:Int = Int()
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let usernameLabel: UILabel = {
        let field = UILabel()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let userImageView: UIImageView = {
        let field = UIImageView()
        field.layer.cornerRadius = 125
        field.layer.masksToBounds = true
        //field.translatesAutoresizingMaskIntoConstraints = false
        field.layer.borderWidth = 5
        field.contentMode = .scaleToFill
        return field
    }()
    
    private let status: UILabel = {
        let field = UILabel()
        field.textColor = .systemGray2
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let userStatusLabel: UILabel = {
        let field = UILabel()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let statusEdit: UIButton = {
        let field = UIButton()
        field.setTitle("Edit", for: .normal)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let transparentView: UIView = UIView()
    
    private let emailField2: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemBackground
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let reportButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
       // button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let requestButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        //button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let acceptButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rejectButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let setPasswordButton: UIButton = {
        let field = UIButton()
        field.imageView?.contentMode = .scaleAspectFit
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let blockButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        //button.imageView?.contentMode = .scaleAspectFit
        //button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let newButton: UIButton = {
       let button = UIButton()
        //button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        //button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let alertView: UIView = UIView()
    private let alertLabel: UILabel = UILabel()
    private let alertButton: UIButton = {
        let field = UIButton()
        field.setTitle("X", for: .normal)
        return field
    }()
    
    private let onlineStatus: UILabel = {
        let field = UILabel()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        setupViewController()
        view.backgroundColor = third
        
        self.navigationController?.tabBarController?.tabBar.backgroundColor = third
        reportButton.addTarget(self, action: #selector(report), for: .touchUpInside)
        setup()
    }
    
    private func setupViewController() {
        view.addSubview(scrollView)
        alertView.isHidden = true
        scrollView.contentSize = CGSize(width: view.width, height: 2000)
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.addSubview(backgroundView)
        
        
        
        
        
        scrollView.addSubview(usernameLabel)
        
        usernameLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 320).isActive = true
        
        scrollView.addSubview(userImageView)
        
        userImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        userImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25).isActive = true
//        userImageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 100).isActive = true
//        userImageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width/2 - 100).isActive = true
//        userImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, constant: 250).isActive = true
        userImageView.widthAnchor.constraint(equalTo: userImageView.widthAnchor, constant: 250).isActive = true
//        userImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollView.addSubview(status)
        
        status.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30).isActive = true
        status.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 400).isActive = true
        
        scrollView.addSubview(userStatusLabel)
        
        userStatusLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        userStatusLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30).isActive = true
        userStatusLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 430).isActive = true
        
        scrollView.addSubview(statusEdit)
        
        statusEdit.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width-60).isActive = true
        statusEdit.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 400).isActive = true
        
        scrollView.addSubview(requestButton)
        
        //reportButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        requestButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30).isActive = true
        requestButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 540).isActive = true
        requestButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.25).isActive = true
        requestButton.heightAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 0.4).isActive = true
        scrollView.addSubview(reportButton)
        
        reportButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        reportButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 540).isActive = true
        //requestButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 130).isActive = true
        reportButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.25).isActive = true
        reportButton.heightAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 0.4).isActive = true
        scrollView.addSubview(blockButton)
        
        blockButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        blockButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 540).isActive = true
        blockButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width - 30).isActive = true
        blockButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.25).isActive = true
        blockButton.heightAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 0.4).isActive = true
        scrollView.addSubview(newButton)
        newButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        newButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width).isActive = true
        
        scrollView.addSubview(acceptButton)
        
        acceptButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 600).isActive = true
        acceptButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width/2 - 30).isActive = true
        
        scrollView.addSubview(rejectButton)
        
        rejectButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 600).isActive = true
        rejectButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width-30).isActive = true
        rejectButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: view.width/2 + 30).isActive = true
        
        //scrollView.addSubview(setPasswordButton)
        //setPasswordButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25).isActive = true
        //setPasswordButton.backgroundColor = .red
        //setPasswordButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: view.width-30).isActive = true
        
        scrollView.addSubview(onlineStatus)
        
        onlineStatus.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        onlineStatus.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 720).isActive = true
        onlineStatus.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 30).isActive = true
        
        transparentView.isHidden = true
        scrollView.addSubview(transparentView)
        
        scrollView.addSubview(alertView)
        alertView.addSubview(alertLabel)
        alertView.addSubview(alertButton)
        
    }
    
    @objc func buttonTapped() {
        alertView.isHidden = true
        transparentView.isHidden = true
    }
    
    
    @objc func report() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        guard !(email == "demo-mode") else {
            let alert = UIAlertController(title: "Notification", message: "Please register in order to use this feature", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let vc = ReportViewController(with: otherEmail)
        vc.title = "Report a user"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        statusEdit.isHidden = true
        reportButton.isHidden = true
        requestButton.isHidden = true
        blockButton.isHidden = true
        rejectButton.isHidden = true
        acceptButton.isHidden = true
        newButton.isHidden = true
        if (mine) {
            statusEdit.isHidden = false
        } else {
            reportButton.isHidden = false
            requestButton.isHidden = false
            blockButton.isHidden = false
        }
        if isRequesting == 4 {
            //requestButton.isHidden = true
            //rejectButton.isHidden = false
            //acceptButton.isHidden = false
        }
        if isRequesting == 6 {
            requestButton.isHidden = true
        }
        let passcordImage = UIImage(systemName: "circle.grid.3x3.fill")
        newButton.setImage(passcordImage, for: .normal)
        newButton.layer.borderWidth = 2
        newButton.layer.borderColor = primary.cgColor
        newButton.layer.cornerRadius = 17.5
        newButton.imageView?.tintColor = primary
        if hasPasscord {
            //setPasswordButton.setTitle("reset passcord", for: .normal)
            newButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        } else {
            //setPasswordButton.setTitle("set passcord", for: .normal)
            newButton.addTarget(self, action: #selector(setPassword), for: .touchUpInside)
        }
        setup()
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
    
    
    init(with name: String, status: String, path:String, isMine: Bool, email: String, request:Int, passcord: Bool) {
        self.username = name
        ProfileUserViewController.self.userStatus = status
        self.url = path
        self.mine = isMine
        self.otherEmail = email
        super.init(nibName: nil, bundle: nil)
        self.isRequesting = request
        self.hasPasscord = passcord
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {
        DatabaseManager.shared.checkDelete(email: otherEmail) { deleted in
            if deleted {
                self.usernameLabel.text = "Deleted User"
                self.userStatusLabel.text = ""
                self.url = ""
                self.statusEdit.isHidden = true
                self.reportButton.isHidden = true
                self.requestButton.isHidden = true
                self.blockButton.isHidden = true
                self.rejectButton.isHidden = true
                self.acceptButton.isHidden = true
                self.newButton.isHidden = true
                self.setPasswordButton.isHidden = true
            } else {
                self.usernameLabel.text = self.username
                self.userStatusLabel.text = ProfileUserViewController.userStatus
            
            
            DatabaseManager.shared.checkOnline(otherUserEmail: self.otherEmail) { online in
                if online == "online" {
                    self.onlineStatus.text = "online"
                } else if online == "Idle" {
                    self.onlineStatus.text = "Idle"
                } else {
                    let lastDate = ChatViewController.dateFormatter.date(from: online)!
                    let currentDate = Date()
                    guard let minDistance = lastDate.fullDistance(from: currentDate, resultIn: .minute) else {
                        return
                    }
                    if minDistance < 60 {
                        if minDistance == 1 {
                            self.onlineStatus.text = "last online: 1 minute ago"
                        } else {
                            self.onlineStatus.text = "last online: \(minDistance) minutes ago"
                        }
                    }
                    guard let hrDistance = lastDate.fullDistance(from: currentDate, resultIn: .hour) else {
                        return
                    }
                    if 0 < hrDistance && hrDistance < 24 {
                        if hrDistance == 1 {
                            self.onlineStatus.text = "last online: 1 hour ago"
                        } else {
                            self.onlineStatus.text = "last online: \(hrDistance) hours ago"
                            
                        }
                    }
                    guard let dayDistance = lastDate.fullDistance(from: currentDate, resultIn: .day) else {
                        return
                    }
                    if 0 < dayDistance && dayDistance < 31 {
                        if dayDistance == 1 {
                            self.onlineStatus.text = "last online: 1 day ago"
                        } else {
                            self.onlineStatus.text = "last online: \(dayDistance) days ago"
                            
                        }
                    }
                    guard let monthDistance = lastDate.fullDistance(from: currentDate, resultIn: .month) else {
                        return
                    }
                    if 0 < monthDistance && monthDistance < 12 {
                        if monthDistance == 1 {
                            self.onlineStatus.text = "last online: 1 month ago"
                        } else {
                            self.onlineStatus.text = "last online: \(monthDistance) months ago"
                        }
                    }
                    guard let yearDistance = lastDate.fullDistance(from: currentDate, resultIn: .year) else {
                        return
                    }
                    if 0 < yearDistance {
                        if yearDistance == 1 {
                            self.onlineStatus.text = "last online: 1 year ago"
                        } else {
                            self.onlineStatus.text = "last online: \(yearDistance) years ago"
                            
                        }
                    }
                    
                }
                }
                
            }
            StorageManager.shared.downloadURL(for: self.url, completion: { [weak self] result in
                switch result {
                case .success(let path):
                    self?.userImageView.sd_setImage(with: path, completed: nil)
                case .failure(let error):
                    let profilePic = UIImageView()
                    profilePic.image = UIImage(systemName: "person.circle")
                    profilePic.tintColor = self?.primary
                    self?.userImageView.image = profilePic.image
                    self?.userImageView.tintColor = self?.primary
                    print("profile failed to get image url: \(error)")
                }
            })
        }
        
        
        
    }
    
    @objc func setPassword() {
        let alert = UIAlertController(title: "Notification", message: "Do you want to set a passcord for this conversation?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { _ in
            let vc = PasswordView(email: self.otherEmail, opening: false, passcord: "", reset: false, create: false)
            vc.title = "Set password"
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    @objc func resetPassword() {
        let alert = UIAlertController(title: "Notification", message: "Do you want to change your passcord for this conversation?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { _ in
            let vc = PasswordView(email: self.otherEmail, opening: false, passcord: "", reset: true, create: false)
            vc.title = "Reset Passcord"
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func tapped() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        guard !(email == "demo-mode") else {
            let alert = UIAlertController(title: "Notification", message: "Please log in or register in order to use this feature", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let vc = UserStatusChangeViewController()
        vc.title = "change status"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func cancelRequest() {
        spinner.show(in: view)
        DatabaseManager.shared.deleteRequest(otherEmail: otherEmail, completion: {(fail) in
            switch fail {
            case .success(_):
                let alert = UIAlertController(title: "Notification", message: "You have successfully canceled a request", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                self.spinner.dismiss()
            case .failure(let error):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "Failed canceling the request: \(error.localizedDescription).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    private func createRequest(name: String, email: String) {
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
    
    @objc func accept() {
        spinner.show(in: view)
        DatabaseManager.shared.accepted(otherEmail: otherEmail, completion: {(error) in
            switch error{
            case .success(_):
                DatabaseManager.shared.conversationExist(with: self.otherEmail, completion: { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    self?.spinner.dismiss()
                    switch result {
                    case .success(let conversationId):
                        let vc = ChatViewController(with: strongSelf.otherEmail, id: conversationId, passcord:nil)
                        vc.isNewConversation = false
                        vc.title = strongSelf.username
                        vc.navigationItem.largeTitleDisplayMode = .never
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    case .failure(_):
                        let vc = ChatViewController(with: strongSelf.otherEmail, id: nil, passcord:nil)
                        vc.isNewConversation = true
                        vc.title = strongSelf.username
                        vc.navigationItem.largeTitleDisplayMode = .never
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            case .failure(let error):
            let alert = UIAlertController(title: "Notification", message: "Failed accepting a user's request: \(error.localizedDescription).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
        })
                
    }
    
    @objc func reject() {
        spinner.show(in: view)
        DatabaseManager.shared.deleteReceive(otherEmail: otherEmail, completion: {(fail) in
            switch fail {
            case .success(_):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "You have successfully rejected a request.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .failure(let error):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "Failed rejecting a user's request: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        usernameLabel.textAlignment = .center
        statusEdit.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        status.text = "Bio:"
        userStatusLabel.numberOfLines = 0
        userImageView.layer.borderColor = primary.cgColor
        usernameLabel.textColor = primary
        status.textColor = textcolor
        userStatusLabel.textColor = primary
        statusEdit.setTitleColor(primary, for: .normal)
        setPasswordButton.setTitleColor(primary, for: .normal)
        backgroundView.backgroundColor = secondary
        usernameLabel.font = UIFont(name: "Avenir", size: 20)
        userStatusLabel.font = UIFont(name: "Mukta Mahee", size: 16)
        let font = UIFont(name: "Avenir", size: 20)!
        let secFont = UIFont(name: "Mukta Mahee", size: 18)!
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        usernameLabel.font = fontMetrics.scaledFont(for: font)
        usernameLabel.adjustsFontForContentSizeCategory = true
        status.font = fontMetrics.scaledFont(for: font)
        status.adjustsFontForContentSizeCategory = true
        onlineStatus.font = fontMetrics.scaledFont(for: font)
        onlineStatus.adjustsFontForContentSizeCategory = true
        onlineStatus.textColor = primary
        userStatusLabel.font = fontMetrics.scaledFont(for: secFont)
        userStatusLabel.adjustsFontForContentSizeCategory = true
        statusEdit.adjustsImageWhenHighlighted = true
        scrollView.frame = CGRect(x: 0, y: 0, width: view.width, height: 800)
        //reportButton.backgroundColor = secondary
        reportButton.setTitleColor(primary, for: .normal)
        reportButton.layer.borderWidth = 2
        reportButton.layer.borderColor = primary.cgColor
        requestButton.layer.borderWidth = 2
        requestButton.layer.borderColor = primary.cgColor
        blockButton.layer.borderWidth = 2
        blockButton.layer.borderColor = primary.cgColor
        userImageView.frame = CGRect (x: (self.view.frame.width / 2) - 125,
                                      y: 50,
                                      width: 250,
                                      height: 250)
        usernameLabel.frame = CGRect (x: 30,
                                      y: userImageView.bottom+15,
                                      width: scrollView.width-60,
                                      height: usernameLabel.font.pointSize+10)
        status.frame = CGRect (x: 30,
                               y: usernameLabel.bottom+40,
                               width: scrollView.width-60,
                               height: status.font.pointSize+5)
        statusEdit.frame = CGRect (x: status.left-40,
                                   y: usernameLabel.bottom+40,
                                   width: 50,
                                   height: 20)
        backgroundView.frame = CGRect (x: 0,
                                       y: status.top - 610,
                                       width: scrollView.width,
                                       height: 600)
        userStatusLabel.frame = CGRect (x: 30,
                                        y: status.bottom+10,
                                        width: scrollView.width-50,
                                        height: userStatusLabel.font.pointSize*10+10)
        requestButton.frame = CGRect(x: 30, y: userStatusLabel.bottom + 10, width: 100, height: 100)
        scrollView.isScrollEnabled = true
        blockButton.frame = CGRect(x: (self.view.frame.width) - 130, y: userStatusLabel.bottom + 10, width: 100, height: 100)
        newButton.frame = CGRect(x: view.frame.width - 70, y: 30, width: 40, height: 40)
        reportButton.frame = CGRect(x: view.width/2 - 50, y: userStatusLabel.bottom + 10, width: 100, height: 100)
        acceptButton.frame = CGRect(x: (self.view.frame.width / 2) - (scrollView.width-60)/2, y: userStatusLabel.bottom + 30, width: (scrollView.width)/2-60, height: 40)
        rejectButton.frame = CGRect(x: self.view.frame.width - acceptButton.width - 30 , y: userStatusLabel.bottom + 30, width: (scrollView.width)/2-60, height: 40)
        onlineStatus.frame = CGRect(x: (self.view.frame.width / 2) - (scrollView.width-60)/2, y: reportButton.bottom + 50, width: scrollView.width-60, height: 40)
        
        let img = UIImage(systemName: "lock")
        let iv = UIImageView()
        iv.image = img
        iv.tintColor = primary
        iv.contentMode = .scaleAspectFill
        blockButton.addSubview(iv)
        iv.frame = CGRect(x: (blockButton.width - 40)/2, y: 20, width: 40, height: 40)
        let lb = UILabel()
        lb.text = "Block"
        
        blockButton.addSubview(lb)
        lb.textAlignment = .center
        lb.textColor = primary
        lb.frame = CGRect(x: (blockButton.width)/2 - 45, y: iv.bottom+5, width: 90, height: 20)
        
        let img2 = UIImage(systemName: "person.badge.plus")
        let iv2 = UIImageView()
        iv2.image = img2
        iv2.tintColor = primary
        requestButton.addSubview(iv2)
        iv2.frame = CGRect(x: (blockButton.width - 40)/2, y: 20, width: 40, height: 40)
        iv2.contentMode = .scaleAspectFill
        let lb2 = UILabel()
        lb2.text = "Request"
        requestButton.addSubview(lb2)
        lb2.textAlignment = .center
        lb2.textColor = primary
        lb2.frame = CGRect(x: (blockButton.width)/2 - 45, y: iv.bottom+5, width: 90, height: 20)
        
        let img3 = UIImage(systemName: "megaphone")
        let iv3 = UIImageView()
        iv3.image = img3
        iv3.tintColor = primary
        iv3.contentMode = .scaleAspectFill
        reportButton.addSubview(iv3)
        iv3.frame = CGRect(x: (blockButton.width - 40)/2, y: 20, width: 40, height: 40)
        let lb3 = UILabel()
        lb3.text = "Report"
        reportButton.addSubview(lb3)
        lb3.textAlignment = .center
        lb3.textColor = primary
        lb3.frame = CGRect(x: (blockButton.width)/2 - 45, y: iv.bottom+5, width: 90, height: 20)
        
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(reject), for: .touchUpInside)
        transparentView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
         //requestButton.backgroundColor = secondary
        rejectButton.backgroundColor = secondary
        acceptButton.backgroundColor = secondary
        rejectButton.setTitleColor(primary, for: .normal)
        acceptButton.setTitleColor(primary, for: .normal)
         requestButton.setTitleColor(primary, for: .normal)
        //blockButton.backgroundColor = secondary
        blockButton.setTitleColor(primary, for: .normal)
        rejectButton.setTitle("reject", for: .normal)
        acceptButton.setTitle("start", for: .normal)
        //blockButton.setTitle("Block", for: .normal)
        blockButton.addTarget(self, action: #selector(block), for: .touchUpInside)
        //reportButton.setTitle("Report", for: .normal)
        transparentView.alpha = 0.3
        //setPasswordButton.frame = CGRect(x: view.frame.width - 80, y: 30, width: 50, height: 50)
        newButton.contentVerticalAlignment = .fill
        newButton.contentHorizontalAlignment = .fill
        newButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        transparentView.backgroundColor = .systemGray
            if (isRequesting == 1) {
                //self.requestButton.setTitle("Requesting...", for: .normal)
                lb2.text = "Sent..."
                iv2.image = UIImage(systemName: "paperplane")
                iv2.tintColor = primary
                self.requestButton.removeTarget(self, action: #selector(self.request), for: .touchUpInside)
            }
            
            if (isRequesting == 2) {
                    //self.requestButton.setTitle("Request", for: .normal)
                    self.requestButton.addTarget(self, action: #selector(self.request), for: .touchUpInside)
                }
            if (isRequesting == 3) {
                //self.requestButton.setTitle("Cancel the Request", for: .normal)
                lb2.text = "Cancel"
                iv2.image = UIImage(systemName: "person.crop.circle.badge.xmark")
                iv2.tintColor = primary
                self.requestButton.removeTarget(self, action: #selector(self.request), for: .touchUpInside)
                self.requestButton.addTarget(self, action: #selector(self.cancelRequest), for: .touchUpInside)
                    
            }
        if (isRequesting == 4) {
            lb2.text = "Accept"
            iv2.image = UIImage(systemName: "person.fill.checkmark")
            iv2.tintColor = primary
            //self.requestButton.setTitle("Accept", for: .normal)
            self.requestButton.removeTarget(self, action: #selector(self.request), for: .touchUpInside)
            self.requestButton.addTarget(self, action: #selector(self.accept), for: .touchUpInside)
            lb3.text = "Reject"
            iv3.image = UIImage(systemName: "person.fill.xmark")
            iv3.tintColor = primary
            self.reportButton.removeTarget(self, action: #selector(self.report), for: .touchUpInside)
            self.reportButton.addTarget(self, action: #selector(self.reject), for: .touchUpInside)
                
        }
        if (isRequesting == 5) {
            self.requestButton.isHidden = true
            //self.blockButton.setTitle("unblock", for: .normal)
            lb.text = "unblock"
            iv.image = UIImage(systemName: "lock.open")
            iv.tintColor = primary
            self.blockButton.removeTarget(self, action: #selector(self.block), for: .touchUpInside)
            self.blockButton.addTarget(self, action: #selector(self.unblock), for: .touchUpInside)
        }
        
        if (isRequesting == 6) {
            self.requestButton.isHidden = true
            self.newButton.isHidden = false
        }
            
        alertView.backgroundColor = secondary
        alertLabel.textColor = primary
        alertLabel.backgroundColor = .clear
        alertLabel.font = fontMetrics.scaledFont(for: secFont)
        alertButton.setTitleColor(primary, for: .normal)
        alertButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        alertView.frame = CGRect(x: 30, y: 350, width: view.width-60, height: 100)
        alertLabel.frame = CGRect(x: 20, y: 10, width: alertView.width-40, height: alertView.height-20)
        alertButton.frame = CGRect(x: alertView.width - 40, y: 20, width: 20, height: 20)
        setup()
    }
    
    @objc func request() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        guard !(email == "demo-mode") else {
            let alert = UIAlertController(title: "Notification", message: "Please register in order to use this feature", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        spinner.show(in: view)
        DatabaseManager.shared.requestUser(otherEmail: otherEmail) { (fail) in
            switch fail {
            case .success(_):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "You have successfully requested to start a conversation.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .failure(let error):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "Failed requesting: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func unblock() {
        spinner.show(in: view)
        DatabaseManager.shared.removeBlock(otherEmail: otherEmail, completion: {(success) in
            switch success {
            case .success(_):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "You have Unblocked this User", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .failure(let error):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "Failed unblocking this use: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    @objc func block() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        guard !(email == "demo-mode") else {
            let alert = UIAlertController(title: "Notification", message: "Please register in order to use this feature", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        spinner.show(in: view)
        DatabaseManager.shared.addBlock(otherEmail: otherEmail, completion: {(bool) in
            switch bool {
            case.success(_):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "You have Blocked this User", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            case .failure(let error):
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Notification", message: "Failed blocking this user: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        })
        DatabaseManager.shared.blockConversation(otherEmail: otherEmail) { success in
            if !success {
                print("failed to delete")
            }
        }
//        guard let users = UserDefaults.standard.value(forKey: "block") as? [String] else {
//            let newUsers:[String] = ["\(otherEmail)"]
//            UserDefaults.standard.setValue(newUsers, forKey: "block")
//            return
//        }
//        var newUser = users
//        if (!newUser.contains(otherEmail)) {
//        newUser.append(otherEmail)
//        UserDefaults.standard.setValue(newUser, forKey: "block")
//        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension Date {

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
}
