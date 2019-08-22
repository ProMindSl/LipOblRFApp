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
    
    private let setController = SetContentController()
    
    // type picker vars
    var picker: TypePickerView?
    var pickerAccessory: UIToolbar?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initUI()
        updateViewState(
            signInCompletion:
            { text in
                print("signIn - ok")
            },
            signOutCompletion:
            { text in
                print("signOut")
            })
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
    private func updateViewState(signInCompletion signInCompFunc: @escaping ((String) -> ()),
                                 signOutCompletion signOutCompFunc: @escaping ((String) -> ()))
    {
        let signInStatus = accMng.getAccessToken()
        self.stopLoadIndication()
        
        if signInStatus == AccountManager.REQUEST_LOGIN
        {
            setViewState(in: AccountManager.STATE_SIGNOUT)
            signOutCompFunc("not signIn")
            
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
                
                signInCompFunc("signIn ok")
            },
            errorCompletion:
            { [unowned self] text in
                self.stopLoadIndication()
                self.setViewState(in: AccountManager.STATE_SIGNOUT)
                    
                // show error alert and relocate to login
                self.alertController.alert(in: self,
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
            let signStatusOk = AccountManager.STATE_SIGNIN
            setViewState(in: signStatusOk)
            
            signInCompFunc("signIn ok")
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
        let scope = 6 //tfIdeaScope.text                                                // gettiog input data
        let title = tfIdeaTitle.text ?? "Пустой заголовок"
        let body = tfIdeaTxtBody.text ?? "Пустое описание"
        let raion = 1
        let longitude = 52.322343
        let latitude = 53.231232
        
        var errMsg = ""
        
        if scope == 0                                                                   // check data in inputs
        {
            errMsg = "Категория идеи не выбрана"
        }
        else if title == "" || title == "Пустой заголовок"
        {
            errMsg = "Поле названия идеи пустое"
        }
        else if body == "" || body == "Пустое описание"
        {
            errMsg = "Поле с описанием идеи пустое"
        }
        else if raion == 0 // !!!!!! внести проверку с запросом в API на принадлежность к одному из типов
        {
            errMsg = "Район (адрес) не определен"
        }
        else if longitude == 0 || latitude == 0
        {
            errMsg = "Метка расположения не задана на карте"
        }
        else                                                                            // if all requared inputs - ok
        { print("in here")
            // Check SignIn status and get at from account manager
            updateViewState(signInCompletion:                                           // signIn status - ok
            { [unowned self] text in
                let at = self.accMng.getAccessToken()
                self.setController.createIdea(withTitle: title,
                                             body: body,
                                             scope: scope,
                                             region: raion,
                                             longitude: longitude,
                                             latitude: latitude,
                                             at: at,
                                             successCompletion:                         // add idea success complete
                                             { [unowned self] text in
                                                // present alert about success Idea add
                                                self.alertController.alert(in: self,
                                                                      withTitle: "Получилось!",
                                                                      andMsg: "Ваша идея успешно отправлена на модерацию",
                                                                      andActionTitle: "Ок",
                                                                      completion:
                                                                      { [unowned self] text in
                                                                        DispatchQueue.main.async
                                                                        {
                                                                            self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEAS_LIST)
                                                                        }
                                                                      })
                                             },
                                             errorCompletion:                           // add idea error complete
                                             { [unowned self] text in
                                                
                                                // create api answer type string
                                                var ansMsg = ""
                                                switch self.accMng.apiANS
                                                {
                                                case APIVals.API_ANS_TYPE_NOT_DB_CONNECTION:
                                                    ansMsg = "Нет соединения с базой данных"
                                                case APIVals.API_ANS_TYPE_ACCESS_TOKEN_INVALID:
                                                    ansMsg = "Сессия недействительна"
                                                case APIVals.API_ANS_TYPE_HAS_NOT_CREDENTIALS:
                                                    ansMsg = "Недостаточно прав у текущего пользователя"
                                                case APIVals.API_ANS_TYPE_INVALID_INPUT_DATA:
                                                    ansMsg = "Ошибочные входные данные"
                                                default:
                                                    ansMsg = "Неизвестная ошибка"
                                                    break
                                                }
                                                
                                                // present alert about error Idea add
                                                self.alertController.alert(in: self,
                                                                           withTitle: "Ошибка!",
                                                                           andMsg: ansMsg,
                                                                           andActionTitle: "Ок",
                                                                           completion:
                                                    { [unowned self] text in
                                                        DispatchQueue.main.async
                                                        {
                                                            self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEAS_LIST)
                                                        }
                                                    })
                                             })
                    
            },
            signOutCompletion:                                                        // signOut status
            { text in
                print("out from form")
            })
            
            
            
            
        }
        
        if errMsg != ""                                                               // if One of requared inputs - not ok
        {
            alertController.alert(in: self,
                                  withTitle: "Не все поля заполнены",
                                  andMsg: errMsg,
                                  andActionTitle: "Заполнить",
                                  completion:
                                  { text in
                                    print("coloring error inputs")
                                  })
        }
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
