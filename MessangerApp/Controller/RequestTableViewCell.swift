//
//  RequestTableViewCell.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/29/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    static let identifier = "RequestTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColor()
        backgroundColor = third
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    let requestLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    
    func configure(path: String, name: String, section: Int) {
        setColor()
        self.backgroundColor = third
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        userImageView.frame = CGRect(x: 20,
                                     y: 20,
                                     width: 50,
                                     height: 50)
        usernameLabel.frame = CGRect(x: userImageView.right + 70,
                                     y: contentView.height/2 - 25/2,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height-20)/2)
        usernameLabel.adjustsFontForContentSizeCategory = true
        usernameLabel.adjustsFontSizeToFitWidth = true
        
        self.layer.borderWidth = 10
        //let color = UIColor(displayP3Red: 255, green: 240, blue: 232, alpha: 1.0)
        let color = secondary
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = 35
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.masksToBounds = true
        //userImageView?.image = image.image
        usernameLabel.text = name
        userImageView.layer.cornerRadius = 25
        usernameLabel.textColor = primary
        let font = UIFont(name: "Symbol", size: 20)!
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        usernameLabel.font = fontMetrics.scaledFont(for: font)
        usernameLabel.adjustsFontForContentSizeCategory = true
        //usernameLabel.acce
        let profilePic = UIImageView()
        profilePic.image = UIImage(systemName: "person.circle")
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
                DispatchQueue.main.async {
                    self?.userImageView.image = profilePic.image
                    self?.userImageView.tintColor = self?.primary
                }
                
            }
        })
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
