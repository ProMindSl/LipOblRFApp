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
    @IBOutlet weak var tvNewsList: UITableView!
    
    var loadActivityIndicator:UIActivityIndicatorView?
    
    // cell count from Model
    private var _cellCount = 0
    private var _cellReuseIdentifier = "newsCell"
    private var _cellHeight = 358.0
    
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
        
        tvNewsList?.separatorStyle = .none
        
        initUI()
        showNextNewsPage()
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
        cell.ivNewsPic.layer.cornerRadius = 8
        // add listener for news discription
        
        let numOfRow = Int(indexPath.row)
        
        cell.tfNewsLabel.text = self._getContMng.loadedNewsList[numOfRow].title
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
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
    
    private func showNextNewsPage()
    {
        self.showActivityIndicatory()
        
        self._getContMng.loadNextContentSegment(byType: GetContentManager.CONTENT_TYPE_NEWS,
                                                at: GetContentManager.AJWT_WORD,
                                                successCompletion:
                                                { text in
                                                    self.hideActivityIndicatory()
                                                    print("ok show news")
                                                    //print(self._getContMng.loadedNewsList)
                                                    self._cellCount = self._getContMng.loadedNewsList.count
                                                    
                                                    DispatchQueue.main.async
                                                    {
                                                        self.tvNewsList?.reloadData()
                                                    }
                                                    
                                                },
                                                errorCompletion:
                                                { text in
                                                    self._alertController.alert(in: self,
                                                                               withTitle: "Ошибка!",
                                                                               andMsg: "Не удалось загрузить новости, повторите попытку позже.",
                                                                               andActionTitle: "Ок",
                                                                               completion:
                                                                               { [unowned self] text in
                                                                                    self.sidebarDidClose(with: UIStoryboard.VIEW_TYPE_LOGIN)
                                                                               })
                                                })
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
