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
    public static let VIEW_TYPE_NEWS_LIST = 0
    public static let VIEW_TYPE_NAV_MENU = 3
    public static let VIEW_TYPE_IDEAS_LIST = 1
    public static let VIEW_TYPE_LOGIN = 2
    
    struct main {
        static func LaunchNewsVC() -> NewsViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsViewController") as? NewsViewController
        }
        static func NavigationVC() -> NavigationMenuViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationMenuViewController") as? NavigationMenuViewController
        }
        static func IdeasVC() -> IdeasViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IdeasViewController") as? IdeasViewController
        }
        static func LoginVC() -> LoginViewController?{
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        }
        
    }
}

