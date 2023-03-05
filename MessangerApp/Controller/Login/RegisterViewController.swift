//
//  RegisterViewController.swift
//  Messanger
//
//  Created by choi jun hyung on 7/7/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class RegisterViewController: UIViewController {
    
        var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
        var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
        var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
        var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
        private let spinner = JGProgressHUD(style: .dark)

        private let scrollView: UIScrollView = {
           let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
        }()
        private let firstNameField: UITextField = {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.placeholder = "first name..."
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            field.leftViewMode = .always
            return field
           }()
            
        private let lastNameField: UITextField = {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
            field.placeholder = "last name..."
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            field.leftViewMode = .always
            return field
            }()
            
        private let emailField: UITextField = {
            let field = UITextField()
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .continue
            field.layer.cornerRadius = 12
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
            field.placeholder = "Password..."
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            field.leftViewMode = .always
            field.isSecureTextEntry = true
            return field
        }()
        
    private let passwordConfirmField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.placeholder = "Confirm Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        return field
    }()
    
    private let agreeLabel: UITextView = {
        let field = UITextView()
        return field
    }()
    
        private let registerButton: UIButton = {
           let button = UIButton()
            button.setTitle("Agree and Continue", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            
            return button
        }()
        
        private let imageView : UIImageView = {
            let imageView = UIImageView()
            
            //change logo here
            imageView.image = UIImage(systemName: "person.circle")
            imageView.contentMode = .scaleAspectFit
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            return imageView
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            setColor()
            view.backgroundColor = third
            let att1 = NSAttributedString(string: "First Name...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
            let att2 = NSAttributedString(string: "Last Name...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
            let att3 = NSAttributedString(string: "Email Address...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
            let att4 = NSAttributedString(string: "Password...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
            let att5 = NSAttributedString(string: "Confirm Password...", attributes: [NSAttributedString.Key.foregroundColor: textcolor])
            firstNameField.attributedPlaceholder = att1
            lastNameField.attributedPlaceholder = att2
            emailField.attributedPlaceholder = att3
            passwordField.attributedPlaceholder = att4
            passwordConfirmField.attributedPlaceholder = att5
            
            
            
            let url1 = URL(string: "https://hereapp.org/terms-of-service")
            let url2 = URL(string: "https://hereapp.org/privacy-policy")
            let attributedStr = NSMutableAttributedString(string: "By registering, you are agreeing to our Terms of Service and Privacy Policy")
            attributedStr.setAttributes([.link: url1!], range: NSMakeRange(40, 16))
            attributedStr.setAttributes([.link: url2!], range: NSMakeRange(60, 15))
            attributedStr.setAttributes([NSAttributedString.Key.foregroundColor: textcolor], range: NSMakeRange(0, 40))
            attributedStr.setAttributes([NSAttributedString.Key.foregroundColor: textcolor], range: NSMakeRange(56, 4))
            agreeLabel.attributedText = attributedStr
            agreeLabel.isUserInteractionEnabled = true
            agreeLabel.isEditable = false
            agreeLabel.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
            agreeLabel.backgroundColor = .clear
            
            let font = UIFont(name: "Symbol", size: 16)!
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            agreeLabel.font = fontMetrics.scaledFont(for: font)
            
            
            firstNameField.textColor = primary
            lastNameField.textColor = primary
            emailField.textColor = primary
            passwordField.textColor = primary
            passwordConfirmField.textColor = primary
            registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
            emailField.delegate = self
            passwordField.delegate = self
            // add subviews
            imageView.tintColor = primary
            imageView.layer.borderColor = primary.cgColor
            view.addSubview(scrollView)
            scrollView.addSubview(imageView)
            scrollView.addSubview(firstNameField)
            scrollView.addSubview(lastNameField)
            scrollView.addSubview(emailField)
            scrollView.addSubview(passwordField)
            scrollView.addSubview(registerButton)
            scrollView.addSubview(agreeLabel)
            scrollView.addSubview(passwordConfirmField)
            firstNameField.backgroundColor = .clear
            firstNameField.layer.borderColor = primary.cgColor
            lastNameField.backgroundColor = .clear
            lastNameField.layer.borderColor = primary.cgColor
            emailField.backgroundColor = .clear
            emailField.layer.borderColor = primary.cgColor
            passwordField.backgroundColor = .clear
            passwordField.layer.borderColor = primary.cgColor
            registerButton.backgroundColor = primary
            imageView.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
            
            imageView.addGestureRecognizer(gesture)
        }
    
        @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
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
            let size = scrollView.width/3
            
            imageView.frame = CGRect (x: (scrollView.width-size)/2,
                                      y: 20,
                                      width: size,
                                      height: size)
            
            imageView.layer.cornerRadius = imageView.width/2.0
            firstNameField.frame = CGRect (x: 30,
                                       y: imageView.bottom+10,
                                       width: scrollView.width-60,
                                       height: 52)
            lastNameField.frame = CGRect (x: 30,
                                       y: firstNameField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 52)
            emailField.frame = CGRect (x: 30,
                                       y: lastNameField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 52)
            passwordField.frame = CGRect (x: 30,
                                       y: emailField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 52)
            passwordConfirmField.frame = CGRect(x: 30,
                                        y: passwordField.bottom+10,
                                        width: scrollView.width-60,
                                        height: 52)
            agreeLabel.frame = CGRect (x: 30,
                                       y: passwordConfirmField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 50)
            registerButton.frame = CGRect (x: 30,
                                        y: agreeLabel.bottom+10,
                                        width: scrollView.width-60,
                                        height: 52)
            
            let underline = UIView()
            underline.frame = CGRect(x: view.width/2-(view.width-60)/2, y: firstNameField.bottom-10, width: view.width-60, height: 3.3)
            underline.layer.cornerRadius = 4
            underline.backgroundColor = primary
            scrollView.addSubview(underline)
            let underline2 = UIView()
            underline2.frame = CGRect(x: view.width/2-(view.width-60)/2, y: lastNameField.bottom-10, width: view.width-60, height: 3.3)
            underline2.layer.cornerRadius = 4
            underline2.backgroundColor = primary
            scrollView.addSubview(underline2)
            let underline3 = UIView()
            underline3.frame = CGRect(x: view.width/2-(view.width-60)/2, y: emailField.bottom-10, width: view.width-60, height: 3.3)
            underline3.layer.cornerRadius = 4
            underline3.backgroundColor = primary
            scrollView.addSubview(underline3)
            let underline4 = UIView()
            underline4.frame = CGRect(x: view.width/2-(view.width-60)/2, y: passwordField.bottom-10, width: view.width-60, height: 3.3)
            underline4.layer.cornerRadius = 4
            underline4.backgroundColor = primary
            scrollView.addSubview(underline4)
            let underline5 = UIView()
            underline5.frame = CGRect(x: view.width/2-(view.width-60)/2, y: passwordConfirmField.bottom-10, width: view.width-60, height: 3.3)
            underline5.layer.cornerRadius = 4
            underline5.backgroundColor = primary
            scrollView.addSubview(underline5)
        }
        
        @objc private func registerButtonTapped() {
            emailField.resignFirstResponder()
            passwordField.resignFirstResponder()
            firstNameField.resignFirstResponder()
            lastNameField.resignFirstResponder()
            
            guard let firstName = firstNameField.text,
                let lastName = lastNameField.text,
                let email = emailField.text,
                let password = passwordField.text,
                !email.isEmpty,
                !password.isEmpty,
                !firstName.isEmpty,
                !lastName.isEmpty,
                password.count >= 6 else {
                alertUserLoginError()
                return
            }
            guard let passwordConfirm = passwordConfirmField.text, password == passwordConfirm else {
                let alert = UIAlertController(title: "Notification", message: "Error while registering: Password doesn't match", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            let inappropriate_words = ["ass","4r5e","5h1t","5hit","a_s_s","ar5e","arrse","asshole","asswhole","b!tch","b00bs","b17ch","b1tch", "ballbag", "bastard","beastial","bellend","bestial","bi+ch","biatch","bitch","bloody","blow job","blowjob","boiolas","bollock","bollok","boner","boob","booobs","boooobs","booooobs","booooooobs","breasts","buceta","butthole","buttmuch","buttplug","c0ck","cock","carpet muncher","cawk","chink","cl1t","clit","coon","cunilingus","cunillingus","cunnilingus","cunt","cyalis","cyberfuc","d1ck","dick","dildo","dink","dirsa","dlck","doggin","donkeyribber","doosh","duche","dyke","ejaculate","ejaculating","ejaculation","ejakulate","f u c k","f4nny","f_u_c_k","fag","fanny","fanyy","fcuk","faggot","felching","fellate","fellatio","flange","fook","fuck","f*ck","fudge packer","fudgepacker","fux","gangbang","gaylord","goatse","heshe","hoar","hoer","horniest","horny","jack-off","jackoff","jerk-off","jism","kondum","kum","kunilingus","l3i+ch","l3itch","labia","m0f0","m0fo","m45terbate","ma5terb8","ma5terbate","master-bate","masterb8","masterbat*","masterbat3","masterbate","masterbation","masturbate","mo-fo","mof0","mofo","muff","mutha","muther","n1gga","n1gger","nazi","nigg3r","nigg4h","nigga","nigger","numbnuts","nutsack","orgasim","orgasm","p0rn","pecker","penis","phuck","phuk","phuq","pimpis","porn","prick","pron","pube","pusse","pussi","pussy","qnmlgb","rectum","retard","rimjaw","s hit","s.o.b.","s_h_i_t","schlong","screwing","scroat","scrote","scrotum","semen","sh!+","sh!t","sh1t","shemale","shit","skank","slut","smegma","snatch","spunk","t1tt1e5","t1tties","teets","teez","testical","testicle","tosser","tw4t","twat","twunt","v14gra","v1gra","vagina","viagra","vulva","w00se","wank","willies","xrated"]
            
            guard !inappropriate_words.contains(firstName), !inappropriate_words.contains(lastName) else {
                let alert = UIAlertController(title: "Notification", message: "Please avoid using inappropriate word in the name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                present(alert,animated: true)
                return
            }
            
            spinner.show(in: view)
            
            //Firebase Log In
//
            DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
                guard let strongSelf = self else {
                    return
                }

                

                guard !exists else {
                    // user already exists
                    strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists." )
                    return
                }

            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                  guard authResult != nil, error == nil else {
                    print("error creating user \(String(describing: error?.localizedDescription))")
                  return
                }

                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")

                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: {success in

                    switch success {
                    case .success(let bool):
                        if bool {
                        guard let image = strongSelf.imageView.image,
                            let data = image.pngData() else {
                                return
                        }
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case.success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                DispatchQueue.main.async {
                                    strongSelf.spinner.dismiss()
                                }
                                self?.navigationController?.dismiss(animated: true, completion: nil)
                                print(downloadUrl)

                            case .failure(let error) :
                                let alert = UIAlertController(title: "Notification", message: error.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                                strongSelf.present(alert, animated: true)
                            }
                        })
                        }
                    case .failure(let error):
                        let alert = UIAlertController(title: "Notification", message: "Failed registering: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                        self?.present(alert, animated: true)
                    }
                })
//                let vc = ConversationsViewController()
//                let nav = UINavigationController(rootViewController: vc)
//                strongSelf.present(nav, animated: true)
                
                })
            })
            
        }

    func alertUserLoginError(message: String = "Please enter all information and set the password at least 6 character in order to create a new account") {
            let alert = UIAlertController(title: "Woops",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
        @objc private func didTapRegister() {
            let vc = RegisterViewController()
            vc.title = "Create Account"
            navigationController?.pushViewController(vc, animated: true)
        }
     
    }

    extension RegisterViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            if textField == emailField {
                passwordField.becomeFirstResponder()
            }
            else if textField == passwordField {
                registerButtonTapped()
            }
            return true
        }
        
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "profile picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler:  { [weak self] _ in
                                                
                                                self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
                                                
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
