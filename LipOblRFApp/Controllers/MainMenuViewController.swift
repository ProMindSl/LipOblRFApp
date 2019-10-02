//
//  IdeaClaimMenuViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 17/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController
{
    // outlets
    
    @IBOutlet weak var btnQuestionCreate: UIButton!
    @IBOutlet weak var btnQuestionCreateLong: UIButton!
    @IBOutlet weak var btnIdeaCreate: UIButton!
    @IBOutlet weak var btnIdeaCreateLong: UIButton!
    @IBOutlet weak var btnClimeCreate: UIButton!
    @IBOutlet weak var btnClaimCreateLong: UIButton!
    @IBOutlet weak var indViewCenter: UIActivityIndicatorView!
    @IBOutlet weak var menu: TabMainMenuView!
    
    
    
    
    // link to static vars
    private let accMng = AccountManager.shared
    private let alertController = AlertController.shared
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        menu.setState(withType: TabMainMenuView.MENU_STATE_MAIN)
        updateViewState()
        addListeners()
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
     *   Listeners
    **/
    private func addListeners()
    {
        [btnIdeaCreate, btnIdeaCreateLong, btnClimeCreate, btnQuestionCreateLong].forEach(
        {
            $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
    }
    @objc private func didSelect(_ sender: UIButton)
    {
        switch sender
        {
        
        case btnIdeaCreate, btnIdeaCreateLong:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_ADD_IDEA_STEP_1)
        case btnClimeCreate, btnClaimCreateLong:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_ADD_CLAIM_FORM)
        default:
            break
        }
    }
    
    /*
     *   State methods
    **/
    private func setViewState(in stateType:Int)
    {
        if stateType == AccountManager.STATE_SIGNIN
        {
            DispatchQueue.main.async
            {
                self.btnIdeaCreate.isEnabled = true
                self.btnClimeCreate.isEnabled = true
                
            }
        }
        else if stateType == AccountManager.STATE_SIGNOUT
        {
            DispatchQueue.main.async
            {
                self.btnIdeaCreate.isEnabled = false
                self.btnClimeCreate.isEnabled = false
                
            }
        }
    }
    private func updateViewState()
    {
        let signInStatus = accMng.getAccessToken()
        self.stopLoadIndication()
        
        if signInStatus == AccountManager.REQUEST_LOGIN
        {
            setViewState(in: AccountManager.STATE_SIGNOUT)
            // relocate to login
            alertController.alert(in: self,
                                  withTitle: "Вход не выполнен",
                                  andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                  andActionTitle: "Войти",
                                  completion:
                                  { [unowned self] text in
                                    
                                        self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                  })
            
        }
        else if signInStatus == AccountManager.REQUEST_REFRESH_AT
        {
            initLoadIndication()
            
            accMng.refreshAccessToken(
                successCompletion:
                { [unowned self] text in
                    self.stopLoadIndication()
                    self.setViewState(in: AccountManager.STATE_SIGNIN)
                },
                errorCompletion:
                { [unowned self] text in
                    self.stopLoadIndication()
                    self.setViewState(in: AccountManager.STATE_SIGNOUT)
                    
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
            let signStatusOk = AccountManager.STATE_SIGNIN
            setViewState(in: signStatusOk)
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

extension MainMenuViewController: SidebarDelegate
{
    func sidbarDidOpen()
    {
        print("Sidebar opened")
    }
    
    func sidebarDidClose(with item: Int?)
    {
        guard let item = item else {return}
        print("Did select \(item)")
        let rootVC = AppDelegate.shared.rootViewController
        
        switch item
        {
        /*case UIStoryboard.VIEW_TYPE_NEWS_LIST:
            rootVC.showNewsList()
        case UIStoryboard.VIEW_TYPE_IDEAS_LIST:
            rootVC.showIdeaList()
        case UIStoryboard.VIEW_TYPE_LOGIN:
            rootVC.showLoginScreen()
        case UIStoryboard.VIEW_TYPE_ADD_IDEA_FORM:
            rootVC.showAddIdeaForm()
        case UIStoryboard.VIEW_TYPE_IDEACLIME_MENU:
            break
        case UIStoryboard.VIEW_TYPE_ADD_CLAIM_FORM:
            rootVC.showAddClaimForm()*/
        case UIStoryboard.VIEW_TYPE_ADD_IDEA_STEP_1:
            rootVC.showAddIdeaStep1()
        case UIStoryboard.VIEW_TYPE_LOGIN:
            rootVC.showLoginScreen()
        default:
            break
        }
    }
}
