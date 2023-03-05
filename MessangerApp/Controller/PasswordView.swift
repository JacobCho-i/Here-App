//
//  PasswordView.swift
//  MessangerApp
//
//  Created by choi jun hyung on 7/3/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import GoogleSignIn

class PasswordView: UIViewController {
    //
    //  ChangeNameViewController.swift
    //  MessangerApp
    //
    //  Created by choi jun hyung on 4/20/21.
    //  Copyright © 2021 choi jun hyung. All rights reserved.
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)

    private let spinners = JGProgressHUD(style: .dark)
    
    private var otherEmail:String = String()
    private var isNotEmpty = false
    private var isOpening = false
    private var verPasscord: String = String()
    private var passcord:String = String()
    private var passwordType:String = "num4"
    private var tempModel: Conversation? = nil
    private var tempIndexpath: Int? = nil
    private var isReseting: Bool = Bool()
    private var isVerified: Bool = Bool()
    private var createsNewPassword: Bool = Bool()
    
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
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        return field
    }()

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
        field.backgroundColor = .clear
        return field
    }()
    
    private let button1: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("1", for: .normal)
        return button
    }()
    
    private let button2: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("2", for: .normal)
        return button
    }()
    
    private let button3: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("3", for: .normal)
        return button
    }()
    
    private let button4: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("4", for: .normal)
        return button
    }()
    
    private let button5: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("5", for: .normal)
        return button
    }()
    
    private let button6: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("6", for: .normal)
        return button
    }()
    
    private let button7: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("7", for: .normal)
        return button
    }()
    
    private let button8: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("8", for: .normal)
        return button
    }()
    
    private let button9: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("9", for: .normal)
        return button
    }()
    
    private let button0: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("0", for: .normal)
        return button
    }()
    
    private let backButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 37.5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitle("←", for: .normal)
        return button
    }()
    
    private let passcordlabel: UILabel = {
        let label = UILabel()
        label.text = "Enter a passcord"
        return label
    }()
    
    private let passcord1: UIView = {
        let field = UIView()
        field.layer.cornerRadius = 15
        field.layer.masksToBounds = true
        field.layer.borderWidth = 3
        return field
    }()
    
    private let passcord2: UIView = {
        let field = UIView()
        field.layer.cornerRadius = 15
        field.layer.masksToBounds = true
        field.layer.borderWidth = 3
        return field
    }()
    
    private let passcord3: UIView = {
        let field = UIView()
        field.layer.cornerRadius = 15
        field.layer.masksToBounds = true
        field.layer.borderWidth = 3
        return field
    }()
    
    private let passcord4: UIView = {
        let field = UIView()
        field.layer.cornerRadius = 15
        field.layer.masksToBounds = true
        field.layer.borderWidth = 3
        return field
    }()
    
    private let passcord5: UIView = {
        let field = UIView()
        field.layer.cornerRadius = 15
        field.layer.masksToBounds = true
        field.layer.borderWidth = 3
        return field
    }()
    
    private let passcord6: UIView = {
        let field = UIView()
        field.layer.cornerRadius = 15
        field.layer.masksToBounds = true
        field.layer.borderWidth = 3
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Verify", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        
    }
    
    private func reload() {
        if passwordType == "num4" {
            if passcord.count == 0 {
                passcord1.backgroundColor = .clear
                passcord2.backgroundColor = .clear
                passcord3.backgroundColor = .clear
                passcord4.backgroundColor = .clear
            }
            if passcord.count == 1 {
                passcord1.backgroundColor = third
            }
            if passcord.count == 2 {
                passcord1.backgroundColor = third
                passcord2.backgroundColor = third
            }
            if passcord.count == 3 {
                passcord1.backgroundColor = third
                passcord2.backgroundColor = third
                passcord3.backgroundColor = third
            }
            if passcord.count == 4 {
                passcord1.backgroundColor = third
                passcord2.backgroundColor = third
                passcord3.backgroundColor = third
                passcord4.backgroundColor = third
                passcordFull()
                
            }
            if passcord.count > 4 {
                
                passcord = ""
            }
        }
    }
    
    private func passcordFull() {
        if isOpening == false {
            
        if passcordlabel.text == "Enter a passcord" {
            if passwordType == "num4" {
            passcord1.backgroundColor = .clear
            passcord2.backgroundColor = .clear
            passcord3.backgroundColor = .clear
            passcord4.backgroundColor = .clear
            verPasscord = passcord
            passcord = ""
            passcordlabel.text = "Reenter a passcord"
                
            }
        } else if passcordlabel.text == "Reenter a passcord" {
            if passwordType == "num4" {
                passcord1.backgroundColor = .clear
                passcord2.backgroundColor = .clear
                passcord3.backgroundColor = .clear
                passcord4.backgroundColor = .clear
                if (verPasscord == passcord) {
                    print("passcord set, \(passcord)")
                    setpasscord(passcord: passcord)
                } else {
                    passcordlabel.text = "Enter a passcord"
                    print("not noice")
                }
                passcord = ""
                verPasscord = ""
                }
            }
        }
        if isOpening == true {
            if passwordType == "num4" {
            passcord1.backgroundColor = .clear
            passcord2.backgroundColor = .clear
            passcord3.backgroundColor = .clear
            passcord4.backgroundColor = .clear
            if (verPasscord == passcord) {
                self.navigationController?.popViewController(animated: false)
            } else {
                let alert = UIAlertController(title: "Notification", message: "Please enter a correct passcord", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                
                present(alert, animated: true)
            }
            passcord = ""
            print("this passcord \(verPasscord)")
            }
        }
        
    }
    
    @objc func verifyAndDelete() {
        passwordField.resignFirstResponder()
        guard let password = passwordField.text, !password.isEmpty else {
            return
        }
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let currentUser = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        print("aaaa")
        currentUser?.reauthenticate(with: credential, completion: { AuthResult, error in
            guard error == nil else {
                print(error.debugDescription)
                let alert = UIAlertController(title: "Notification", message: "Failed to Delete Account: \(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            self.spinners.show(in: self.view)
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
             DatabaseManager.shared.getUserID(email: safeEmail) { (id) in
                print("got id")
                 //log out fb
                 //log out google
                
                guard let user = Auth.auth().currentUser else {
                    print("no user")
                    return
                }
                print("signed out")
                            DatabaseManager.shared.deleteUserID(int: id, completion: {(result) in
                                switch (result) {
                                case .success:
                                    print("no error deleting user id")
                                    DatabaseManager.shared.deleteAppend(int: id, email: safeEmail, completion: {(result) in
                                        switch result {
                                        case .success:
                                            print("no error deleting append")
                                            user.delete(completion: { (error) in
                                                    guard error == nil else {
                                                        print(error.debugDescription)
                                                        DispatchQueue.main.async {
                                                            self.spinners.dismiss()
                                                            self.passwordField.text = ""
                                                        }
                                                        print("no error deleting")
                                                        return
                                                    }
                                                GIDSignIn.sharedInstance.signOut()
                                                    do {
                                                        try
                                                            Auth.auth().signOut()
                                                        print("signed")
                                                    }
                                                    catch {
                                                        print("Failed to log out")
                                                    }
                                                    DispatchQueue.main.async {
                                                        self.spinners.dismiss()
                                                    }
                                                    UserDefaults.standard.setValue(nil, forKey: "email")
                                                    UserDefaults.standard.setValue(nil, forKey: "name")
                                                    UserDefaults.standard.setValue("pink", forKey: "theme")
                                                    UserDefaults.standard.setValue(nil, forKey: "block")
                                                self.navigationController?.popViewController(animated: false)
                                                    let vc = LoginViewController()
                                                    let nav = UINavigationController(rootViewController: vc)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    self.present(nav, animated: true)
                                                    return
                                            })
                                            
                                        case .failure(let error):
                                            print("we errored")
                                            let alert = UIAlertController(title: "Notification", message: "Failed deleting this account: \(error.localizedDescription)", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                                        }
                                    })
                                case .failure(let error):
                                    print("errored")
                                    let alert = UIAlertController(title: "Notification", message: "Failed deleting this account: \(error.localizedDescription)", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                                }
                            })
            }
        })
    }
    
    @objc func verifyAndCreate() {
        passwordField.resignFirstResponder()
        
        spinners.show(in: view)
        guard let password = passwordField.text, !password.isEmpty else {
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
            currentUser.updatePassword(to: password, completion: { error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                print("that trued")
                UserDefaults.standard.setValue(true, forKey: "setPassword")
                self.spinners.dismiss()
                self.navigationController?.dismiss(animated: true)
            })
        
        
    }
    
    @objc func verify() {
        passwordField.resignFirstResponder()
        guard let password = passwordField.text, !password.isEmpty else {
            return
        }
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let currentUser = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        print("aaaa")
        currentUser?.reauthenticate(with: credential, completion: { AuthResult, error in
            guard error == nil else {
                return
            }
            self.passcordlabel.text = "Enter a passcord"
            self.passwordField.isHidden = true
            self.loginButton.isHidden = true
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button5.isHidden = false
            self.button6.isHidden = false
            self.button7.isHidden = false
            self.button8.isHidden = false
            self.button9.isHidden = false
            self.button0.isHidden = false
            self.backButton.isHidden = false
            self.passcord1.isHidden = false
            self.passcord2.isHidden = false
            self.passcord3.isHidden = false
            self.passcord4.isHidden = false
        })
        
    }
    
    private func setpasscord(passcord: String) {
        DatabaseManager.shared.setPasscord(otherEmail: otherEmail, passcord: passcord, completion: {(fail) in
            switch fail{
            case .success(_):
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: "Notification", message: "Failed to set or change the passcord: \(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        })
        
        print("error")
    }
    
    
    init(email: String, opening:Bool, passcord:String, reset: Bool, create: Bool) {
        self.otherEmail = email
        self.isOpening = opening
        self.verPasscord = passcord
        self.isReseting = reset
        self.createsNewPassword = create
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func button1tapped() {
        passcord += "1"
        reload()
    }
    @objc func button2tapped() {
        passcord += "2"
        reload()
    }
    @objc func button3tapped() {
        passcord += "3"
        reload()
    }
    @objc func button4tapped() {
        passcord += "4"
        reload()
    }
    @objc func button5tapped() {
        passcord += "5"
        reload()
    }
    @objc func button6tapped() {
        passcord += "6"
        reload()
    }
    @objc func button7tapped() {
        passcord += "7"
        reload()
    }
    @objc func button8tapped() {
        passcord += "8"
        reload()
    }
    @objc func button9tapped() {
        passcord += "9"
        reload()
    }
    @objc func button0tapped() {
        passcord += "0"
        reload()
    }
    @objc func backButtonTap() {
        passcord = ""
        reload()
    }
    
    func openConversation(_ model: Conversation, indexpath: Int){
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id, passcord:nil)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        DatabaseManager.shared.userRead(indexpath: indexpath)
        navigationController?.pushViewController(vc, animated: true)
        DatabaseManager.shared.addIndex(indexPath: indexpath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        passcordlabel.textColor = primary
        let font = UIFont(name: "Symbol", size: 20)!
        let fontMetrics = UIFontMetrics(forTextStyle: .title1)
        passcordlabel.font = fontMetrics.scaledFont(for: font)
        emailField.delegate = self as? UITextFieldDelegate
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(scrollView)
        loginButton.addTarget(self, action: #selector(verify), for: .touchUpInside)
//        scrollView.addSubview(emailField)
//        scrollView.addSubview(emailField2)
        passwordField.isHidden = true
        loginButton.isHidden = true
        if isReseting{
            passcordlabel.text = "Enter your password to verify"
            passwordField.isHidden = false
            loginButton.isHidden = false
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = true
            button4.isHidden = true
            button5.isHidden = true
            button6.isHidden = true
            button7.isHidden = true
            button8.isHidden = true
            button9.isHidden = true
            button0.isHidden = true
            backButton.isHidden = true
            passcord1.isHidden = true
            passcord2.isHidden = true
            passcord3.isHidden = true
            passcord4.isHidden = true
            if createsNewPassword {
                passcordlabel.text = "Create a password for this app"
                loginButton.setTitle("Set", for: .normal)
                loginButton.removeTarget(self, action: #selector(verify), for: .touchUpInside)
                loginButton.addTarget(self, action: #selector(verifyAndCreate), for: .touchUpInside)
            }
        } else {
            if createsNewPassword {
                passcordlabel.text = "Enter your password"
                passwordField.isHidden = false
                loginButton.isHidden = false
                button1.isHidden = true
                button2.isHidden = true
                button3.isHidden = true
                button4.isHidden = true
                button5.isHidden = true
                button6.isHidden = true
                button7.isHidden = true
                button8.isHidden = true
                button9.isHidden = true
                button0.isHidden = true
                backButton.isHidden = true
                passcord1.isHidden = true
                passcord2.isHidden = true
                passcord3.isHidden = true
                passcord4.isHidden = true
                passwordField.textColor = primary
                passwordField.attributedPlaceholder = NSAttributedString(string: "Password...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
                loginButton.setTitle("Delete Account", for: .normal)
                loginButton.removeTarget(self, action: #selector(verify), for: .touchUpInside)
                loginButton.addTarget(self, action: #selector(verifyAndDelete), for: .touchUpInside)
            }
        }
        
        if createsNewPassword {
            
        }
        
        scrollView.addSubview(button1)
        scrollView.addSubview(button2)
        scrollView.addSubview(button3)
        scrollView.addSubview(button4)
        scrollView.addSubview(button5)
        scrollView.addSubview(button6)
        scrollView.addSubview(button7)
        scrollView.addSubview(button8)
        scrollView.addSubview(button9)
        scrollView.addSubview(button0)
        scrollView.addSubview(backButton)
        
        scrollView.addSubview(passcord1)
        scrollView.addSubview(passcord2)
        scrollView.addSubview(passcord3)
        scrollView.addSubview(passcord4)
        
        scrollView.addSubview(passcordlabel)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        button1.addTarget(self, action: #selector(button1tapped), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2tapped), for: .touchUpInside)
        button3.addTarget(self, action: #selector(button3tapped), for: .touchUpInside)
        button4.addTarget(self, action: #selector(button4tapped), for: .touchUpInside)
        button5.addTarget(self, action: #selector(button5tapped), for: .touchUpInside)
        button6.addTarget(self, action: #selector(button6tapped), for: .touchUpInside)
        button7.addTarget(self, action: #selector(button7tapped), for: .touchUpInside)
        button8.addTarget(self, action: #selector(button8tapped), for: .touchUpInside)
        button9.addTarget(self, action: #selector(button9tapped), for: .touchUpInside)
        button0.addTarget(self, action: #selector(button0tapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        view.backgroundColor = secondary
        //if isNotEmpty {
        
        //}
    }
    
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
            textcolor = UIColor(named: "mainThemeText")!
           } else {
               primary = UIColor(named: "whiteThemePrimary")!
               secondary = UIColor(named: "whiteThemeSecondary")!
               //third = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
               third = UIColor(named: "whiteThemeBackgroundColor")!
           }
       }
    
    
    
    func alertError() {
        let alert = UIAlertController(title: "Notification", message: "Please fill all of following information.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
//        emailField.frame = CGRect (x: 30,
//                                   y: 30,
//                                   width: scrollView.width-60,
//                                   height: 52)
//        emailField2.frame = CGRect (x: 30,
//                                    y: emailField.height+45,
//                                    width: scrollView.width-60,
//                                    height: 52)
        button1.backgroundColor = third
        passwordField.layer.borderColor = primary.cgColor
        loginButton.backgroundColor = primary
        button1.setTitleColor(primary, for: .normal)
        button1.frame = CGRect(x: 45, y: 280, width: 75, height: 75)
        button2.backgroundColor = third
        button2.setTitleColor(primary, for: .normal)
        button2.frame = CGRect(x: view.width/2 - 37.5, y: 280, width: 75, height: 75)
        button3.backgroundColor = third
        button3.setTitleColor(primary, for: .normal)
        button3.frame = CGRect(x: view.width-120, y: 280, width: 75, height: 75)
        button4.backgroundColor = third
        button4.setTitleColor(primary, for: .normal)
        button4.frame = CGRect(x: 45, y: button1.top + 120, width: 75, height: 75)
        button5.backgroundColor = third
        button5.setTitleColor(primary, for: .normal)
        button5.frame = CGRect(x: view.width/2 - 37.5, y: button1.top + 120, width: 75, height: 75)
        button6.backgroundColor = third
        button6.setTitleColor(primary, for: .normal)
        button6.frame = CGRect(x: view.width-120, y: button1.top + 120, width: 75, height: 75)
        button7.backgroundColor = third
        button7.setTitleColor(primary, for: .normal)
        button7.frame = CGRect(x: 45, y: button4.top + 120, width: 75, height: 75)
        button8.backgroundColor = third
        button8.setTitleColor(primary, for: .normal)
        button8.frame = CGRect(x: view.width/2 - 37.5, y: button4.top + 120, width: 75, height: 75)
        button9.backgroundColor = third
        button9.setTitleColor(primary, for: .normal)
        button9.frame = CGRect(x: view.width-120, y: button4.top + 120, width: 75, height: 75)
        button0.backgroundColor = third
        button0.setTitleColor(primary, for: .normal)
        button0.frame = CGRect(x: view.width/2 - 37.5, y: button7.top + 120, width: 75, height: 75)
        backButton.backgroundColor = third
        backButton.setTitleColor(primary, for: .normal)
        backButton.frame = CGRect(x: view.width-120, y: button7.top + 120, width: 75, height: 75)
        passcord1.layer.borderColor = third.cgColor
        passcord2.layer.borderColor = third.cgColor
        passcord3.layer.borderColor = third.cgColor
        passcord4.layer.borderColor = third.cgColor
        passcord5.layer.borderColor = third.cgColor
        passcord6.layer.borderColor = third.cgColor
        
        passcordlabel.frame = CGRect(x: 30, y: 60, width: view.width - 60, height: 30)
        passcordlabel.textAlignment = .center
        
        passwordField.frame = CGRect(x: 30,
                                     y: passcordlabel.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        loginButton.frame = CGRect (x: 30,
                                    y: passwordField.bottom+10,
                                    width: scrollView.width-60,
                                    height: 52)
        
        if self.passwordType == "num4" {
        passcord1.frame = CGRect(x: view.width/2 - 105, y: 120, width: 30, height: 30)
        passcord2.frame = CGRect(x: view.width/2 - 45, y: 120, width: 30, height: 30)
        passcord3.frame = CGRect(x: view.width/2 + 15, y: 120, width: 30, height: 30)
        passcord4.frame = CGRect(x: view.width/2 + 75, y: 120, width: 30, height: 30)
        }
    }
}


