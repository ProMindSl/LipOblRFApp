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
    
    // cell count from Model
    private var _cellCount = 5
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
        
        // set bg for cell
        if (indexPath.row % 2) == 0
        {
            cell.ivBG.image = UIImage(named: "btn_bg_idea1.png")
        }
        else
        {
            cell.ivBG.image = UIImage(named: "btn_bg_idea2.png")
        }
        
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
        default:
            break
        }
    }
}

