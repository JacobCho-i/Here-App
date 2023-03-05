//
//  ProfileModel.swift
//  MessangerApp
//
//  Created by choi jun hyung on 3/18/21.
//  Copyright © 2021 choi jun hyung. All rights reserved.
//

import Foundation
import UIKit

enum ProfileViewModelType {
    case info, logout, content, name, setting, section, email
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

