//
//  NotificationHelper.swift
//  MessangerApp
//
//  Created by choi jun hyung on 4/21/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import UIKit
import UserNotifications



class NotificationHelper: NSObject {
    static let sharedManager = NotificationHelper()
    var userAllowsNotification = false
    
    func requestUserPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if (success) {
                print("Permission granted")
                self.userAllowsNotification = true
                //TODO: Handle user interface change
                
            } else if error != nil {
                self.userAllowsNotification = false
                //print("error occured while granting permission \(error?.localizedDescription)")
                
            }
            
        }
    }
}
