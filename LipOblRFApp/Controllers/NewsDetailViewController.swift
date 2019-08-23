//
//  NewsDetailViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 23/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class NewsDetailViewController: UITableViewController
{
    // outlets
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var labelAutor: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTextBody: UILabel!
    @IBOutlet weak var ivPic: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
    }
    
    /*
     *   -------- Public func ----------
     **/
    
    
    /*
     *   -------- Privete func ----------
     **/
    private func addListeners()
    {
        btnBack.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
    }
    
    @objc func didSelect(_ sender: UIButton)
    {
        switch sender
        {
        case btnBack:
            sidebarDidClose(with: UIStoryboard.VIEW_TYPE_NEWS_LIST)
        default:
            break
        }
    }
}

extension NewsDetailViewController: SidebarDelegate
{
    func sidbarDidOpen() {
        print("do nothing")
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
        
        default:
            break
        }
    }
}
