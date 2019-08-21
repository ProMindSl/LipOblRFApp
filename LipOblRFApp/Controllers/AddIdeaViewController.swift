//
//  AddIdeaViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
import MapKit

class AddIdeaViewController: UITableViewController
{

    // outlets
    @IBOutlet weak var tfIdeaScope: UITextField!
    @IBOutlet weak var tfMapSearch: UITextField!
    @IBOutlet weak var mvIdeaLocation: MKMapView!
    @IBOutlet weak var tfIdeaTitle: UITextField!
    @IBOutlet weak var tfIdeaTxtBody: UITextField!
    @IBOutlet weak var btnAddIdea: UIButton!
    @IBOutlet weak var btnAddFiles: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var indLoadState: UIActivityIndicatorView!
    
    // st links
    private let accMng = AccountManager.shared
    private let alertController = AlertController.shared
    
    // type picker vars
    var picker: TypePickerView?
    var pickerAccessory: UIToolbar?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initUI()
        updateViewState()
    }
    
    /*
     *   -------- Public func ----------
    **/
    
    
    /*
     *   -------- Privete func ----------
    **/
    private func initUI()
    {
        // init picker
        picker = TypePickerView()
        picker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker?.backgroundColor = UIColor.white
        picker?.data = ["Бизнес", "Благо­­устрой­­ство", "Борьба с коррупцией", "Демография", "Дороги и транспорт"]
        
        tfIdeaScope.inputView = picker
        
        pickerAccessory = UIToolbar()
        pickerAccessory?.autoresizingMask = .flexibleHeight
        
        //this customization is optional
        pickerAccessory?.barStyle = .default
        pickerAccessory?.barTintColor = UIColor.blue
        pickerAccessory?.backgroundColor = UIColor.blue
        pickerAccessory?.isTranslucent = false
        var frame = pickerAccessory?.frame
        frame?.size.height = 44.0
        pickerAccessory?.frame = frame!
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddIdeaViewController.cancelBtnClicked(_:)))
        cancelButton.tintColor = UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //a flexible space between the two buttons
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddIdeaViewController.doneBtnClicked(_:)))
        doneButton.tintColor = UIColor.white
        //Add the items to the toolbar
        pickerAccessory?.items = [cancelButton, flexSpace, doneButton]
        tfIdeaScope.inputAccessoryView = pickerAccessory
        

        
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
                self.btnAddFiles.isEnabled = true
                //self.btnAddIdea.isEnabled = true
                self.tfIdeaScope.isEnabled = true
                self.tfMapSearch.isEnabled = true
                self.tfIdeaTitle.isEnabled = true
                self.tfIdeaTxtBody.isEnabled = true
                
                //self.btnAddIdea.isHidden = false
            }
        }
        else if stateType == AccountManager.STATE_SIGNOUT
        {
            DispatchQueue.main.async
            {
                self.btnAddFiles.isEnabled = false
                //self.btnAddIdea.isEnabled = false
                self.tfIdeaScope.isEnabled = false
                self.tfMapSearch.isEnabled = false
                self.tfIdeaTitle.isEnabled = false
                self.tfIdeaTxtBody.isEnabled = false
                
                //self.btnAddIdea.isHidden = true
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
            
            // show error alert and relocate to login
            self.alertController.alert(in: self,
                                       withTitle: "Вход не выполнен",
                                       andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                       andActionTitle: "Авторизироваться",
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
                    
                // show error alert and relocate to login
                self.alertController.alert(in: self,
                                           withTitle: "Вход не выполнен",
                                           andMsg: "Раздел доступен только для зарегистрированных пользователей",
                                           andActionTitle: "Авторизироваться",
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
            self.indLoadState.isHidden = false
            self.indLoadState.startAnimating()
        }
    }
    private func stopLoadIndication()
    {
        DispatchQueue.main.async
        {
            self.indLoadState.isHidden = true
            self.indLoadState.stopAnimating()
        }
    }
    
    /*
     *   Handlers
    **/
    @IBAction func didSelectAddIdea(_ sender: Any)
    {
        
    }
    
    /**
    * Called when the cancel button of the `pickerAccessory` was clicked. Dismsses the picker
    **/
    @objc func cancelBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
    }
    
    /**
    * Called when the done button of the `pickerAccessory` was clicked. Dismisses the picker and puts the selected value into the textField
    **/
    @objc func doneBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
        tfIdeaScope.text = picker?.selectedValue
    }
    
}

extension AddIdeaViewController: SidebarDelegate
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
