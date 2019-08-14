//
//  NavigationMenuViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation
import UIKit
protocol NavigationDelegate{
    func navigation(didSelect: Int?)
}

class NavigationMenuViewController: UIViewController{
    
    
    
    var delegate: NavigationDelegate?
    
    /*override func viewDidLoad() {
        super.viewDidLoad()
        [buttonLaunchVC,buttonSecondViewController,buttonThirdViewController].forEach({
            $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
    }
    
    @objc func didSelect(_ sender: UIButton){
        switch sender {
        case buttonLaunchVC:
            delegate?.navigation(didSelect: 0)
        case buttonSecondViewController:
            delegate?.navigation(didSelect: 1)
        case buttonThirdViewController:
            delegate?.navigation(didSelect: 2)
        default:
            break
        }
    }
    
    
    @IBAction func CloseMenu(_ sender: Any) {
        delegate?.navigation(didSelect: nil)
    }
    
    */
}
