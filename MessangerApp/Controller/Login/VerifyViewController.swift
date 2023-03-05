//
//  VerifyViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 7/5/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerifyViewController: UIViewController {
    
    private var isRegistering: Bool = Bool()
    
    private let verifyLabel: UILabel = {
        let field = UILabel()
        return field
    }()
    
    private let orLabel: UILabel = {
        let field = UILabel()
        return field
    }()
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    private func setColor() {
        guard let theme = UserDefaults.standard.value(forKey: "theme") as? String else {
            primary = UIColor(named: "whiteThemePrimary")!
            secondary = UIColor(named: "whiteThemeSecondary")!
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Agree", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let resend: UIButton = {
        let button = UIButton()
        button.setTitle("Send Verification Email", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let logOut: UIButton = {
        let button = UIButton()
        button.setTitle("log Out", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(registering: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isRegistering = registering
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        view.backgroundColor = third
        if isRegistering {
            resend.isHidden = true
            verifyLabel.isHidden = true
            orLabel.isHidden = true
            logOut.isHidden = true
            
        } else {
            registerButton.isHidden = true
        }
        resend.backgroundColor = secondary
        logOut.backgroundColor = primary
        resend.setTitleColor(primary, for: .normal)
        logOut.setTitleColor(.white, for: .normal)
        verifyLabel.textColor = textcolor
        orLabel.textColor = textcolor
        orLabel.text = "or"
        orLabel.textAlignment = .center
        navigationController?.navigationBar.barTintColor = third
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        navigationController?.tabBarController?.tabBar.tintColor = primary
        navigationController?.tabBarController?.tabBar.barTintColor = third
        navigationController?.tabBarController?.tabBar.unselectedItemTintColor = secondary
            view.addSubview(registerButton)
            view.addSubview(resend)
            view.addSubview(verifyLabel)
            view.addSubview(orLabel)
            view.addSubview(logOut)
            let image = UIImage(systemName: "arrow.clockwise")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(reload))
        navigationItem.rightBarButtonItem?.tintColor = primary
            
            // Do any additional setup after loading the view.
        
    }
    
    @objc func reload() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        user.reload { (error) in
            switch user.isEmailVerified {
            case true:
                self.navigationController?.dismiss(animated: true, completion: nil)
                
            case false:
                let alert = UIAlertController(title: "Notification", message: "Your email is not verified yet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
        
    override func viewDidLayoutSubviews() {
        registerButton.frame = CGRect(x: 50, y: view.height-100, width: 300, height: 50)
        resend.frame = CGRect(x: view.width/2-150, y: 200, width: 300, height: 50)
        verifyLabel.text = "Please Verify Your Email First"
        verifyLabel.textColor = textcolor
        verifyLabel.frame = CGRect(x: view.width/2-150, y: 100, width: 300, height: 50)
        orLabel.frame = CGRect(x: view.width/2-150, y: 265, width: 300, height: 20)
        logOut.frame = CGRect(x: view.width/2-150, y: 300, width: 300, height: 50)
        verifyLabel.textAlignment = .center
            registerButton.addTarget(self, action: #selector(agreeAndRegister), for: .touchUpInside)
            logOut.addTarget(self, action: #selector(logout), for: .touchUpInside)
            resend.addTarget(self, action: #selector(verificationEmailSend), for: .touchUpInside)
        }
        
        @objc func agreeAndRegister() {
            print("good")
            registerButton.isHidden = true
            resend.isHidden = false
            verifyLabel.isHidden = false
            orLabel.isHidden = false
            logOut.isHidden = false
            
        }
        
        @objc func verificationEmailSend() {
            guard let user = Auth.auth().currentUser else {
                return
            }
            user.sendEmailVerification { (error) in
                guard let error = error else {
                    let alert = UIAlertController(title: "Notification", message: "Verification email sent. Please check your email.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                return print("user varification email sent")
            }
            self.handleError(error: error)
        }
    }
    
    func handleError(error: Error) {
        
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
    
    @objc func logout() {
        let actionSheet = UIAlertController(title: "Log out",
                                            message: "Do you want to log out?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                
                                                guard let sself = self else {
                                                    return
                                                }
                                                    
                                                UserDefaults.standard.setValue(nil, forKey: "email")
                                                UserDefaults.standard.setValue(nil, forKey: "name")
                                                UserDefaults.standard.setValue("pink", forKey: "theme")
                                                UserDefaults.standard.setValue(nil, forKey: "block")
                                                //log out fb
                                                
                                                do {
                                                    try FirebaseAuth.Auth.auth().signOut()
                                                    
                                                    let vc = LoginViewController()
                                                    let nav = UINavigationController(rootViewController: vc)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    sself.present(nav, animated: true)
                                                    
                                                }
                                                catch {
                                                    print("Failed to log out")
                                                }
                                                
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        self.present(actionSheet, animated: true)
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
