//
//  AddIdeaStepOneViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 02/10/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class AddIdeaStepOneViewController: UIViewController,
                                    UITextFieldDelegate
{
    @IBOutlet weak var menu: TabMainMenuView!
    @IBOutlet weak var btnNextStep: LRAppButton!
    @IBOutlet weak var tfIdeaScope: UITextField!
    
    // st links
    private let _accMng = AccountManager.shared
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    // other mngs init
    private let _setController = SetContentManager.shared
    
    // type picker vars
    var picker: TypePickerView?
    var pickerAccessory: UIToolbar?
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initUI()
        updateCompleteStepStatus()
    }
    
    /*
     *   -------- Public methods ----------
    **/
    
    
    /*
     *   -------- Privete methods ----------
    **/
    private func updateCompleteStepStatus()
    {
        if _setController.currIdeaScope != 0
        {
            DispatchQueue.main.async
            {
                self.btnNextStep.setEnable()
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.btnNextStep.setDisable()
            }
        }
    }
    
    
    private func initUI()
    {
        self.menu.setState(withType: TabMainMenuView.MENU_STATE_SERVICES)
        self.btnNextStep.setViewType(with: LRAppButton.TYPE_RED)
       
        // init picker
        picker = TypePickerView()
        picker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker?.backgroundColor = UIColor.white
        picker?.data = ["Загрузка категорий"]
           
        tfIdeaScope.inputView = picker
           
        pickerAccessory = UIToolbar()
        pickerAccessory?.autoresizingMask = .flexibleHeight
          
        // this customization is optional
        pickerAccessory?.barStyle = .default
        pickerAccessory?.barTintColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
        pickerAccessory?.backgroundColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
        pickerAccessory?.isTranslucent = false
        var frame = pickerAccessory?.frame
        frame?.size.height = 44.0
        pickerAccessory?.frame = frame!
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(AddIdeaStepOneViewController.cancelBtnClicked(_:)))// barButtonSystemItem: .cancel, target: self, action: #selector(AddIdeaStepOneViewController.cancelBtnClicked(_:)))
        cancelButton.tintColor = UIColor.white
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //a flexible space between the two buttons
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(AddIdeaStepOneViewController.doneBtnClicked(_:))) //(barButtonSystemItem: .done, target: self, action: #selector(AddIdeaStepOneViewController.doneBtnClicked(_:)))
        doneButton.tintColor = UIColor.white
        //Add the items to the toolbar
        pickerAccessory?.items = [cancelButton, flexSpace, doneButton]
        
        tfIdeaScope.inputAccessoryView = pickerAccessory
           
        // load
        updateViewState(
           signInCompletion:
           { text in
                                                                                                           // load Scopes
               if self._getContMng.scopeTypesList.count == 0
               {
                   self._getContMng.loadContent(byType: GetContentManager.CONTENT_TYPE_SCOPES,
                                              at: self._accMng.getAccessToken(),
                                              successCompletion:
                                              { text in
                                               print("load ok from add IDEA");
                                               // set picker for scope types
                                               DispatchQueue.main.async
                                               {
                                                   self.picker?.data = self._getContMng.getScopeStringList()
                                               }
                                              },
                                              errorCompletion:
                                              { text in
                                                   self.initLoadContentErrorAlert()
                                              })
               }
               else
               {
                   DispatchQueue.main.async
                   {
                       self.picker?.data = self._getContMng.getScopeStringList()
                   }
               }

                                                                                                               // load Raions
               if self._getContMng.raionTypeList.count == 0
               {
                   self._getContMng.loadContent(byType: GetContentManager.CONTENT_TYPE_RAIONS,
                                               at: self._accMng.getAccessToken(),
                                               successCompletion:
                                               { text in
                                                   print("load ok from add IDEA");

                                               },
                                               errorCompletion:
                                               { text in
                                                   self.initLoadContentErrorAlert()
                                               })
               }
               else
               {

               }


           },
           signOutCompletion:
           { text in
               // exit from add idea form if signuot status
               self._alertController.alert(in: self,
                                          withTitle: "Вход не выполнен",
                                          andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                          andActionTitle: "Войти",
                                          completion:
                                          { [unowned self] text in
                                               self.showAppView(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                          })
           })
           
    }
    
    /*
     *   Delegate methods
    **/
    /**
     *  Called when the cancel button of the `pickerAccessory` was clicked. Dismsses the picker
    **/
    @objc func cancelBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
    }
       
    /**
      *     Called when the done button of the `pickerAccessory` was clicked. Dismisses the picker and puts the selected value into the textField
    **/
    @objc func doneBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
        tfIdeaScope?.text = picker?.selectedValue
        
        _setController.currIdeaScope = _getContMng.getScopeIdByName(with: picker?.selectedValue ?? "")
        updateCompleteStepStatus()
    }
    
    private func updateViewState(signInCompletion signInCompFunc: @escaping ((String) -> ()),
                                 signOutCompletion signOutCompFunc: @escaping ((String) -> ()))
    {
        let signInStatus = _accMng.getAccessToken()
        self.stopActivityIndicate()
        
        if signInStatus == AccountManager.REQUEST_LOGIN
        {
            setViewState(in: AccountManager.STATE_SIGNOUT)
            signOutCompFunc("not signIn")
            
            // show error alert and relocate to login
            self._alertController.alert(in: self,
                                       withTitle: "Вход не выполнен",
                                       andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                       andActionTitle: "Войти",
                                       completion:
                                       { [unowned self] text in
                                            self.showAppView(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                       })
        }
        else if signInStatus == AccountManager.REQUEST_REFRESH_AT
        {
            startActivityIndicate()
            
            _accMng.refreshAccessToken(
            successCompletion:
            { [unowned self] text in
                self.stopActivityIndicate()
                self.setViewState(in: AccountManager.STATE_SIGNIN)
                
                signInCompFunc("signIn ok")
            },
            errorCompletion:
            { [unowned self] text in
                self.stopActivityIndicate()
                self.setViewState(in: AccountManager.STATE_SIGNOUT)
                    
                // show error alert and relocate to login
                self._alertController.alert(in: self,
                                           withTitle: "Вход не выполнен",
                                           andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                           andActionTitle: "Войти",
                                           completion:
                                           { [unowned self] text in
                                            signOutCompFunc("not signIn")
                                            self.showAppView(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                           })
                
            })
        }
        else
        {
           signInCompFunc("signIn ok")
        }
    }
    
    private func startActivityIndicate()
    {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    private func stopActivityIndicate()
    {
        activityIndicator.stopAnimating()
    }
    
    /*
     *   Error IU methods
    **/
    private func initLoadContentErrorAlert()
    {
        self._alertController.alert(in: self,
                                   withTitle: "Ошибка загрузки данных",
                                   andMsg: "Загрузка данных с сервера произошла с ошибкой, повторите позже!",
                                   andActionTitle: "Выйти из формы",
                                   completion:
                                   { [unowned self] text in
                                    self.showAppView(with: UIStoryboard.VIEW_TYPE_NAV_MENU)
                                   })
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
                self.btnNextStep.isEnabled = true
                self.tfIdeaScope.isEnabled = true
                
            }
        }
        else if stateType == AccountManager.STATE_SIGNOUT
        {
            DispatchQueue.main.async
            {
                self.btnNextStep.isEnabled = false
                self.tfIdeaScope.isEnabled = false
                
            }
        }
    }
       
}

extension AddIdeaStepOneViewController: NavigateDelegate
{
    func showAppView(with item: Int?)
    {
        guard let item = item else {return}
        print("Did select \(item)")
        let rootVC = AppDelegate.shared.rootViewController
        
        switch item
        {
        case UIStoryboard.VIEW_TYPE_LOGIN:
            rootVC.showLoginScreen()
        
        case UIStoryboard.VIEW_TYPE_NAV_MENU:
            rootVC.showMainMenu()
        default:
            break
        }
    }
}
