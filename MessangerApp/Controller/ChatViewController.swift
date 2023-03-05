//
//  ChatViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 10/10/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation
import UserNotifications


final class ChatViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    
    
    public static let dateFormatter: DateFormatter = {
       let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        formattre.timeZone = TimeZone(abbreviation: "UTC")
        return formattre
    }()
    private var previousDate: String = " "
    
    let newNotificationKey = "messanger.message.later"
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    public let otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    
    private var present:Bool = Bool()
    private var messages = [Message]()
    private var dates = [String]()
    private var passcord:String = String()
    private var messageText:String? = String()
    
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
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    
    init(with email: String, id: String?, passcord: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        if passcord != nil {
            self.present = true
            self.passcord = passcord!
        } else {
            self.present = false
            self.passcord = ""
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
        DatabaseManager.shared.checkDelete(email: otherUserEmail) { bool in
            if bool {
                self.messageInputBar.isHidden = true
                self.title = "Deleted User"
                let alert = UIAlertController(title: "Notification", message: "This user is a deleted user", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        self.navigationController?.navigationBar.isHidden = false
        if let conversationId = conversationId {
            DatabaseManager.shared.getConvID(convId: conversationId) { id in
                
            }
        
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //code
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        guard let id = conversationId else {
            return
            
        }
        NotificationCenter.default.post(name: .uponUserQuittingChatView, object: nil, userInfo: ["id":"\(id)"])
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getRecentConversation(email: safeEmail) { (id) in
            print("recent id: \(id)")
            DatabaseManager.shared.userRead(indexpath: id)
        }
        
//        if {
            
        
        
    }
    @objc func passwordTest() {
        if self.present {
            let vc = PasswordView(email: otherUserEmail, opening: true, passcord: passcord, reset:false, create: false)
            vc.title = "Passcord"
            vc.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    
    
    @objc func sendMessageLater() {
        guard let selfSender = self.selfSender, let string = self.messageText,
        let messageId = createMessageId() else {
            return
        }

        let message = Message(sender: selfSender,
                               messageId: messageId,
                               sentDate: Date(),
                               kind: .text(string))
        //send message
        if isNewConversation {
            print("we here")
            DatabaseManager.shared.checkingAuth(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation__\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessage(id: newConversationId, shouldScrollToBottom: false)
                    self?.messageInputBar.inputTextView.text = nil
                }
                else {
                    print("failed to sent")
                }
            })
        }
        else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            print("we here ?")
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                switch success {
                case .success(let bool):
                    if bool {
                    self?.messageInputBar.inputTextView.text = nil
                        self?.messageText = nil
                    } else {
                        let alert = AlertManager.shared.messageFailedtoSend()
                        self?.present(alert, animated: true)
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Notification", message: "Failed sending a message: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                    self?.present(alert, animated: true)
                }
                    
                    //alertuiview
                    
                
            })
        }
    }
    
    @objc func userread() {
        guard let id = conversationId else {
            return
        }
        DatabaseManager.shared.getConvID(convId: id) { convId in
            DatabaseManager.shared.userRead(indexpath: convId)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        NotificationCenter.default.addObserver(self, selector: #selector(passwordTest), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userread), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessageLater), name: .uponFinishingUploading, object: nil)
            if self.present {
                let vc = PasswordView(email: otherUserEmail, opening: true, passcord: passcord, reset:false, create: false)
            vc.title = "Passcord"
            vc.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
        let customImage = UIImage(systemName: "paperplane.circle.fill")!
        customImage.sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFit)
        messageInputBar.sendButton.image = customImage
        messageInputBar.sendButton.imageView?.tintColor = primary
        messageInputBar.setStackViewItems([messageInputBar.sendButton, .fixedSpace(5)], forStack: .right, animated: false)
        
        messageInputBar.sendButton.title = ""
        messagesCollectionView.backgroundColor = third
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "person.circle")
//        messagesCollectionView.backgroundView = imageView
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .center, textInsets: .zero))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .center, textInsets: .zero))
        messageInputBar.delegate = self
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        self.navigationController?.navigationBar.barTintColor = third
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: primary]
        setupInputButton()
        
        
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside{ [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }

    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
        self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { [weak self] _ in
        self?.presentVideoInputActionSheet()
        }))
//        actionSheet.addAction(UIAlertAction(title: "Location",
//                                            style: .default,
//                                            handler: { [weak self] _ in
//        self?.presentLocationPicker()
//        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {[weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                let conversationId = strongSelf.conversationId,
                let selfSender = strongSelf.selfSender,
                let name = strongSelf.title else {
                    return
            }
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            print("long=\(longitude) | lat=\(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                 size: .zero)
            
            let message = Message(sender: selfSender,
                                   messageId: messageId,
                                   sentDate: Date(),
                                   kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                
                switch success {
                case .success(let bool):
                    if !bool {
                        let alert = AlertManager.shared.messageFailedtoSend()
                        self?.present(alert, animated: true)
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Notification", message: "Failed sending a message: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                    self?.present(alert, animated: true)
                }
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self]_ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))

        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self]_ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))

        present(actionSheet, animated: true)
    }
    
    private func listenForMessage(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("message are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.scrollToLastItem()
                    //}
                    
                }
            case .failure(let error):
                print("Failed to get message: \(error)")
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessage(id: conversationId, shouldScrollToBottom: true)
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
            let conversationId = conversationId,
            let selfSender = selfSender,
            let name = self.title else {
                return
        }
        
        if let image = info[.editedImage] as? UIImage,let imageData = image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                           messageId: messageId,
                                           sentDate: Date(),
                                           kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        switch success {
                        case .success(let bool):
                            if !bool {
                                let alert = AlertManager.shared.messageFailedtoSend()
                                self?.present(alert, animated: true)
                            }
                        case .failure(let error):
                            let alert = UIAlertController(title: "Notification", message: "Failed sending a message: \(error.localizedDescription)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                            self?.present(alert, animated: true)
                        }
                    })
                    
                case .failure(let error):
                    print("message photo upload error: \(error)")
                    
                }
            })
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self]result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    print("Uploaded Message video:\(urlString)")
                    
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                           messageId: messageId,
                                           sentDate: Date(),
                                           kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        
                        switch success {
                        case .success(let bool):
                            if !bool {
                                let alert = AlertManager.shared.messageFailedtoSend()
                                self?.present(alert, animated: true)
                            }
                        case .failure(let error):
                            let alert = UIAlertController(title: "Notification", message: "Failed sending a message: \(error.localizedDescription)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                            self?.present(alert, animated: true)
                        }
                    })
                    
                case .failure(let error):
                    print("message photo upload error: \(error)")
                    
                }
            })
        }
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        inputBar.inputTextView.images
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() else {
            return
        }
        print("IMAGES detected \(inputBar.inputTextView.images.count)")
        var imageLoaded = 0
        let archieve = inputBar.inputTextView.images
        let texted = inputBar.inputTextView.text!
        self.messageInputBar.inputTextView.text = nil
        if archieve.count > 0 {
            for image in archieve {
                let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
                if let imageData = image.pngData() {
                
                StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    switch result {
                    case .success(let urlString):
                        guard let messageId = self?.createMessageId(),
                              let conversationId = self?.conversationId,
                              let selfSender = self?.selfSender,
                            let name = self?.title else {
                                return
                        }
                        print(selfSender.displayName)
                        guard let url = URL(string: urlString),
                            let placeholder = UIImage(systemName: "plus") else {
                                return
                        }
                        
                        let media = Media(url: url,
                                          image: nil,
                                          placeholderImage: placeholder,
                                          size: .zero)
                        let message = Message(sender: selfSender,
                                               messageId: messageId,
                                               sentDate: Date(),
                                               kind: .photo(media))
                        
                        DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                            switch success {
                            case .success(let bool):
                                if bool {
                                    imageLoaded += 1
                                    if imageLoaded == archieve.count {
                                        print("we called")
                                        let letters = CharacterSet.letters
                                        let range = texted.rangeOfCharacter(from: letters)
                                        if range != nil {
                                            let texts = text.suffix(text.count - 2 * archieve.count)
                                            self?.messageText = String(texts)
                                            NotificationCenter.default.post(name: .uponFinishingUploading, object: self)
                                        }
                                    }
                                } else {
                                    let alert = AlertManager.shared.messageFailedtoSend()
                                    self?.present(alert, animated: true)
                                }
                            case .failure(let error):
                                let alert = UIAlertController(title: "Notification", message: "Failed sending a message: \(error.localizedDescription)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                                self?.present(alert, animated: true)
                            }
                        })
                        
                    case .failure(_):
                        print("failed to fetch the data")
                    }
                    })
                }
            }
        } else {
            let message = Message(sender: selfSender,
                                   messageId: messageId,
                                   sentDate: Date(),
                                   kind: .text(text))
            //send message
            print("heh he \(isNewConversation)")
            if isNewConversation {
                print("are we even here")
                DatabaseManager.shared.checkingAuth(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                    if success {
                        print("message sent")
                        self?.isNewConversation = false
                        let newConversationId = "conversation__\(message.messageId)"
                        self?.conversationId = newConversationId
                        self?.listenForMessage(id: newConversationId, shouldScrollToBottom: false)
                        self?.messageInputBar.inputTextView.text = nil
                    }
                    else {
                        print("failed to sent")
                    }
                })
            }
            else {
                guard let conversationId = conversationId, let name = self.title else {
                    return
                }
                //here
                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                    switch success {
                    case .success(let bool):
                        if bool {
                        self?.messageInputBar.inputTextView.text = nil
                            self?.messageText = nil
                        } else {
                            let alert = AlertManager.shared.messageFailedtoSend()
                            self?.present(alert, animated: true)
                        }
                    case .failure(let error):
                        let alert = UIAlertController(title: "Notification", message: "Failed sending a message: \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
                        self?.present(alert, animated: true)
                    }
                })
            }
        }
        
        
    }
    
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if (indexPath.section == messages.count-1) {
            return 16
        }
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "HH:mm"
        formatter1.locale = .current
        let prev = formatter1.string(from: messages[indexPath.section+1].sentDate)
        let currentDate = formatter1.string(from: messages[indexPath.section].sentDate)
        if (currentDate == prev) {
            return 0
        }
        previousDate = currentDate
        return 16
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter1 = DateFormatter()
        let today = Date()
        let calendar = NSCalendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        formatter1.dateFormat = "E, d MMM y"
        formatter1.locale = .current
        let currentDate = formatter1.string(from: message.sentDate)
        let todayDate = formatter1.string(from: today)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: textcolor,
        ]
        guard let daybefore = yesterday else {
            return nil
        }
        let yesterdayDate = formatter1.string(from: daybefore)
        
//        if (currentDate == prev) {
//            return nil
//        }
        if currentDate == todayDate {
            return NSAttributedString(string: "Today", attributes: attributes)
        }
        if currentDate == yesterdayDate {
            return NSAttributedString(string: "Yesterday", attributes: attributes)
        }
        return NSAttributedString(string: currentDate, attributes: attributes)
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if (indexPath.section == 0) {
            return 16
        }
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "E, d MMM y"
        formatter1.locale = .current
        let prev = formatter1.string(from: messages[indexPath.section-1].sentDate)
        let currentDate = formatter1.string(from: messages[indexPath.section].sentDate)
        if (currentDate == prev) {
            return 0
        }
        previousDate = currentDate
        return 16
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .current
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "E, d MMM y"
        formatter1.locale = .current
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: textcolor,
        ]
        previousDate = formatter1.string(from: message.sentDate)
        let date = formatter.string(from: message.sentDate)
        return NSAttributedString(string: date, attributes: attributes)
    }
    
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let view = MessageReusableView()
        let label = UILabel()
        label.text = "time"
        view.addSubview(label)
        return view
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        let sections = messages.count
        return sections
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else{
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .bubbleTail(.bottomRight, .pointedEdge)
            //return .bubbleTailOutline(primary, .bottomRight, .pointedEdge)
        }
        return .bubbleTail(.bottomLeft, .pointedEdge)
        //return .bubbleTailOutline(secondary, .bottomLeft, .pointedEdge)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            
            return secondary
        }
        
        return primary
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == selfSender?.senderId {
            return primary
        }
        return .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        //let sender = message.sender
        
//        guard let selfSender = selfSender, message.sender.senderId != selfSender.senderId else {
//            avatarView.isHidden = true
//            return
//        }
            avatarView.backgroundColor = third
            if let otherUserPhotoURL = self.otherUserPhotoURL{
                avatarView.sd_setImage(with: otherUserPhotoURL, completed: nil)
            }
            else {
                let email = self.otherUserEmail
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(_):
                        let image = UIImage(systemName: "person.circle")
                        avatarView.backgroundColor = self?.third
                        avatarView.image = image
                        avatarView.tintColor = self?.primary
                        
                    }
                })
            }
            
        }
        

}


extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
                                                
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewsViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: false)
            
            let actionSheet = UIAlertController(title: "What do you want to do?", message: "yeet", preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Delete",
                                                style: .default,
                                                handler:  { _ in
                                                    print("hi")
            }))
            actionSheet.addAction(UIAlertAction(title: "View",
                                                style: .default,
                                                handler:  { _ in
            
            }))
            //present(actionSheet, animated: true)
            
            
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
            
        default:
            break
        }
    }
}

extension Notification.Name {
    static let uponFinishingUploading = Notification.Name("user_read.notification_key")
    static let uponUserQuittingChatView = Notification.Name("user_left_chat_view")
    static let usersLoaded = Notification.Name("usersLoaded")
    static let loadProfile = Notification.Name("loadProfile")
    static let spinner = Notification.Name("spinner")
    static let passwordNotif = Notification.Name("passwordNotif")
    static let loginError = Notification.Name("loginError")
    static let convError = Notification.Name("convError")
    static let listenConv = Notification.Name("listenConv")
}
//
//extension UITextField {
//    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return action == #selector(UIResponderStandardEditActions.paste)
//    }
//}
