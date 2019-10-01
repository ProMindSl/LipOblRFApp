//
//  SignInViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 25/09/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
//import

class SignInViewController: UIViewController
{
    
    @IBOutlet weak var btnSignIn: LRAppButton!
    @IBOutlet weak var btnSignUp: LRAppButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
    }
    
    private func addListeners()
    {
        btnSignUp.setViewType(with: LRAppButton.TYPE_ALPHA_WHITE_TITLE)
        btnSignIn.setViewType(with: LRAppButton.TYPE_WHITE)
        
        [btnSignIn, btnSignUp].forEach(
        {
            $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
    }
    
    /*
    *   btn click methods
    **/
    @objc func didSelect(_ sender: UIButton)
    {
        let rootVC = AppDelegate.shared.rootViewController
        
        switch sender
        {
        case btnSignIn :
            rootVC.showLoginScreen()
        case btnSignUp:
            break
        default:
            break
        }
    }
    

}


