//
//  AddIdeaViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
import MapKit

class AddIdeaClaimShortViewController:  UITableViewController,
                                        UITextFieldDelegate,
                                        MKMapViewDelegate,
                                        CLLocationManagerDelegate,
                                        UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate
    
{
    // outlets
    @IBOutlet weak var tfIdeaScope: UITextField!
    @IBOutlet weak var tfIdeaTitleAdress: UITextField!
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var mvIdeaLocation: MKMapView!
    //@IBOutlet weak var tfIdeaTitle: UITextField!
    @IBOutlet weak var tfIdeaTxtBody: UITextField!
    @IBOutlet weak var btnAddIdea: LRAppButton!
    @IBOutlet weak var btnAddFiles: LRAppButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var indLoadState: UIActivityIndicatorView!
    
    // st links
    private let _accMng = AccountManager.shared
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    // other mngs init
    private let _setController = SetContentManager.shared
        
    // ui view local vars
    private var picker: TypePickerView?
    private var pickerAccessory: UIToolbar?
    
    private var picker2: TypePickerView?
    private var pickerAccessory2: UIToolbar?
    
    private var locationManager = CLLocationManager()
    
    private var imagePicker = UIImagePickerController()
    
    // current add type
    private var _currentAddType = "none"
    // current idea/claim input vars
    private var _currLatitude: Double = 0.0
    private var _currLongitude: Double = 0.0
    private var _currRaionFromMap: String = ""
    private var _currRaionId = 0
    private var _currCountryCode: String = "none"
    private var _currStreet = "none"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // init ui elements
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mvIdeaLocation?.setRegion(region, animated: true)
        }
    }
    
    /*
     *   -------- Privete func ----------
    **/
    private func initUI()
    {
        // init btns
        btnAddIdea.setViewType(with: LRAppButton.TYPE_RED)
        btnAddFiles.setViewType(with: LRAppButton.TYPE_ALPHA_RED_TITLE)
        // listeners
        btnBack.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        
        // init picker for scope switcher
        picker = TypePickerView()
        picker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker?.backgroundColor = UIColor.white
        picker?.data = ["Загрузка категорий"]
        tfIdeaScope.inputView = picker
        pickerAccessory = UIToolbar()
        pickerAccessory?.autoresizingMask = .flexibleHeight
        // view customization
        pickerAccessory?.barStyle = .default
        pickerAccessory?.barTintColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
        pickerAccessory?.backgroundColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
        pickerAccessory?.isTranslucent = false
        var frame = pickerAccessory?.frame
        frame?.size.height = 44.0
        pickerAccessory?.frame = frame!
        let cancelButton = UIBarButtonItem(title: "Отмена",
                                           style: .done,
                                           target: self,
                                           action: #selector(AddIdeaClaimShortViewController.cancelBtnClicked(_:)))
        cancelButton.tintColor = UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)
        let doneButton = UIBarButtonItem(title: "Выбрать",
                                         style: .done,
                                         target: self,
                                         action: #selector(AddIdeaClaimShortViewController.doneBtnClicked(_:)))
        doneButton.tintColor = UIColor.white
        //Add the items to the toolbar
        pickerAccessory?.items = [cancelButton, flexSpace, doneButton]
        tfIdeaScope.inputAccessoryView = pickerAccessory
                
        // init picker for type switcher
        picker2 = TypePickerView()
        picker2?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker2?.backgroundColor = UIColor.white
        picker2?.data = [GetContentManager.ADD_TYPE_IDEA, GetContentManager.ADD_TYPE_CLAIM]
        tfType.inputView = picker2
        pickerAccessory2 = UIToolbar()
        pickerAccessory2?.autoresizingMask = .flexibleHeight
        pickerAccessory2?.barStyle = .default
        pickerAccessory2?.barTintColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
        pickerAccessory2?.backgroundColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
        pickerAccessory2?.isTranslucent = false
        pickerAccessory2?.frame = frame!
        let cancelButton2 = UIBarButtonItem(title: "Отмена",
                                            style: .done,
                                            target: self,
                                            action: #selector(AddIdeaClaimShortViewController.cancelBtnClickedForTypeSwitcher(_:)))
        cancelButton2.tintColor = UIColor.white
        let doneButton2 = UIBarButtonItem(title: "Выбрать",
                                          style: .done,
                                          target: self,
                                          action: #selector(AddIdeaClaimShortViewController.doneBtnClickedForTypeSwitcher(_:)))
        doneButton2.tintColor = UIColor.white
        //Add the items to the toolbar
        pickerAccessory2?.items = [cancelButton2, flexSpace, doneButton2]
        tfType.inputAccessoryView = pickerAccessory2
                        
        // set text field keyboard settings
        tfIdeaTitleAdress.delegate = self
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
        mvIdeaLocation?.addGestureRecognizer(recognizer)
        
        mvIdeaLocation?.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true
        {
            
            if CLLocationManager.authorizationStatus() == .restricted
            || CLLocationManager.authorizationStatus() == .denied
            ||  CLLocationManager.authorizationStatus() == .notDetermined
            {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        else
        {
            print("location services or GPS is off")
        }
        
        // init ui photo
        imagePicker.delegate = self
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

            
                // City
                if let raion = placeMark.subAdministrativeArea
                {
                    print(raion)
                    self._currRaionFromMap = raion
//                    if self.tfIdeaTitleAdress.text! != raion
//                    {
//                        self.tfIdeaTitleAdress.text! += raion
//                    }
                      self.tfIdeaTitleAdress.text! = raion
                    self._currRaionId = self._getContMng.getRaionIdByString(by: String(raion))
                    if self._currRaionId == 0
                    {
                        self._alertController.alert(in: self,
                                               withTitle: "Ошибка определения Липецкого района",
                                               andMsg: "Убедитесь, что метка определена в границах Липецкой области",
                                               andActionTitle: "Повторить",
                                               completion:
                                               { text in
                                                
                        })
                    }
                    else
                    {
                        self._alertController.alert(in: self,
                                                    withTitle: "Район определен",
                                                    andMsg: "\(self._currRaionFromMap) \((self._currStreet != "none" ? ", "+self._currStreet : ""))",
                                                    andActionTitle: "Продолжить",
                                                    completion:
                            { text in
                                
                        })
                    }
                }
                // Street address
                if let street = placeMark.thoroughfare
                {
                    print(street)
                    self._currStreet = street
                    self.tfIdeaTitleAdress.text = street
                    if let raion = placeMark.subAdministrativeArea
                    {
                        self.tfIdeaTitleAdress.text! += ", "+raion
                    }
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
    
    // ui photo methods
    @IBAction func buttonOnClick(_ sender: UIButton)
    {
        self.setOffBtnInterraction()
        let color = #colorLiteral(red: 0.9973761439, green: 0.3234748244, blue: 0.2775879204, alpha: 1)
        
        let alert = UIAlertController(title: "Выбор фото",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Камера",
                                      style: .default,
                                      handler:
                                      { _ in
                                        self.openCamera()
                                      })
        actionCamera.setValue(color, forKey: "titleTextColor")

        let actionGalery = UIAlertAction(title: "Галерея",
                                      style: .default,
                                      handler:
                                      { _ in
                                        self.openGallary()
                                      })
        actionGalery.setValue(color, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction.init(title: "Отмена",
                                           style: .cancel,
                                           handler:
                                           { _ in
                                                self.setOnBtnInterraction()
                                           })
        actionCancel.setValue(color, forKey: "titleTextColor")
        
        alert.addAction(actionCamera)
        alert.addAction(actionGalery)
        alert.addAction(actionCancel)
        
        // Crash on iPad
        switch UIDevice.current.userInterfaceIdiom
        {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }

        self.present(alert, animated: true, completion: nil)
    }

    func openCamera()
    {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Внимание!", message: "Камера на устройстве отсутствует", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.setOnBtnInterraction()
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
//            imageView.contentMode = .scaleAspectFit
//            imageView.image = pickedImage
            print("photo ok! ")
        }
     
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.setOnBtnInterraction()
        
        dismiss(animated: true, completion: nil)
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
                self.tfIdeaTitleAdress.isEnabled = true
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
                self.tfIdeaTitleAdress.isEnabled = false
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
    private func setOffBtnInterraction()
    {
        let color = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.btnAddFiles.setTitleColor(color, for: .normal)
        self.btnAddFiles.isUserInteractionEnabled = false
    }
    private func setOnBtnInterraction()
    {
        let color = #colorLiteral(red: 0.9973761439, green: 0.3234748244, blue: 0.2775879204, alpha: 1)
        self.btnAddFiles.setTitleColor(color, for: .normal)
        self.btnAddFiles.isUserInteractionEnabled = true
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
        let title = tfIdeaTitleAdress.text ?? "Адрес отсутствует"
        let body = tfIdeaTxtBody.text ?? "Пустое описание"
        let raion = _currRaionId
        let longitude = _currLongitude
        let latitude = _currLatitude
        
        var errMsg = ""
        
        if _currentAddType == "none"
        {
            errMsg = "Тип предложения не выбран"
        }
        if scope == 0                                                                   // check data in inputs
        {
            errMsg = "Категория идеи не выбрана"
        }
        else if title == "" || title == "Пустой заголовок"
        {
            errMsg = "Поле c адресом пустое"
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
                // get valid access token
                let at = self._accMng.getAccessToken()
                // for Idea-type form create IDEA
                if self._currentAddType == GetContentManager.ADD_TYPE_IDEA
                {
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
                }
                // for Claim-type form create CLAIM
                else if self._currentAddType == GetContentManager.ADD_TYPE_CLAIM
                {
                    self._setController.createClaim(withTitle: title,
                                               body: body,
                                               scope: scope,
                                               region: raion,
                                               longitude: longitude,
                                               latitude: latitude,
                                               at: at,
                                               successCompletion:                         // add claim success complete
                                               { [unowned self] text in
                                                // present alert about success Idea add
                                                self._alertController.alert(in: self,
                                                                            withTitle: "Получилось!",
                                                                            andMsg: "Ваша жалоба успешно отправлена на модерацию",
                                                                            andActionTitle: "Ок",
                                                                            completion:
                                                                            { [unowned self] text in
                                                                                DispatchQueue.main.async
                                                                                {
                                                                                    self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEAS_LIST)
                                                                                }
                                                                            })
                                                },
                                                errorCompletion:                                                    // add claim error complete
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
                }
                    
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
    @objc func cancelBtnClickedForTypeSwitcher(_ button: UIBarButtonItem?)
    {
        tfType?.resignFirstResponder()
    }
    
    /**
    * Called when the done button of the `pickerAccessory` was clicked. Dismisses the picker and puts the selected value into the textField
    **/
    @objc func doneBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
        tfIdeaScope.text = picker?.selectedValue
    }
    @objc func doneBtnClickedForTypeSwitcher(_ button: UIBarButtonItem?)
    {
        tfType?.resignFirstResponder()
        tfType.text = picker2?.selectedValue
        _currentAddType = picker2?.selectedValue ?? "none"
    }
    
}

extension AddIdeaClaimShortViewController: SidebarDelegate
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
            rootVC.showIdeaList()
        case UIStoryboard.VIEW_TYPE_LOGIN:
            rootVC.showLoginScreen()
        case UIStoryboard.VIEW_TYPE_ADD_IDEA_FORM:
            break
        case UIStoryboard.VIEW_TYPE_IDEACLIME_MENU:
            rootVC.showMainMenu()
        default:
            break
        }
    }
}
