//
//  EdeasViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation
import UIKit
class IdeasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    
    @IBOutlet weak var tvIdeaList: UITableView!
    @IBOutlet weak var tabBtnNews: UIButton!
    @IBOutlet weak var tabBtnIdeaClimeMenu: UIButton!
    
    var loadActivityIndicator:UIActivityIndicatorView?
    
    // st links
    private let _accMng = AccountManager.shared
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    
    // cell count from Model
    private var _cellCount = 0
    private var _cellReuseIdentifier = "ideaCell"
    private var _cellHeight = 180.0
    
    @IBAction func OpenMenu(_ sender: Any)
    {
        SidebarLauncher(delegate: self ).show()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
        
        // other options
        tvIdeaList.separatorStyle = .none
        initUI()
        
    }
    
    /*
     *   TableVIew methods
     **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _cellCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(_cellHeight);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellReuseIdentifier, for: indexPath) as! IdeaViewCell
        
        let numOfRow = indexPath.row
        
        // set bg for cell
        if (indexPath.row % 2) == 0
        {
            cell.ivBG.image = UIImage(named: "btn_bg_idea1.png")
        }
        else
        {
            cell.ivBG.image = UIImage(named: "btn_bg_idea2.png")
        }
        // autor name
        let fullFio = _accMng.getUserParsms()["fio"] as? String
        cell.labelAutor.text = GetContentManager.getShortFio(from: fullFio!)
        let ideaId = Int(_getContMng.ideasOwnList[numOfRow].sphera)!
        // scope label
        cell.labelScope.text = _getContMng.getScopeNameById(with: ideaId)
        // idea label
        cell.lablelTitle.text = _getContMng.ideasOwnList[numOfRow].name
        // idea text
        cell.labelTextBody.text = _getContMng.ideasOwnList[numOfRow].txt
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        sidebarDidClose(with: UIStoryboard.VIEW_TYPE_NEWS_DETAIL)
    }
    
    /*
     *   -------- Privete methods ----------
     **/
    private func addListeners()
    {
        [tabBtnNews,tabBtnIdeaClimeMenu].forEach(
        {
            $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
    }
    @objc func didSelect(_ sender: UIButton)
    {
        switch sender
        {
        case tabBtnNews:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_NEWS_LIST)
        case tabBtnIdeaClimeMenu:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEACLIME_MENU)
        default:
            break
        }
    }
    
    /*
     *   Signin status checking method
     **/
    private func updateViewState(signInCompletion signInCompFunc: @escaping ((String) -> ()),
                                 signOutCompletion signOutCompFunc: @escaping ((String) -> ()))
    {
        let signInStatus = _accMng.getAccessToken()
        self.stopLoadIndication()
        
        if signInStatus == AccountManager.REQUEST_LOGIN
        {
            signOutCompFunc("not signIn")
            
            // show error alert and relocate to login
            self._alertController.alert(in: self,
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
            
            _accMng.refreshAccessToken(
                successCompletion:
                { [unowned self] text in
                    self.stopLoadIndication()
                    signInCompFunc("signIn ok")
                },
                errorCompletion:
                { [unowned self] text in
                    self.stopLoadIndication()
                    
                    // show error alert and relocate to login
                    self._alertController.alert(in: self,
                                                withTitle: "Вход не выполнен",
                                                andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                                andActionTitle: "Войти",
                                                completion:
                        { [unowned self] text in
                            signOutCompFunc("not signIn")
                            self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_LOGIN)
                    })
                    
            })
        }
        else
        {
            signInCompFunc("signIn ok")
        }
    }
    
    /*
     *   First init UI
     **/
    private func initUI()
    {
        // init ai
        DispatchQueue.main.async
        {                
            self.loadActivityIndicator = UIActivityIndicatorView(style: .gray)
            self.loadActivityIndicator?.center = self.view.center
            self.view.addSubview(self.loadActivityIndicator!)
            self.loadActivityIndicator?.hidesWhenStopped = true
        }
        
        initLoadIndication()
        
        // check/update signin status
        updateViewState(
        signInCompletion:
        { text in
            self.stopLoadIndication()
            
            if self._getContMng.ideasOwnList.count == 0                         // load user ideas (if needed)
            {
                self._getContMng.loadContent(byType: GetContentManager.CONTENT_TYPE_IDEAS_OWN,
                                             at: self._accMng.getAccessToken(),
                                             successCompletion:
                                             { text in
                                                print(self._getContMng.ideasOwnList)
                                                self._cellCount = self._getContMng.ideasOwnList.count
                                                
                                                DispatchQueue.main.async
                                                {
                                                    self.tvIdeaList.reloadData()
                                                }
                                             },
                                             errorCompletion:
                                             { text in
                                                print("error load ideas list")
                                             }
                )
            }
            
            if self._getContMng.scopeTypesList.count == 0
            {
                self._getContMng.loadContent(byType: GetContentManager.CONTENT_TYPE_SCOPES,
                                             at: self._accMng.getAccessToken(),
                                             successCompletion:
                                             { text in
                                                    self._cellCount = self._getContMng.ideasOwnList.count
                                                
                                                    DispatchQueue.main.async
                                                    {
                                                       self.tvIdeaList.reloadData()
                                                    }
                                              },
                                              errorCompletion:
                                              { text in
                                                    print("error load ideas list")
                                              }
                )
            }
        },
        signOutCompletion:
        { text in
            self.stopLoadIndication()
        })
    }
    
    /*
     *   Load indication
     **/
    private func initLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.loadActivityIndicator?.startAnimating()
        }
    }
    private func stopLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.loadActivityIndicator?.stopAnimating()
        }
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
        let rootVC = AppDelegate.shared.rootViewController
        
        switch item
        {
        case UIStoryboard.VIEW_TYPE_NEWS_LIST:
            rootVC.showNewsList()
        case UIStoryboard.VIEW_TYPE_IDEAS_LIST:
            break
        case UIStoryboard.VIEW_TYPE_LOGIN:
            rootVC.showLoginScreen()
        case UIStoryboard.VIEW_TYPE_ADD_IDEA_FORM:
            rootVC.showAddIdeaForm()
        case UIStoryboard.VIEW_TYPE_IDEACLIME_MENU:
            rootVC.showIdeaClimeMenu()
        case UIStoryboard.VIEW_TYPE_ADD_CLAIM_FORM:
            rootVC.showAddClaimForm()
        default:
            break
        }
    }
}

