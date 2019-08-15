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
    
    //link to accaunt manager
    let accMng = AccountManager.shared
    
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
    @IBOutlet weak var uiPicSignOutBtn: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setListenersForNavBtns()
        setState(in: accMng.currentSignState)
    }
    
    /*
     *   State methods
    **/
    private func setState(in stateType:Int)
    {
        if stateType == accMng.STATE_SIGNIN
        {
            btnSignIn.isHidden = true
            btnSignUp.isHidden = true
            btnSignOut.isHidden = false
            
            labelUserFIO.text = accMng.getUserParsms()["fio"] as? String
            labelUserFIO.isHidden = false
            uiPicSignOutBtn.isHidden = false
        }
        else if stateType == accMng.STATE_SIGNOUT
        {
            btnSignIn.isHidden = false
            btnSignUp.isHidden = false
            btnSignOut.isHidden = true
            labelUserFIO.isHidden = true
            uiPicSignOutBtn.isHidden = true
        }
    }
    
    /*
    *   Navigation methods
    **/
    @objc func didSelect(_ sender: UIButton)
    {
        switch sender
        {
        case btnNewsList:
            delegate?.navigation(didSelect: UIStoryboard.VIEW_TYPE_NEWS_LIST)
        case btnIdeasList:
            delegate?.navigation(didSelect: UIStoryboard.VIEW_TYPE_IDEAS_LIST)
        case btnSignIn:
            delegate?.navigation(didSelect: UIStoryboard.VIEW_TYPE_LOGIN)
        default:
            break
        }
    }
    
    
    
    /*
     *   UI handlers
    **/
    private func setListenersForNavBtns()
    {
        [btnNewsList,btnIdeasList,btnSignIn].forEach(
        {
            $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
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


    
    

