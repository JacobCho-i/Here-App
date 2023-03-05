//
//  ChangeNameViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 4/20/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseDatabase

var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)

private var isNotEmpty = false

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
    field.backgroundColor = .systemBackground
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
    field.backgroundColor = .systemBackground
    return field
}()

class ChangeNameViewController: UIViewController {

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
    
    override func viewDidLoad() {
        emailField.delegate = self as? UITextFieldDelegate
        setColor()
        
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(emailField2)
        emailField.tintColor = primary
        emailField2.tintColor = primary
        emailField.textColor = primary
        emailField2.textColor = primary
        emailField.backgroundColor = .clear
        emailField2.backgroundColor = .clear
        emailField.layer.borderColor = primary.cgColor
        emailField2.layer.borderColor = primary.cgColor
        let att1 = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
        emailField.attributedPlaceholder = att1
        let att2 = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
        emailField2.attributedPlaceholder = att2
        
        super.viewDidLoad()
        view.backgroundColor = third
        //if isNotEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change",
            style: .done,
            target: self,
            action: #selector(sendButtonTapped))
            
        //}
    }
    
    @objc func sendButtonTapped() {
        emailField.resignFirstResponder()
        emailField2.resignFirstResponder()
        
        guard let firstname = emailField.text, let lastname = emailField2.text, !firstname.isEmpty, !lastname.isEmpty else {
            alertError()
            return
        }
        let changedFirstName = emailField.text!
        let changedLastName = emailField2.text!
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        if email.hasPrefix("demo@here.net") {
                DatabaseManager.shared.changeUsername(safeEmail: safeEmail, firstName: changedFirstName, lastName: changedLastName, id: 1000, completion: {(result) in
                    switch (result) {
                    case .success:
                        self.navigationController?.popViewController(animated: true)
                        self.navigationController?.dismiss(animated: true)
                    case .failure(let error):
                        let alert = UIAlertController(title: "Notification", message: "failed to change username: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                    }
                })
            
        } else {
        DatabaseManager.shared.getUserID(email: safeEmail) { (id) in
            DatabaseManager.shared.changeUsername(safeEmail: safeEmail, firstName: changedFirstName, lastName: changedLastName, id: id, completion: {(result) in
                switch (result) {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.dismiss(animated: true)
                case .failure(let error):
                    let alert = UIAlertController(title: "Notification", message: "failed to change username: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    }
                })
            }
        }
        //DatabaseManager.shared.changeUserName(with: , changedfirstName: changedFirstName, changedlastName: changedLastName)
         
    }
    
    func alertError() {
        let alert = UIAlertController(title: "Notification", message: "Please fill all of following information.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        emailField.frame = CGRect (x: 30,
                                   y: 30,
                                   width: scrollView.width-60,
                                   height: 52)
        emailField2.frame = CGRect (x: 30,
                                    y: emailField.height+45,
                                   width: scrollView.width-60,
                                   height: 52)
        
    }
}


