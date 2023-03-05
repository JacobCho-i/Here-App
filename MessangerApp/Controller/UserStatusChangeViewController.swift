//
//  UserStatusChangeViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/27/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseDatabase
import JGProgressHUD

class UserStatusChangeViewController: UIViewController {
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    private let spinner = JGProgressHUD(style: .dark)
    
    
    private var isNotEmpty = false
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let emailField: UITextView = {
        let field = UITextView()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.font = .systemFont(ofSize: 18, weight: .medium)
//        field.placeholder = "your status..."
//        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
//        field.leftViewMode = .always
        
        field.backgroundColor = .systemBackground
        return field
    }()
    private let registerButton: UIButton = {
       let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //emailField.delegate = self as? UITextFieldDelegate
        
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(registerButton)
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        view.backgroundColor = third
        emailField.frame = CGRect (x: 30,
                                   y: 30,
                                   width: scrollView.width-60,
                                   height: 250)
        registerButton.frame = CGRect (x: 30,
                                    y: emailField.height+45,
                                   width: scrollView.width-60,
                                   height: 52)
        registerButton.addTarget(self, action: #selector(editted), for: .touchUpInside)
        emailField.textColor = primary
        emailField.backgroundColor = .clear
        emailField.layer.borderColor = primary.cgColor
        registerButton.backgroundColor = primary
        registerButton.setTitleColor(third, for: .normal)
    }
    
    @objc func editted() {
        spinner.show(in: view)
        guard let status = emailField.text,
            !status.isEmpty else {
                DatabaseManager.shared.uploadStatus(status: " ", completion: { (success) in
                    switch success {
                    case .success(_):
                        self.spinner.dismiss()
                        ProfileUserViewController.userStatus = " "
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        let alert = UIAlertController(title: "Notification", message: "Failed editing bio: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                })
            return
        }
        let userStatus = emailField.text!
        DatabaseManager.shared.uploadStatus(status: userStatus, completion: { (success) in
            switch success {
            case .success(_):
                self.spinner.dismiss()
                ProfileUserViewController.userStatus = userStatus
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: "Notification", message: "Failed editing bio: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        })

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
