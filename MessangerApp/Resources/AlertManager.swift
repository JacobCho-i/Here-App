//
//  AlertManager.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/2/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import Connectivity

class AlertManager: NSObject {
    static let shared = AlertManager()
    
    
    public func internetNotStable() -> UIAlertController {
            let alert = UIAlertController(title: "Warning", message: "Internet is not stable", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            return alert
        }
    
    public func messageFailedtoSend() -> UIAlertController {
        let alert = UIAlertController(title: "Warning", message: "Message Failed to send", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        return alert
    }

    
    public func verifiedEmails() -> UIAlertController {
        let alert = UIAlertController(title: "Warning", message: "Please Verify your Email First", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        return alert
    }
    

    
}

