//
//  NewsDetailViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 23/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
import Kingfisher

class NewsDetailViewController: UITableViewController
{
    // outlets
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var labelDataStr: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    //@IBOutlet weak var labelTextBody: UILabel!
    @IBOutlet weak var ivPic: UIImageView!
    @IBOutlet weak var wvTextBody: UIWebView!
    
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    
    var loadActivityIndicator:UIActivityIndicatorView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
        initUI()
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
    
    
    private func initUI()
    {
        // init ai
        DispatchQueue.main.async
        {
             self.loadActivityIndicator = UIActivityIndicatorView(style: .gray)
             self.loadActivityIndicator?.center = self.view.center
             self.view.addSubview(self.loadActivityIndicator!)
             self.loadActivityIndicator?.hidesWhenStopped = true
        }
        
        // set content from Model
        let newsId = _getContMng.currentNews
        
        labelTitle.text = _getContMng.loadedNewsList[newsId].title
        
        wvTextBody.loadHTMLString(_getContMng.loadedNewsList[newsId].content, baseURL: nil)
        
        labelDataStr.text = _getContMng.currentNewsDateStr
        labelTime.text = _getContMng.currentNewsDateTime
        
        let urlStr = self._getContMng.loadedNewsList[newsId].imgs[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let imgUrl = URL(string: urlStr)
        
        ivPic.kf.setImage(
            with: imgUrl,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
    }
    
    private func showActivityIndicatory()
    {
        DispatchQueue.main.async
        {
                self.loadActivityIndicator?.startAnimating()
        }
    }
    private func hideActivityIndicatory()
    {
        DispatchQueue.main.async
        {
                self.loadActivityIndicator?.stopAnimating()
        }
    }
}

extension NewsDetailViewController: SidebarDelegate
{
    func sidbarDidOpen()
    {
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
