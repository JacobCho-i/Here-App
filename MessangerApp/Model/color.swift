//
//  color.swift
//  MessangerApp
//
//  Created by choi jun hyung on 6/27/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import Foundation
import UIKit

enum colorType {
    case orange, pink, white
}
//struct colors{
//
//}

struct color {
    let primary:UIColor
    let secondary:UIColor
    let third:UIColor
}

enum orange{
    case primary,secondary,third
}

enum pink{
    case primary,secondary,third
}

enum white{
    case primary,secondary,third
}
//
//struct pink {
//    let primaryColor: UIColor
//    let secondaryColor: UIColor
//    let thirdColor: UIColor
//}
//
//struct orange {
//    let primaryColor: UIColor = #colorLiteral(red: 0.9912647605, green: 0.6538529396, blue: 0.1987086833, alpha: 1)
//    let secondaryColor: UIColor = #colorLiteral(red: 1, green: 0.8577087522, blue: 0.6699833274, alpha: 1)
//    let thirdColor: UIColor = #colorLiteral(red: 1, green: 0.9404397011, blue: 0.9045404792, alpha: 1)
//}
//
//struct white {
//    let primaryColor: UIColor
//    let secondaryColor: UIColor
//    let thirdColor: UIColor
//}
