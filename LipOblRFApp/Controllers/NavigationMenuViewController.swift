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
    @IBOutlet weak var indHeader: UIActivityIndicatorView!
    @IBOutlet weak var indFooter: UIActivityIndicatorView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setListenersForNavBtns()
        // check signin status
        updateViewState()
        
    }
    
    /*
     *   State methods
    **/
    private func setViewState(in stateType:Int)
    {
        if stateType == accMng.STATE_SIGNIN
        {
            DispatchQueue.main.async
            {
                self.btnSignIn.isHidden = true
                self.btnSignUp.isHidden = true
                self.btnSignOut.isHidden = false
                
                self.labelUserFIO.text = self.accMng.getUserParsms()["fio"] as? String
                self.labelUserFIO.isHidden = false
                self.uiPicSignOutBtn.isHidden = false
            }
        }
        else if stateType == accMng.STATE_SIGNOUT
        {
            DispatchQueue.main.async
            {
                self.btnSignIn.isHidden = false
                self.btnSignUp.isHidden = false
                self.btnSignOut.isHidden = true
                self.labelUserFIO.isHidden = true
                self.uiPicSignOutBtn.isHidden = true
            }
        }
    }
    
    private func initLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.indHeader.isHidden = false
            self.indFooter.isHidden = false
            self.indHeader.startAnimating()
            self.indFooter.startAnimating()
        }
    }
    private func stopLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.indHeader.isHidden = true
            self.indFooter.isHidden = true
            self.indHeader.stopAnimating()
            self.indFooter.stopAnimating()
        }
    }
    
    private func updateViewState()
    {
        let signInStatus = accMng.getAccessToken()
        self.stopLoadIndication()
        
        if signInStatus == accMng.REQUEST_LOGIN
        {
            setViewState(in: accMng.STATE_SIGNOUT)
        }
        else if signInStatus == accMng.REQUEST_REFRESH_AT
        {
            initLoadIndication()
            
            accMng.refreshAccessToken(successCompletion:
            { [unowned self] text in
                self.stopLoadIndication()
                self.setViewState(in: self.accMng.STATE_SIGNIN)
            },
            errorCompletion:
            { [unowned self] text in
                self.stopLoadIndication()
                self.setViewState(in: self.accMng.STATE_SIGNOUT)
            })
        }
        else
        {
            setViewState(in: accMng.STATE_SIGNIN)
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
    
    @IBAction func didSelectSignOutBtn(_ sender: Any)
    {
        accMng.signOut()
        CloseMenu(self)
    }
    
}


    
    

