//
//  NewsViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
import Kingfisher

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tabBtnNews: UIButton!
    @IBOutlet weak var tabBtnIdeaClimeMenu: UIButton!
    @IBOutlet weak var tvNewsList: UITableView!
    @IBOutlet weak var currNewsDate: UILabel!
    
    var loadActivityIndicator:UIActivityIndicatorView?
    
    // cell count from Model
    private var _cellCount = 0
    private var _cellReuseIdentifier = "newsCell"
    private var _cellHeight = 358.0
    
    private let _getContMng = GetContentManager.shared
    private let _alertController = AlertController.shared
    
    private var _loadingState: Bool = false
    private var _count = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addListeners()
        tvNewsList?.separatorStyle = .none
        initUI()
        
        initShowNews()
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
        
        let numOfRow = Int(indexPath.row)
        
        // costomize image content from API
        let urlStr = self._getContMng.loadedNewsList[numOfRow].imgs[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let imgUrl = URL(string: urlStr)
        cell.ivNewsPic.kf.indicatorType = .activity
        cell.ivNewsPic.kf.setImage(
            with: imgUrl,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        cell.ivNewsPic.layer.cornerRadius = 8
        
        // costomize text content from API
        cell.tfNewsLabel.layer.cornerRadius = 8
        cell.tfNewsLabel.text = self._getContMng.loadedNewsList[numOfRow].title
        
        cell.tfNewsText.text = GetContentManager.clearTextFromHtmlTegs(htmlText: self._getContMng.loadedNewsList[numOfRow].content) 
        
        // time to news
        let dateStr = self._getContMng.loadedNewsList[numOfRow].created_at
        let indexStart: String.Index = dateStr.index(dateStr.endIndex, offsetBy: -8)
        let indexEnd: String.Index = dateStr.index(dateStr.endIndex, offsetBy: -3)
        cell.tfTime.text = String(dateStr[indexStart..<indexEnd])
        
        setDateLabel(with: dateStr)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self._getContMng.currentNews = indexPath.row
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
            self.tvNewsList?.separatorStyle = .none
            
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
    
    private func initShowNews()
    {
        if self._getContMng.loadedNewsList.count == 0
        {
            showNextNewsPage()
        }
        else
        { print("Second show news")
            self.hideActivityIndicatory()
            self._cellCount = self._getContMng.loadedNewsList.count
            DispatchQueue.main.async
            {
                self.tvNewsList?.reloadData()
            }

        }
    }
    
    private func showNextNewsPage()
    {
_count += 1
print(_count)
print("pre num of PAGE \(self._getContMng.getLoadedPageNum(of: GetContentManager.CONTENT_TYPE_NEWS))")
        showActivityIndicatory()
        
        
        _getContMng.loadNextContentSegment(byType: GetContentManager.CONTENT_TYPE_NEWS,
                                                at: GetContentManager.AJWT_WORD,
                                                successCompletion:
                                                { text in
                                                    
                                                    self.hideActivityIndicatory()
                                                    print("ok show news")
                                                    self._cellCount = self._getContMng.loadedNewsList.count
                                                    
                                                    print(self._getContMng.loadedNewsList.count)
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
    
    /*
     *   Actualize date label
    **/
    private func setDateLabel(with dateStr: String)
    {
        // get current date string
        let date = Date()
        let calendar = Calendar.current
        let currYear = String(calendar.component(.year, from: date))
        let currMonth = String(calendar.component(.month, from: date))
        let currDay = String(calendar.component(.day, from: date))
        let currDateStr = currYear + "-" + addZeroToSingleChar(to: currMonth) + "-" + addZeroToSingleChar(to: currDay)
        
        // get news date string
        let indexEnd: String.Index = dateStr.index(dateStr.startIndex, offsetBy: 10)
        let newsDateStr = String(dateStr[..<indexEnd])
        
        if currDateStr == newsDateStr
        {
            self.currNewsDate.text = "Сегодня"
        }
        else
        {
            self.currNewsDate.text = newsDateStr
        }
        
    }
    
    private func addZeroToSingleChar(to oneCharString: String) -> String
    {
        var readyStr = oneCharString
        
        if readyStr.count == 1
        {
            readyStr = "0" + readyStr
        }
        
        return readyStr
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
