//
//  SignInViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 25/09/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController
{
    
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
    }
    
    private func addListeners()
    {
        // configure ui view
        btnSignIn.layer.cornerRadius = 6
        btnSignUp.layer.cornerRadius = 6
        btnSignUp.layer.borderColor = UIColor.white.cgColor
        btnSignUp.layer.borderWidth = CGFloat(exactly: 1.0)! 
        
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


