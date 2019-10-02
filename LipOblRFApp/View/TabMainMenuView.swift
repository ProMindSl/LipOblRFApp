//
//  TabMainMenuView.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 26/09/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class TabMainMenuView: UIView
{
    public static let MENU_STATE_NONE = 0
    public static let MENU_STATE_MAIN = 1
    public static let MENU_STATE_SERVICES = 2
    public static let MENU_STATE_NEWS = 3
    public static let MENU_STATE_PROFILE = 4
    
    @IBOutlet weak var btnMenuMain: UIButton!
    @IBOutlet weak var btnMenuServices: UIButton!
    @IBOutlet weak var btnMenuNews: UIButton!
    @IBOutlet weak var btnMenuProfile: UIButton!
    
    
    override func draw(_ rect: CGRect)
    {
        let borderColorFromHash = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) //UIMethods.hexStringToUIColor(hex: "#808080") as UIColor
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColorFromHash.cgColor
        
        addListeners()
    }
    
    public func setState(withType type: Int)
    {
        switch type
        {
        case TabMainMenuView.MENU_STATE_NONE:
            btnMenuMain.setImage(UIImage(named: "tab_btn_main.png"), for: .normal)
            btnMenuServices.setImage(UIImage(named: "tab_btn_services.png"), for: .normal)
            btnMenuNews.setImage(UIImage(named: "tab_btn_news.png"), for: .normal)
            btnMenuProfile.setImage(UIImage(named: "tab_btn_profile.png"), for: .normal)
        case TabMainMenuView.MENU_STATE_MAIN:
            btnMenuMain.setImage(UIImage(named: "tab_btn_active_main.png"), for: .normal)
            btnMenuServices.setImage(UIImage(named: "tab_btn_services.png"), for: .normal)
            btnMenuNews.setImage(UIImage(named: "tab_btn_news.png"), for: .normal)
            btnMenuProfile.setImage(UIImage(named: "tab_btn_profile.png"), for: .normal)
        case TabMainMenuView.MENU_STATE_SERVICES:
            btnMenuMain.setImage(UIImage(named: "tab_btn_main.png"), for: .normal)
            btnMenuServices.setImage(UIImage(named: "tab_btn_active_services.png"), for: .normal)
            btnMenuNews.setImage(UIImage(named: "tab_btn_news.png"), for: .normal)
            btnMenuProfile.setImage(UIImage(named: "tab_btn_profile.png"), for: .normal)
        case TabMainMenuView.MENU_STATE_NEWS:
            btnMenuMain.setImage(UIImage(named: "tab_btn_main.png"), for: .normal)
            btnMenuServices.setImage(UIImage(named: "tab_btn_services.png"), for: .normal)
            btnMenuNews.setImage(UIImage(named: "tab_btn_active_news.png"), for: .normal)
            btnMenuProfile.setImage(UIImage(named: "tab_btn_profile.png"), for: .normal)
        case TabMainMenuView.MENU_STATE_PROFILE:
            btnMenuMain.setImage(UIImage(named: "tab_btn_main.png"), for: .normal)
            btnMenuServices.setImage(UIImage(named: "tab_btn_services.png"), for: .normal)
            btnMenuNews.setImage(UIImage(named: "tab_btn_news.png"), for: .normal)
            btnMenuProfile.setImage(UIImage(named: "tab_btn_active_profile.png"), for: .normal)
        default:
            break
        }
    }
    
    private func addListeners()
    {
        [btnMenuMain, btnMenuServices, btnMenuNews, btnMenuProfile].forEach(
        {
              $0?.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        })
    }
        
    /*
     *   btn click methods
    **/
    @objc func didSelect(_ sender: UIButton)
    {
        let rootVC = AppDelegate.shared.rootViewController
            
        switch sender
        {
        case btnMenuProfile:
            rootVC.showLoginScreen()
        case btnMenuNews:
            rootVC.showNewsList()
        case btnMenuMain:
            rootVC.showMainMenu()
        default:
            break
        }
    }

}
