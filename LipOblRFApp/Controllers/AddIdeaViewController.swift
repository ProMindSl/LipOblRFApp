//
//  AddIdeaViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
import MapKit

class AddIdeaViewController: UITableViewController,
                             UITextFieldDelegate,
                             MKMapViewDelegate
    
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
    private let _accMng = AccountManager.shared
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    // other mngs init
    private let _setController = SetContentManager()
    
    // type picker vars
    var picker: TypePickerView?
    var pickerAccessory: UIToolbar?
    
    // current idea input vars
    private var _currLatitude: Double = 0.0
    private var _currLongitude: Double = 0.0
    private var _currRaionFromMap: String = ""
    private var _currRaionId = 0
    private var _currCountryCode: String = "none"
    private var _currStreet = "none"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initUI()
//        updateViewState(
//            signInCompletion:
//            { text in
//                print("signIn - ok")
//            },
//            signOutCompletion:
//            { text in
//                print("signOut")
//            })
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
        picker?.data = ["Загрузка категорий"]
        
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
        
        // listeners
        btnBack.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        
        // set text field keyboard settings
        tfIdeaTitle.delegate = self
        tfIdeaTxtBody.delegate = self
        
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
                                            self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                       })
        })
        
        // init Map recognizer
        let recognizer = UILongPressGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handleLongPressGesture(_:)))
        mvIdeaLocation.addGestureRecognizer(recognizer)
    }
    
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        // remove old annotation
        let allAnnotations = mvIdeaLocation.annotations
        mvIdeaLocation.removeAnnotations(allAnnotations)
        
        // get coords
        let location = gestureRecognizer.location(in: mvIdeaLocation)
        let coordinate = mvIdeaLocation.convert(location,toCoordinateFrom: mvIdeaLocation)
        // update global coords
        _currLatitude = coordinate.latitude
        _currLongitude = coordinate.longitude
        
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mvIdeaLocation.addAnnotation(annotation)
        
        // get address for touch coordinates.
        let geoCoder = CLGeocoder()
        let locationT = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(locationT, completionHandler:
        {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else { return }

            
                // Street address
                if let street = placeMark.thoroughfare
                {
                    print(street)
                    self._currStreet = street
                }
                // City
                if let raion = placeMark.subAdministrativeArea
                {
                    print(raion)
                    self._currRaionFromMap = raion
                    self._currRaionId = self._getContMng.getRaionIdByString(by: String(raion))
                }
                // Zip code
                if let countryCode = placeMark.isoCountryCode
                {
                    print(countryCode)
                    self._currCountryCode = countryCode
                }
            
        })
    }
    
    @objc func didSelect(_ sender: UIButton)
    {
        switch sender
        {
        case btnBack:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEACLIME_MENU)
        default:
            break
        }
    }
    
    /*
     *   Delegate methods
     **/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
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
        let signInStatus = _accMng.getAccessToken()
        self.stopLoadIndication()
        
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
                self.setViewState(in: AccountManager.STATE_SIGNIN)
                
                signInCompFunc("signIn ok")
            },
            errorCompletion:
            { [unowned self] text in
                self.stopLoadIndication()
                self.setViewState(in: AccountManager.STATE_SIGNOUT)
                    
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
                                        self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEACLIME_MENU)
                                   })
    }
    
    /*
     *   Handlers
    **/
    @IBAction func didSelectAddIdea(_ sender: Any)
    {
        let scope = _getContMng.getScopeIdByName(with: tfIdeaScope.text ?? "none")  // gettiog input data
        let title = tfIdeaTitle.text ?? "Пустой заголовок"
        let body = tfIdeaTxtBody.text ?? "Пустое описание"
        let raion = _currRaionId
        let longitude = _currLongitude
        let latitude = _currLatitude
        
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
        else if raion == 0 
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
                let at = self._accMng.getAccessToken()
                self._setController.createIdea(withTitle: title,
                                             body: body,
                                             scope: scope,
                                             region: raion,
                                             longitude: longitude,
                                             latitude: latitude,
                                             at: at,
                                             successCompletion:                         // add idea success complete
                                             { [unowned self] text in
                                                // present alert about success Idea add
                                                self._alertController.alert(in: self,
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
                                                switch self._accMng.apiANS
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
                                                self._alertController.alert(in: self,
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
            _alertController.alert(in: self,
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
        let rootVC = AppDelegate.shared.rootViewController
        
        switch item
        {
        case UIStoryboard.VIEW_TYPE_NEWS_LIST:
            //let v = UIStoryboard.main.LaunchNewsVC()
            //present(v!, animated: true)
            rootVC.showNewsList()
        case UIStoryboard.VIEW_TYPE_IDEAS_LIST:
            //let v = UIStoryboard.main.IdeasVC()
            //present(v!, animated: true)
            rootVC.showIdeaList()
        case UIStoryboard.VIEW_TYPE_LOGIN:
            //let v = UIStoryboard.main.LoginVC()
            //present(v!, animated: true)
            rootVC.showLoginScreen()
        case UIStoryboard.VIEW_TYPE_ADD_IDEA_FORM:
            break
        case UIStoryboard.VIEW_TYPE_IDEACLIME_MENU:
            rootVC.showIdeaClimeMenu()
        default:
            break
        }
    }
}
