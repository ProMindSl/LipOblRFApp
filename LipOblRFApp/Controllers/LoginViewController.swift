//
//  LoginViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//


import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tfLogin: UITextField!
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    var loginUserParams = [
        "userID" : "none",
        "userLogin" : "none",
        "fio" : "none",
        "role" : "none",
        "cls" : []
        ] as [String : Any]
    let accMng = AccountManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(accMng.API_ANS_TYPE_ACCESS_TOKEN_INVALID)
        
        // ui options
        tfPass.isSecureTextEntry = true
        
    }
    
    /*
     *   Outlet methods
     **/
    @IBAction func OpenMenu(_ sender: Any) {
        SidebarLauncher(delegate: self ).show()
    }
    
    @IBAction func signInAction(_ sender: Any) {
        
        guard let login = tfLogin.text else { return }
        guard let pass = tfPass.text else { return }
        
        // init signIn process
        accMng.signIn(as: login,
                      withPass: pass,
                      successCompletion:
            { [unowned self] text in
                self.loginUserParams = self.accMng.getUserParsms()
                print(self.loginUserParams["fio"] ?? "none data")
                // show success/fail alert
                DispatchQueue.main.async
                    {
                        self.stopActivityIndicate()
                        self.tfLogin.isUserInteractionEnabled = true
                        self.tfPass.isUserInteractionEnabled = true
                        self.btnSignIn.isUserInteractionEnabled = true
                        
                        self.openSignInAlert(with: self.accMng.apiANS);
                }
            },
                      errorCompletion:
            { [unowned self] text in
                DispatchQueue.main.async
                    {
                        self.stopActivityIndicate()
                        self.tfLogin.isUserInteractionEnabled = true
                        self.tfPass.isUserInteractionEnabled = true
                        self.btnSignIn.isUserInteractionEnabled = true
                        
                        self.openSignInAlert(with: self.accMng.apiANS);
                        print("Error in")
                }
            }
            
        )
        
        // diactivate ui until signIn request complete
        startActivityIndicate()
        tfLogin.isUserInteractionEnabled = false
        tfPass.isUserInteractionEnabled = false
        btnSignIn.isUserInteractionEnabled = false
        
    }
    
    /*
     *   UI show/close methods
     **/
    func openSignInAlert(with code: String)
    {
        var message = ""
        var msgTitle = ""
        // seccess authentication
        if code == accMng.API_ANS_TYPE_GET_TOKEN_SUCCES
            && accMng.currentSignState == accMng.STATE_SIGNIN
        {
            msgTitle = "Вход выполнен"
            message = "Добро пожаловать, \(self.loginUserParams["fio"] as! String) !"
        }
        else // not success authentication
        {
            msgTitle = "Вход не выполнен: "
            
            switch code
            {
            case accMng.API_ANS_TYPE_INVALID_USER,
                 accMng.API_ANS_TYPE_USER_LOGIN_NOT_EXTIST:
                message = "Логин пользователя не найден"
                
            case accMng.API_ANS_TYPE_PASSWORD_INCORRECT:
                message = "Пароль неверный"
                
            case accMng.API_ANS_TYPE_NOT_DB_CONNECTION:
                message = "Сервер аутентификации не доступен"
                
            case accMng.API_ANS_TYPE_UNKNOWN_ERROR:
                message = "Неизвестная ошибка"
                
            default:
                message = "Неизвестная ошибка"
            }
        }
        
        
        let alert = UIAlertController(title: msgTitle, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler:
        { (alert: UIAlertAction!) in
            // if signIn - ok? exit from login view to news page
            if self.accMng.currentSignState == self.accMng.STATE_SIGNIN
            {
                let v = UIStoryboard.main.LaunchNewsVC()
                self.present(v!, animated: true)
                
            }
        })
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicate()
    {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    func stopActivityIndicate()
    {
        activityIndicator.stopAnimating()
    }
    
}

extension LoginViewController: SidebarDelegate{
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
        case 0:
            let v = UIStoryboard.main.LaunchNewsVC()
            present(v!, animated: true)
        case 1:
            let v = UIStoryboard.main.IdeasVC()
            present(v!, animated: true)
        case 2:
            break
        /*case 3:
            let v = UIStoryboard.main.NewsListVC()
            present(v!, animated: true)
          */
        case 4:
            break
        default:
            break
        }
    }
}

