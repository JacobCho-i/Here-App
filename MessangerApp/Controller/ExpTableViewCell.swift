import Foundation
import UIKit

class ExpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    func configure(path: String, name: String) {
        setColor()
        self.backgroundColor = third
        self.layer.borderWidth = 10
        let profilePic = UIImageView()
        profilePic.image = UIImage(systemName: "person.circle")
        self.userImageView.image = profilePic.image
        self.userImageView.tintColor = primary
        //let color = UIColor(displayP3Red: 255, green: 240, blue: 232, alpha: 1.0)
        let color = secondary
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = 35
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.masksToBounds = true
        //userImageView?.image = image.image
        usernameLabel?.text = name
        userImageView.layer.cornerRadius = 35
        usernameLabel.textColor = primary
        let font = UIFont(name: "Symbol", size: 20)!
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        usernameLabel.font = fontMetrics.scaledFont(for: font)
        usernameLabel.adjustsFontForContentSizeCategory = true
        //usernameLabel.acce
        
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
    func configure(path:String, name: String, index: Int) {
        
        
    }
    
    
    
    
    
}

