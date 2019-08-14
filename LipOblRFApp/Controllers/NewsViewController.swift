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
    // cell count from Model
    private var _cellCount = 5
    private var _cellReuseIdentifier = "newsCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellReuseIdentifier, for: indexPath) as! NewsViewCell
        
        
        return cell
    }
    
    
    @IBAction func openMenu(_ sender: Any)
    {
        SidebarLauncher(delegate: self ).show()
    }
    /*@IBAction func OpenMenu(_ sender: Any) {
        SidebarLauncher(delegate: self ).show()
    }*/
    
}
extension NewsViewController: SidebarDelegate{
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
            break
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
