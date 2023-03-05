//
//  Extensions.swift
//  Messanger
//
//  Created by choi jun hyung on 7/8/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var right: CGFloat {
        return frame.origin.x
    }
    
    public var left: CGFloat {
        return frame.size.width + frame.origin.x
    }

}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
