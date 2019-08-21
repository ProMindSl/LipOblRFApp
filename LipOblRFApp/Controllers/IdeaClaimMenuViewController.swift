//
//  IdeaClaimMenuViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 17/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class IdeaClaimMenuViewController: UIViewController
{
    // outlets
    @IBOutlet weak var tfCurrDate: UILabel!
    @IBOutlet weak var btnIdeaList: UIButton!
    @IBOutlet weak var btnIdeaCreate: UIButton!
    @IBOutlet weak var btnClimeCreate: UIButton!
    @IBOutlet weak var indViewCenter: UIActivityIndicatorView!

    
    
    // link to static vars
    private let accMng = AccountManager.shared
    private let alertController = AlertController.shared
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateViewState()
    }
    
    
    // handlers
    @IBAction func OpenMenu(_ sender: Any)
    {
        SidebarLauncher(delegate: self ).show()
    }
    
    /*
     *   -------- Private methods ----------
    **/
    /*
     *   State methods
    **/
    private func setViewState(in stateType:Int)
    {
        if stateType == accMng.STATE_SIGNIN
        {
            DispatchQueue.main.async
            {
                self.btnIdeaList.isEnabled = true
                self.btnIdeaCreate.isEnabled = true
                self.btnClimeCreate.isEnabled = true
                
            }
        }
        else if stateType == accMng.STATE_SIGNOUT
        {
            DispatchQueue.main.async
            {
                self.btnIdeaList.isEnabled = false
                self.btnIdeaCreate.isEnabled = false
                self.btnClimeCreate.isEnabled = false
                
            }
        }
    }
    private func updateViewState()
    {
        let signInStatus = accMng.getAccessToken()
        self.stopLoadIndication()
        
        if signInStatus == accMng.REQUEST_LOGIN
        {
            setViewState(in: accMng.STATE_SIGNOUT)
            // relocate to login
            alertController.alert(in: self,
                                  withTitle: "Вход не выполнен",
                                  andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                  andActionTitle: "Войти",
                                  completion: { [unowned self] text in
                                    
                                        self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                   })
            
        }
        else if signInStatus == accMng.REQUEST_REFRESH_AT
        {
            initLoadIndication()
            
            accMng.refreshAccessToken(
                successCompletion:
                { [unowned self] text in
                    self.stopLoadIndication()
                    self.setViewState(in: self.accMng.STATE_SIGNIN)
                },
                errorCompletion:
                { [unowned self] text in
                    self.stopLoadIndication()
                    self.setViewState(in: self.accMng.STATE_SIGNOUT)
                    
                    // relocate to login
                    self.alertController.alert(in: self,
                                          withTitle: "Вход не выполнен",
                                          andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                          andActionTitle: "Войти",
                                          completion:
                                          { [unowned self] text in
                                            
                                            self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                           })
                })
        }
        else
        {
            setViewState(in: accMng.STATE_SIGNIN)
        }
    }
    /*
     *   Load indication
    **/
    private func initLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.indViewCenter.isHidden = false
            self.indViewCenter.startAnimating()
        }
    }
    private func stopLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.indViewCenter.isHidden = true
            self.indViewCenter.stopAnimating()
        }
    }
 

}

extension IdeaClaimMenuViewController: SidebarDelegate
{
    func sidbarDidOpen()
    {
        print("Sidebar opened")
    }
    
    func sidebarDidClose(with item: Int?)
    {
        guard let item = item else {return}
        print("Did select \(item)")
        switch item
        {
        case UIStoryboard.VIEW_TYPE_NEWS_LIST:
            let v = UIStoryboard.main.LaunchNewsVC()
            present(v!, animated: true)
        case UIStoryboard.VIEW_TYPE_IDEAS_LIST:
            let v = UIStoryboard.main.IdeasVC()
            present(v!, animated: true)
        case UIStoryboard.VIEW_TYPE_LOGIN:
            let v = UIStoryboard.main.LoginVC()
            present(v!, animated: true)
        default:
            break
        }
    }
}
