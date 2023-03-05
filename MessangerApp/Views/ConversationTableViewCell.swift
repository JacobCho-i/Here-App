//
//  ConversationTableViewCell.swift
//  MessangerApp
//
//  Created by choi jun hyung on 1/11/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import SDWebImage
import UserNotifications

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    var conv: Conversation? = nil
    var index: IndexPath? = nil

    private var passcordInt: Int = Int()
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let userNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    let newView: UIView = {
        let newView = UIView()
        newView.layer.borderWidth = 10
        newView.layer.cornerRadius = 35
        return newView
    }()
    
    let profileButton: UIButton = {
       let button = UIButton()
        let image = UIImage(systemName: "ellipsis.circle")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //button.backgroundColor = .red
        return button
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
        
    }()
    
    private let redDot: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        return imageView
    }()
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setColor()
        //contentView.addSubview(newView)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(redDot)
        contentView.addSubview(profileButton)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 20,
                                     y: 20,
                                     width: 80,
                                     height: 80)
        userNameLabel.frame = CGRect(x: userImageView.right + 120,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 120,
                                        y: userNameLabel.bottom,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height-20)/2)
        redDot.frame = CGRect (x: 15, y: 15, width: 15, height: 15)
        profileButton.frame = CGRect(x: contentView.width - 70, y: (contentView.height-50)/2, width: 50, height: 50)
        
    }
    
    public func userread() {
        self.redDot.isHidden = true
    }
    
    @objc func openProfile() {
        guard let model = conv else {
            return
        }
        guard let index = index else {
            return
        }
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        DatabaseManager.shared.getStatus(email: model.otherUserEmail) { (status) in
            DatabaseManager.shared.checkPasscord(index: "\(index.row)") { (hasPasscord) in
                DatabaseManager.shared.grabFullname(safeEmail: model.otherUserEmail) { nname in
                    if (hasPasscord) {
                        let vc = ProfileUserViewController(with: nname, status: status, path: path, isMine: false, email: model.otherUserEmail, request: 6, passcord: true)
                        vc.navigationController?.navigationBar.tintColor = self.third
                        vc.navigationItem.largeTitleDisplayMode = .never
                        vc.title = "User Profile"
                        print("this")
                        NotificationCenter.default.post(name: .loadProfile, object: nil, userInfo: ["vc": vc])
                    } else {
                        let vc = ProfileUserViewController(with: nname, status: status, path: path, isMine: false, email: model.otherUserEmail, request: 6, passcord: false)
                        vc.navigationController?.navigationBar.tintColor = self.third
                        vc.navigationItem.largeTitleDisplayMode = .never
                        vc.title = "User Profile"
                        print("that")
                        
                        NotificationCenter.default.post(name: .loadProfile, object: nil, userInfo: ["vc": vc])
                    }
                }
                
            }
            
        }
    }
    
    public func configure(with model: Conversation, indexpath: IndexPath) {
        let image = UIImage(systemName: "person.circle")
        image?.withTintColor(primary)
        conv = model
        index = indexpath
        self.userImageView.image = image
        clipsToBounds = true
        //contentView.backgroundColor = third
        backgroundColor = third
        profileButton.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        
        //let color = UIColor(displayP3Red: 255, green: 240, blue: 232, alpha: 1.0)
        let color = secondary
        contentView.layer.borderWidth = 10
        contentView.layer.borderColor = color.cgColor
        contentView.layer.cornerRadius = 35
        newView.backgroundColor = third
        newView.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height)
        newView.layer.borderColor = color.cgColor
        
        
        let otheruserEmail = model.otherUserEmail
        let safeEmail = DatabaseManager.safeEmail(emailAddress: otheruserEmail)
        DatabaseManager.shared.checkDelete(email: safeEmail) { deleted in
            if deleted {
                DatabaseManager.shared.grabUsername(safeEmail: safeEmail) { (firstNameString) in
                    DatabaseManager.shared.grabLast(safeEmail: safeEmail) { (lastNameString) in
                        self.userNameLabel.text = "deleted user"
                        self.userNameLabel.textColor = self.primary
                        self.userMessageLabel.textColor = self.textcolor
                        
                    }
                }
            } else {
                DatabaseManager.shared.grabUsername(safeEmail: safeEmail) { (firstNameString) in
                    DatabaseManager.shared.grabLast(safeEmail: safeEmail) { (lastNameString) in
                        self.userNameLabel.text = "\(firstNameString) \(lastNameString)"
                        self.userNameLabel.textColor = self.primary
                        self.userMessageLabel.textColor = self.textcolor
                        
                        let path = "images/\(model.otherUserEmail)_profile_picture.png"
                        
                        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                            switch result {
                            case .success(let url):
                                DispatchQueue.main.async {
                                    self?.userImageView.sd_setImage(with: url, completed: nil)
                                }
                            case .failure(_):
                                print("hm")
                            }
                        })
                    }
                }
            }
        }
        
        let font = UIFont(name: "Symbol", size: 20)!
        let fontMetrics = UIFontMetrics(forTextStyle: .title1)
        userNameLabel.font = fontMetrics.scaledFont(for: font)
        userNameLabel.adjustsFontForContentSizeCategory = true
        userMessageLabel.font = fontMetrics.scaledFont(for: font)
        userMessageLabel.adjustsFontForContentSizeCategory = true
        //TODO: Fix me
        if model.latestMessage.type == "photo" {
            userMessageLabel.text = "(Photo)"
        }
        if model.latestMessage.type == "video" {
            userMessageLabel.text = "(Video)"
        }
        if model.latestMessage.type == "location" {
            userMessageLabel.text = "(Location)"
        }
        
        
//        switch model.latestMessage.type {
//
//
//        case .text(let messageText):
//            userMessageLabel.text = messageText
//        case .photo(let mediaItem):
//            if let targetUrlString = mediaItem.url?.absoluteString {
//                userMessageLabel.text = "(photo)"
//            }
//            break
//        case .video(let mediaItem):
//            if let targetUrlString = mediaItem.url?.absoluteString {
//                userMessageLabel.text =  "(video)"
//            }
//            break
//        case .location(let locationData):
//            let location = locationData.location
//            userMessageLabel.text =  "(location)"
//            break
//
//        }
        
        
        
        if model.latestMessage.isRead == false {
            redDot.isHidden = false
            //userNameLabel.text! += "test"
            //backgroundColor = .secondarySystemBackground
            //backgroundColor = UIColor(hex: "DDEEFB")
        } else {
            redDot.isHidden = true
            //self.backgroundColor = UIColor(hex: "DDEEFB")

            //self.backgroundColor = .systemBackground
        }
        
        //let sender = message.sender
        //if sender.senderId == selfSender?.senderId 
        
        let content = UNMutableNotificationContent()
        
        content.title = model.name
        content.body = model.latestMessage.text
        
        // center = UNUserNotificationCenter.current()
        
        //let date = Date().addingTimeInterval(10)
        
        //let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
       // let uuidString = UUID().uuidString
        
        //let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        //center.add(request) { (error) in
        //    print("error sending notification \(error)")
        //}
        
        
        
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let newSafeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: newSafeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                var position = 0
                for conversation in conversations {
                    if (position >= conversations.count){
                        break
                    }
                    if conversation.id == model.id {
                        
                        DatabaseManager.shared.checkPasscord(index: "\(position)") { Bool in
                            if Bool {
                                if model.latestMessage.type == "text" {
                                    self?.userMessageLabel.text = "(text)"
                                    }
                            } else {
                                if model.latestMessage.type == "text" {
                                    self?.userMessageLabel.text = model.latestMessage.text
                                        }
                            }
                                }
                    }
                    position += 1
                }
            case .failure(let error):
        print("failed to get convos:\(error)")
        
        
            }
            
        })
        
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
