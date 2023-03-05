//
//  SettingTableViewCell.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/29/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    static let identifier = "SettingTableViewCell"

    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    let settingText: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
        
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColor()
        // Initialization code
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
    
    func configure(text: String){
        setColor()
        settingText.text = text
        if text == "Delete this Account" || text == "Log Out" {
            settingText.textColor = .red
        } else {
            settingText.textColor = primary
        }
    }

    
    
    override func layoutSubviews() {
    super.layoutSubviews()
        setColor()
        contentView.addSubview(settingText)
        settingText.frame = CGRect(x: 25,
                                   y: 10,
                                   width: contentView.width-60,
                                   height: 20)
        let font = UIFont(name: "Avenir", size: 18)!
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        settingText.font = fontMetrics.scaledFont(for: font)
        settingText.adjustsFontForContentSizeCategory = true
        self.backgroundColor = third
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
