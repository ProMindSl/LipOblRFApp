//
//  NavigationExtensions.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation
import UIKit
extension UIStoryboard{
    struct main {
        static func LaunchNewsVC() -> NewsViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsViewController") as? NewsViewController
        }
        static func NavigationVC() -> NavigationMenuViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationMenuViewController") as? NavigationMenuViewController
        }
        static func IdeasVC() -> EdeasViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EdeasViewController") as? EdeasViewController
        }
        static func LoginVC() -> LoginViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        }
        
    }
}

