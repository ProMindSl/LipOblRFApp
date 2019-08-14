//
//  EdeasViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation
import UIKit
class EdeasViewController: UIViewController{
    
    @IBAction func OpenMenu(_ sender: Any) {
        SidebarLauncher(delegate: self ).show()
    }
}
extension EdeasViewController: SidebarDelegate{
    func sidbarDidOpen() {
        print("Sidebar opened")
    }
    
    func sidebarDidClose(with item: Int?) {
        guard let item = item else {return}
        print("Did select \(item)")
        switch item {
        case 0:
            let v = UIStoryboard.main.LaunchNewsVC()
            present(v!, animated: true)
        case 1:
            break
        case 2:
            let v = UIStoryboard.main.LoginVC()
            present(v!, animated: true)
        default:
            break
        }
    }
}

