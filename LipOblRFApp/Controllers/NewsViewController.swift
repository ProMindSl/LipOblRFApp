//
//  NewsViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tabBtnNews: UIButton!
    @IBOutlet weak var tabBtnIdeaClimeMenu: UIButton!
    
    
    // cell count from Model
    private var _cellCount = 5
    private var _cellReuseIdentifier = "newsCell"
    private var _cellHeight = 358.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellReuseIdentifier, for: indexPath) as! NewsViewCell
        cell.ivNewsPic.image = UIImage(named: "newsImageCut.jpg")
        
        // add listener for news discription
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sidebarDidClose(with: UIStoryboard.VIEW_TYPE_NEWS_DETAIL)
    }
    
    
    @IBAction func openMenu(_ sender: Any)
    {
        SidebarLauncher(delegate: self ).show()
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
            break
        case tabBtnIdeaClimeMenu:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_IDEACLIME_MENU)
        default:
            break
        }
    }
}

extension NewsViewController: SidebarDelegate
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
            break
        case UIStoryboard.VIEW_TYPE_IDEAS_LIST:
            rootVC.showIdeaList()
        case UIStoryboard.VIEW_TYPE_LOGIN:
            rootVC.showLoginScreen()
        case UIStoryboard.VIEW_TYPE_ADD_IDEA_FORM:
            rootVC.showAddIdeaForm()
        case UIStoryboard.VIEW_TYPE_IDEACLIME_MENU:
            rootVC.showIdeaClimeMenu()
        case UIStoryboard.VIEW_TYPE_NEWS_DETAIL:
            rootVC.showNewsDitail()
        default:
            break
        }
    }
}
