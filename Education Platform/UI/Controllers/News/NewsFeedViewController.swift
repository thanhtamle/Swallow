//
//  NewsFeedViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/2/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift
import Alamofire
import SwiftyJSON
import Kingfisher
import ESPullToRefresh
import DZNEmptyDataSet

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, NewsServiceDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 1
    var loadType = false
    
    let newsFeedCellReuseIdentifier = "NewsFeedCellReuseIdentifier"
    let gradientView = GradientView()
    var refreshHeaderAnimator: MTRefreshHeaderAnimator!
    var refreshFooterAnimator: ESRefreshFooterAnimator!

    var cartBarbuttonItem: MIBadgeButton!
    var news = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = Global.colorMain
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let notificationIcon = FAKIonIcons.androidNotificationsIcon(withSize: 25)
        notificationIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
        let notificationImg = notificationIcon?.image(with: CGSize(width: 25, height: 25))
        
        self.cartBarbuttonItem = MIBadgeButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        self.cartBarbuttonItem?.setImage(notificationImg, for: .normal)
        self.cartBarbuttonItem?.addTarget(self, action: #selector(notificationBtnClicked), for: UIControlEvents.touchUpInside)
        self.cartBarbuttonItem.badgeEdgeInsets =  UIEdgeInsets(top: 30, left: 2, bottom: 0, right: 0)
    
        let barButton : UIBarButtonItem = UIBarButtonItem(customView: self.cartBarbuttonItem)
        //let notificationBarBtn = UIBarButtonItem(image: notificationImg, style: .plain, target: self, action: #selector(notificationBtnClicked))
        self.navigationItem.rightBarButtonItem = barButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(UINib(nibName: "NewsFeedTableViewCell", bundle: nil), forCellReuseIdentifier: newsFeedCellReuseIdentifier as String)
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none

        refreshHeaderAnimator = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
        refreshFooterAnimator = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        
        let _ = self.tableView.es_addPullToRefresh(animator: refreshHeaderAnimator) { [weak self] in
            self?.refresh()
        }
        let _ = self.tableView.es_addInfiniteScrolling(animator: refreshFooterAnimator) { [weak self] in
            self?.loadMore()
        }
        self.tableView.refreshIdentifier = "defaulttype"
        self.tableView.expriedTimeInterval = 20.0
        
        self.tableView.es_startPullToRefresh()
        
        getNotificationBadge()
        setLanguageRuntime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge.left
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        getNotificationBadge()
    }
    
    func setLanguageRuntime(){
        self.navigationItem.title = "news_feed".localized()
        refreshFooterAnimator.loadingMoreDescription = "loading_more".localized()
        refreshFooterAnimator.noMoreDataDescription = "no_more_data".localized()
        refreshFooterAnimator.loadingDescription = "loading_more".localized()
    }
    
    func refresh() {
        if !Utils.isInternetAvailable() {
            Utils.showAlert(title: "error".localized(), message: "internet_is_not_available_please_try_again".localized(), viewController: self)
            tableView.es_stopPullToRefresh()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.currentPage = 1
            self.loadType = true
            NewsService.reloadNews(currentPage: self.currentPage, newsServiceDelegate: self)
        }
    }
    
    func loadMore() {
        if !Utils.isInternetAvailable() {
            Utils.showAlert(title: "error".localized(), message: "internet_is_not_available_please_try_again".localized(), viewController: self)
            tableView.es_stopLoadingMore()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.currentPage = self.currentPage + 1
            self.loadType = false
            NewsService.reloadNews(currentPage: self.currentPage, newsServiceDelegate: self)
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if DeviceType.IS_IPHONE {
            return UIImage(named: "citynow.png")?.resizeImage(scale: 0.3)
        }
        else {
            return UIImage(named: "citynow.png")?.resizeImage(scale: 0.5)
        }
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "no_news_entry".localized()
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
                     NSForegroundColorAttributeName: Global.colorSelected]
        return NSAttributedString(string: text, attributes: attrs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = "refresh".localized()
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline),
                     NSForegroundColorAttributeName: Global.colorMain]
        return NSAttributedString(string: text, attributes: attrs)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.tableView.es_startPullToRefresh()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.news.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsFeedTableViewCell! = tableView.dequeueReusableCell(withIdentifier: newsFeedCellReuseIdentifier as String) as? NewsFeedTableViewCell
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        let news = self.news[indexPath.row]
        
        if news.author.Avatar != "" {
            cell.authorIconBtn.kf.setImage(with: URL(string: news.author.Avatar), for: .normal)
        }
        else {
            cell.authorIconBtn.setImage(UIImage(named: "ic_user"), for: .normal)
        }
        
        cell.authorIconBtn.tag = indexPath.row
        cell.shortDescriptionLabel.text = news.newsInterface.ShortDescription
        cell.authorIconBtn.addTarget(self, action: #selector(authorIconBtnClicked), for: .touchUpInside)
        cell.readMoreLabel.text = "read_more".localized()
        
        var haveBackgroud = false
        for item in news.photos {
            if item.Url != "" {
                cell.photoImgView.kf.setImage(with: URL(string: item.Url))
                haveBackgroud = true
                break
            }
        }
        
        if !haveBackgroud {
            cell.photoImgView.kf.setImage(with: nil)
        }
        
        
        cell.authorNameLabel.text = news.author.DisplayName
        cell.titleLabel.text = news.newsInterface.Title
        cell.categoryTitleLabel.text = news.category.Name
        cell.timeLabel.text = NSDate().timeElapsed(Utils.stringtoDate(string: news.newsInterface.created_time), local: Localize.currentLanguage())

        return cell
    }
    
    func authorIconBtnClicked(_ sender: UIButton) {
        let news = self.news[sender.tag]
        let viewController = UserDetailViewController()
        viewController.user = news.author
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.news[indexPath.row]
        let detailNewsFeedViewController = DetailNewsFeedViewController()
        detailNewsFeedViewController.NewId = news.newsInterface.NewsId
        self.navigationController?.pushViewController(detailNewsFeedViewController, animated: true)
    }
    
    func notificationBtnClicked() {
        let viewController = NotificationViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func loadNewsFinished(success: Bool, message: String, news: [News]) {
        if success {
            if loadType {
                self.news = [News]()
            }
            self.news.append(contentsOf: news)
            tableView.reloadData()
        }
        else {
            Utils.showAlert(title: "error".localized() , message: message, viewController: self)
        }
        
        if loadType {
            self.tableView.es_stopPullToRefresh()
        }
        else {
            self.tableView.es_stopLoadingMore()
        }
    }
    
    func getNotificationBadge() {
        NotificationServices.getInstance().refreshNotification(type: true, currentPage: 1) { (datas, success) in
            
            if success == true {
                var total = 0
                for each in datas{
                    if (each.SeenFlag == 0) {
                        total += 1
                    }
                }
                
                if total > 0 {
                    self.cartBarbuttonItem.badgeString = total.description
                }
            }
        }
    }

}
