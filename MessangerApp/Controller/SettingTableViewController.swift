//
//  SettingTableViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/29/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

class SettingTableViewController: UITableViewController {

    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    var index:Int = 0
    
    private let spinner = JGProgressHUD(style: .dark)
    
    
    private let settingLabel:[String] = ["Change Profile Picture", "Terms of Use", "Privacy Policy", "Contact Us" ,"Blocked Users", "Change Your Password", "Log Out","Delete this Account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        view.backgroundColor = secondary
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        tableView.sectionFooterHeight = 40
        
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0) {
            return 1
        }
        if (section == 1){
            return 3
        }
        if section == 2 {
            return 2
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        if (section == 0 || section == 1) {
            footerView.backgroundColor = secondary
        } else {
            footerView.backgroundColor = .clear
        }
        return footerView
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as! SettingTableViewCell
        cell.configure(text: settingLabel[index])
        index += 1
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0 && indexPath.section == 0) {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            guard !(email == "demo-mode") else {
                let alert = UIAlertController(title: "Notification", message: "Please register in order to use this feature", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                present(alert, animated: true)
                return
            }
            self.presentPhotoActionSheet()
        }
        if (indexPath.row == 2 && indexPath.section == 1) {
            guard let url = URL(string: "https://hereapp.org/contact-us") else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        //search, verify view, setpassword, default log in, color, log out
        if (indexPath.row == 0 && indexPath.section == 1) {
            guard let url = URL(string: "https://hereapp.org/terms-of-service") else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        if (indexPath.row == 1 && indexPath.section == 1) {
            guard let url = URL(string: "https://hereapp.org/privacy-policy") else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        if (indexPath.row == 0 && indexPath.section == 2) {
            let vc = BlockedUsersTableViewController()
            vc.title = "Blocked Users"
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if (indexPath.row == 1 && indexPath.section == 2) {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            guard !(email == "demo-mode") else {
                let alert = UIAlertController(title: "Notification", message: "Please register in order to use this feature", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                present(alert, animated: true)
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                guard error == nil else {
                    let alert = UIAlertController(title: "Notification", message: "Error sending an email: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                let alert = UIAlertController(title: "Notification", message: "Password Change email sent. Please Check your email.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
        if (indexPath.row == 0 && indexPath.section == 3) {
            let actionSheet = UIAlertController(title: "Log out",
                                      message: "Do you want to log out?",
                                      preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                      style: .destructive,
                                      handler: {_ in
                                        
                                        UserDefaults.standard.setValue(nil, forKey: "email")
                                        UserDefaults.standard.setValue(nil, forKey: "name")
                                        UserDefaults.standard.setValue("pink", forKey: "theme")
                                        UserDefaults.standard.setValue(nil, forKey: "block")
                                        UserDefaults.standard.setValue(nil, forKey: "demo")
                                        //log out fb
                                        
                                        //log out google
                                        GIDSignIn.sharedInstance.signOut()
                                        
                                        do {
                                            try FirebaseAuth.Auth.auth().signOut()
                                            
                                            let vc = LoginViewController()
                                            let nav = UINavigationController(rootViewController: vc)
                                            nav.modalPresentationStyle = .fullScreen
                                            self.present(nav, animated: true)
                                            
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
        if (indexPath.row == 1 && indexPath.section == 3) {
                
                let actionSheet = UIAlertController(title: "Delete your account",
                                          message: "Do you want to delete your account?",
                                          preferredStyle: .alert)
            
            actionSheet.addAction(UIAlertAction(title: "Delete",
                                          style: .destructive,
                                          handler: { [weak self] _ in
                                            
                                            guard let strongSelf = self else {
                                                return
                                            }
                                            let vc = PasswordView(email: "", opening: false, passcord: "", reset: false, create: true)
                                            vc.title = "Enter a password"
                                            strongSelf.navigationController?.pushViewController(vc, animated: true)
                                             
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .default,
                                                handler: nil))
            
                self.present(actionSheet, animated: true)
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
}
    
    extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
            
        }
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


