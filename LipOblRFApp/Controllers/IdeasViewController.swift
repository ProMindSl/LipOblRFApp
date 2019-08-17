//
//  EdeasViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation
import UIKit
class IdeasViewController: UIViewController
{
    
    @IBAction func OpenMenu(_ sender: Any)
    {
        SidebarLauncher(delegate: self ).show()
    }
    
}

extension IdeasViewController: SidebarDelegate
{
    func sidbarDidOpen()
    {
        print("Sidebar opened")
    }
    
    func sidebarDidClose(with item: Int?)
    {
        guard let item = item else {return}
        print("Did select \(item)")
        switch item {
        case UIStoryboard.VIEW_TYPE_NEWS_LIST:
            let v = UIStoryboard.main.LaunchNewsVC()
            present(v!, animated: true)
        case UIStoryboard.VIEW_TYPE_IDEAS_LIST:
            break
        case UIStoryboard.VIEW_TYPE_LOGIN:
            let v = UIStoryboard.main.LoginVC()
            present(v!, animated: true)
        default:
            break
        }
    }
}

