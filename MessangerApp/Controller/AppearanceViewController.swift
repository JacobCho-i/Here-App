//
//  AppearanceViewController.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/27/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit

class AppearanceViewController: UIViewController {
    
    var primary:UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
    var secondary:UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
    var third:UIColor = #colorLiteral(red: 1, green: 0.9524316192, blue: 0.8238736987, alpha: 1)
    var textcolor:UIColor = #colorLiteral(red: 1, green: 0.7450067401, blue: 0.4302176535, alpha: 1)
    
    private let White: UIButton = {
       let button = UIButton()
        button.setTitle("  White", for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return button
    }()
    
    private let Orange: UIButton = {
       let button = UIButton()
        button.setTitle("  Orange", for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return button
    }()
    
    private let Pink: UIButton = {
       let button = UIButton()
        button.setTitle("  Pink", for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColor()
        let lineView = UIView()
        let belowView = UIView()
        let upperView = UIView()
        view.backgroundColor = third
        view.addSubview(lineView)
        view.addSubview(belowView)
        view.addSubview(upperView)
        view.addSubview(Pink)
        view.addSubview(White)
        view.addSubview(Orange)
        view.backgroundColor = secondary
        Pink.frame = CGRect(x: 0, y: 150, width: view.width, height: 45)
        White.frame = CGRect(x: 0, y: 197, width: view.width, height: 45)
        Orange.frame = CGRect(x: 0, y: 244, width: view.width, height: 45)
        lineView.frame = CGRect(x: 0, y: 150, width: view.width, height: 139)
        belowView.frame = CGRect(x: 0, y: 291, width: view.width, height: view.height-291)
        //upperView.frame = CGRect(x: 0, y: 0, width: view.width, height: <#T##CGFloat#>)
        Pink.setTitleColor(primary, for: .normal)
        White.setTitleColor(primary, for: .normal)
        Orange.setTitleColor(primary, for: .normal)
        Pink.backgroundColor = third
        White.backgroundColor = third
        Orange.backgroundColor = third
        lineView.backgroundColor = secondary
        belowView.backgroundColor = secondary
        Pink.contentHorizontalAlignment = .left
        White.contentHorizontalAlignment = .left
        Orange.contentHorizontalAlignment = .left
        Pink.addTarget(self, action: #selector(setColorPink), for: .touchUpInside)
        Orange.addTarget(self, action: #selector(setColorOrange), for: .touchUpInside)
        White.addTarget(self, action: #selector(setColorWhite), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func setColorWhite() {
        UserDefaults.standard.setValue("pink", forKey: "theme")
        setColor()
        self.navigationController?.navigationBar.tintColor = secondary
        navigationController?.popViewController(animated: true)
        print("set color as white")
    }
    
    @objc func setColorOrange() {
        UserDefaults.standard.setValue("orange", forKey: "theme")
        setColor()
        self.navigationController?.navigationBar.tintColor = secondary
        navigationController?.popViewController(animated: true)
        print("set color as orange")
    }
    
    @objc func setColorPink() {
        UserDefaults.standard.setValue("pink", forKey: "theme")
        setColor()
        self.navigationController?.navigationBar.tintColor = secondary
        navigationController?.popViewController(animated: true)
        print("set color as pink")
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


