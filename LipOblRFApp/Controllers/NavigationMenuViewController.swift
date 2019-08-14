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
    
    // set delegate
    var delegate: NavigationDelegate?
    
    // outlets btns
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnNewsList: UIButton!
    @IBOutlet weak var btnIdeasList: UIButton!
    @IBOutlet weak var btnCreateIdea: UIButton!
    @IBOutlet weak var btnCreateClaim: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnSignOut: UIButton!
    
    //outlets media
    @IBOutlet weak var labelUserFIO: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        [btnNewsList,btnIdeasList,btnSignIn].forEach(
        {
            $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
    }
    
    @objc func didSelect(_ sender: UIButton){
        switch sender {
        case btnNewsList:
            delegate?.navigation(didSelect: 0)
        case btnIdeasList:
            delegate?.navigation(didSelect: 1)
        case btnSignIn:
            delegate?.navigation(didSelect: 2)
        default:
            break
        }
    }
    
    @IBAction func didSelectSignIn(_ sender: Any)
    {
        print("signIn init")
    }
    
    @IBAction func CloseMenu(_ sender: Any)
    {
        delegate?.navigation(didSelect: nil)
    }
    
    
}
