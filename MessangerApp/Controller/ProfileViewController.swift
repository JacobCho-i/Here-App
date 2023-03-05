//
//  ProfileViewController.swift
//  Messanger
//
//  Created by choi jun hyung on 7/7/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage
import MessageKit



final class ProfileViewController: UIViewController {
    
    public static let shared = ProfileViewController()
    
    public var nameChange = false
    static var needToChange = false
    @IBOutlet var tableView: UITableView!
    var data = [ProfileViewModel]()
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = third
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        self.navigationController?.tabBarController?.tabBar.tintColor = primary
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name:",
        handler: nil))
        
        
        data.append(ProfileViewModel(viewModelType: .name,
                                     title: "\(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",
                                     handler: {
                
                let vc = ChangeNameViewController()
                vc.title = "Change Your Name"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        
        
        ))
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email:",handler: nil))
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        if email.hasPrefix("demo@here.net") {
            data.append(ProfileViewModel(viewModelType: .email,
                                         title: "Demo-mode",
                                         handler: nil))
        } else {
        data.append(ProfileViewModel(viewModelType: .email,
                                     title: "\(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")",
                                     handler: nil))
        }
//        data.append(ProfileViewModel(viewModelType: .info,
//        title: " ",handler: nil))
//        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out",  handler: {
//
//
//               }))
        tableView.register(UITableViewCell.self,
                        forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        let view = UIView()
        view.backgroundColor = third
        tableView.tableFooterView = view
        tableView.separatorColor = UIColor.clear
        //tableView.rowHeight = 40
        tableView.backgroundColor = third
        self.navigationController?.navigationBar.barTintColor = secondary
        self.navigationController?.navigationBar.backgroundColor = .clear
        //navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        updateNameLabel()
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

    private func validatePassword() {
        guard let password = UserDefaults.standard.value(forKey: "setPassword") as? Bool else {
            print("noval")
            return
        }
        if !password {
//            let vc = PasswordView(email: "", opening: false, passcord: "", reset: true, create: true)
//            vc.title = "Set Password"
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true)
            let alert = UIAlertController(title: "Notification", message: "Password is required in order to use some features in this app. Please set a password for this app by using 'change password' feature in the setting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
                UserDefaults.standard.setValue(true, forKey: "setPassword")
            }))
        self.present(alert, animated: true)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        
        validatePassword()
        self.navigationController?.navigationBar.isHidden = false
        //tableView.reloadData()
        self.navigationController?.navigationBar.tintColor = primary
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        self.navigationController?.tabBarController?.tabBar.tintColor = primary
        self.navigationController?.tabBarController?.tabBar.backgroundColor = third
        self.navigationController?.tabBarController?.tabBar.unselectedItemTintColor = secondary
        view.backgroundColor = third
        
        tableView.tableHeaderView = createTableHeader()
            updateNameLabel()
            updateEmailLabel()
        let im = UIImage(systemName: "person.crop.circle")
        let button = UIBarButtonItem(image: im, style: .done, target: self, action: #selector(openProfile))
        button.tintColor = primary
        self.navigationItem.leftBarButtonItem = button
        let im1 = UIImage(systemName: "gearshape.fill")
        let rightButton = UIBarButtonItem(image: im1, style: .done, target: self, action: #selector(presentSetting))
        rightButton.tintColor = primary
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func openProfile() {
        let username = UserDefaults.standard.value(forKey: "name") as? String ?? "no name"
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        if !(email == "demo-mode") {
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let path = "images/\(safeEmail)_profile_picture.png"
        DatabaseManager.shared.getStatus(email: email) { (userStatus) in
            
            let vc = ProfileUserViewController(with: username, status: userStatus, path: path, isMine: true, email: safeEmail, request: 1, passcord: false)
                vc.navigationController?.navigationBar.backgroundColor = .clear
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = ProfileUserViewController(with: "Demo user", status: "", path: "", isMine: true, email: "demo-here-net", request: 1, passcord: false)
                vc.navigationController?.navigationBar.backgroundColor = .clear
                self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func presentSetting() {
        let vc = SettingTableViewController()
        vc.title = "Setting"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = secondary
        
        let imageView = UIImageView(frame: CGRect(x: (view.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = third
        imageView.layer.borderColor = third.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        
        //error
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                let image = UIImage(systemName: "person.circle")
                imageView.image = image
                imageView.tintColor = self.primary
                //here
                print("Failed to get download url: \(error)")
            }
        })
        headerView.addSubview(imageView)
        return headerView
    }
    
    func newTableHeader(with image: UIImage) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = secondary
        let imageView = UIImageView(frame: CGRect(x: (view.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = third
        imageView.layer.borderColor = third.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        imageView.image = image
        headerView.addSubview(imageView)
        return headerView
    }
    
    func updateNameLabel() {
        //tableView?.reloadData()
//        if (data.count > 1 && data[1].viewModelType == .name) {
        print("\(data.count)")
        data.remove(at: 1)
        guard let name = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        if name == " " {
            let newData = ProfileViewModel(viewModelType: .name,
                                         title: "Set your name here",
                handler: {
                    
                    let vc = ChangeNameViewController()
                    vc.title = "Change Your Name"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            
            
            )
            data.insert(newData, at: 1)
                tableView.reloadRows(at: [(NSIndexPath(row: 1, section: 0) as IndexPath)], with: .automatic)
        } else {
        let newData = ProfileViewModel(viewModelType: .name,
                                     title: "\(UserDefaults.standard.value(forKey: "name") as? String ?? " ")",
            handler: {
                
                let vc = ChangeNameViewController()
                vc.title = "Change Your Name"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        
        
        )
        data.insert(newData, at: 1)
            tableView.reloadRows(at: [(NSIndexPath(row: 1, section: 0) as IndexPath)], with: .automatic)
            
        }
    }
    
    func updateEmailLabel() {
//        if (data.count > 3 && data[3].viewModelType == .email) {
        
        data.remove(at: 3)
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        if email.hasPrefix("demo@here.net") {
            let newData = (ProfileViewModel(viewModelType: .email,
                                         title: "Demo-mode",
                                         handler: nil))
            data.insert(newData, at: 3)
            tableView.reloadRows(at: [(NSIndexPath(row: 3, section: 0) as IndexPath)], with: .automatic)
        } else {
        let newData = (ProfileViewModel(viewModelType: .email,
                                     title: "\(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")",
                                     handler: nil))
            data.insert(newData, at: 3)
            tableView.reloadRows(at: [(NSIndexPath(row: 3, section: 0) as IndexPath)], with: .automatic)
            
            }
        }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier,
                                                 for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: data[indexPath.row])
        let uiv = UIView()
        uiv.backgroundColor = secondary
        cell.selectedBackgroundView = uiv
        //cell.textLabel?.font = UIFont(name: "Avenir", size: 20)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}

class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    public func setUp(with viewmodel: ProfileViewModel) {
        
        self.textLabel?.text = viewmodel.title
        setColor()
        switch viewmodel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
            let font = UIFont(name: "Avenir", size: 20)!
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            textLabel?.font = fontMetrics.scaledFont(for: font)
            textLabel?.adjustsFontForContentSizeCategory = true
            textLabel?.adjustsFontSizeToFitWidth = true
            textLabel?.textColor = textcolor
            self.backgroundColor = third
        case .section:
            //textLabel?.backgroundColor = .systemGray6
            self.backgroundColor = secondary
        case .logout:
            textLabel?.backgroundColor = secondary
            textLabel?.textColor = primary
            textLabel?.textAlignment = .center
            self.backgroundColor = third
        case .email:
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
            //problem?
            let underlineAttributedString = NSMutableAttributedString(string: textLabel!.text!, attributes: underlineAttribute)
            let color = [NSAttributedString.Key.underlineColor: primary]
            let range = NSMakeRange(0, underlineAttributedString.length)
            underlineAttributedString.addAttributes(color, range: range)
            textLabel?.attributedText = underlineAttributedString
            textLabel?.textAlignment = .left
            textLabel?.textColor = primary
            textLabel?.isAccessibilityElement = true
            let font = UIFont(name: "Avenir", size: 20)!
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            textLabel?.font = fontMetrics.scaledFont(for: font)
            textLabel?.adjustsFontForContentSizeCategory = true
            self.backgroundColor = third
        case .setting:
            textLabel?.textAlignment = .left
            textLabel?.textColor = primary
            let font = UIFont(name: "Avenir", size: 20)!
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            textLabel?.font = fontMetrics.scaledFont(for: font)
            textLabel?.adjustsFontForContentSizeCategory = true
            self.backgroundColor = third
        case .content:
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
            //problem?
            let underlineAttributedString = NSMutableAttributedString(string: textLabel!.text!, attributes: underlineAttribute)
            let color = [NSAttributedString.Key.underlineColor: UIColor.systemGray6]
            let range = NSMakeRange(0, underlineAttributedString.length)
            underlineAttributedString.addAttributes(color, range: range)
            textLabel?.attributedText = underlineAttributedString
            textLabel?.textAlignment = .left
            textLabel?.font = UIFont(name: "Avenir", size: 20)
        case .name:
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
            //problem?
            let underlineAttributedString = NSMutableAttributedString(string: textLabel!.text!, attributes: underlineAttribute)
            let color = [NSAttributedString.Key.underlineColor: primary]
            let range = NSMakeRange(0, underlineAttributedString.length)
            underlineAttributedString.addAttributes(color, range: range)
            textLabel?.textColor = primary
            //textLabel?.adjustsFontForContentSizeCategory = true
            textLabel?.isAccessibilityElement = true
            textLabel?.attributedText = underlineAttributedString
            textLabel?.textAlignment = .left
            let font = UIFont(name: "Avenir", size: 20)!
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            textLabel?.font = fontMetrics.scaledFont(for: font)
            textLabel?.adjustsFontForContentSizeCategory = true
            self.backgroundColor = third
        }
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
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            let image = selectedImage.pngData()!
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
                return
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            let fileName = "\(safeEmail)_profile_picture.png"
            
            StorageManager.shared.uploadProfilePicture(with: image, fileName: fileName, completion: { result in
                switch result {
                case.success(let downloadUrl):
                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                    print(downloadUrl)
                case .failure(let error) :
                    print("Storage manager error: \(error)")
                }
            })
            //self.imageView.image = selectedImage
            tableView.tableHeaderView = newTableHeader(with: selectedImage)
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
            
        }
        
    }

