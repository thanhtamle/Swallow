//
//  UserDetailViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/30/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift
import Alamofire
import SwiftyJSON
import Kingfisher
import ESPullToRefresh
import STPopup

protocol FollowUserDelegate {
    func userProfileClicked(user: UserResult)
}

class UserDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FollowUserDelegate, NewsServiceDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 1
    var loadType = false

    let newsFeedCellReuseIdentifier = "NewsFeedCellReuseIdentifier"
    let gradientView = GradientView()
    var headerView: UserDetailHeaderTableViewCell!
    var user: UserResult!
    var news = [News]()
    
    var refreshHeaderAnimator: MTRefreshHeaderAnimator!
    var refreshFooterAnimator: ESRefreshFooterAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = Global.colorMain
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewsFeedTableViewCell", bundle: nil), forCellReuseIdentifier: newsFeedCellReuseIdentifier as String)
        tableView.backgroundColor = Global.colorHeader
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.separatorStyle = .none
        
        headerView = UserDetailHeaderTableViewCell.instanceFromNib() as? UserDetailHeaderTableViewCell
        headerView.user = user
        tableView.tableHeaderView = headerView
        headerView.followedBtn.addTarget(self, action: #selector(showUsersFollowed), for: .touchUpInside)
        headerView.followingBtn.addTarget(self, action: #selector(showUsersFollowing), for: .touchUpInside)


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
        
        setLanguageRuntime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge.top
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    func setLanguageRuntime(){
        self.navigationItem.title = user.DisplayName
        headerView.loadData()
        
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
            NewsService.reloadNewsByOwnerUser(currentPage: self.currentPage, userId: self.user.Id, newsServiceDelegate: self)
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
            NewsService.reloadNewsByOwnerUser(currentPage: self.currentPage, userId: self.user.Id, newsServiceDelegate: self)
        }
    }
    
    // MARK: - Manager TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
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
        
        cell.authorIconBtn.addTarget(self, action: #selector(authorIconBtnClicked), for: .touchUpInside)
        cell.authorIconBtn.tag = indexPath.row
        cell.shortDescriptionLabel.text = news.newsInterface.ShortDescription
        cell.readMoreLabel.text = "read_more".localized()
        
        for item in news.photos {
            if item.Url != "" {
                cell.photoImgView.kf.setImage(with: URL(string: item.Url))
                break
            }
        }
        
        cell.authorNameLabel.text = news.author.DisplayName
        cell.titleLabel.text = news.newsInterface.Title
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
    
    var viewPopupController: STPopupController!
    
    func showUsersFollowing() {
        STPopupNavigationBar.appearance().tintColor = UIColor.white
        STPopupNavigationBar.appearance().barTintColor = Global.colorMain
        STPopupNavigationBar.appearance().barStyle = .default
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white]
        }
        
        let viewController = UsersFollowingViewController()
        viewController.user = user
        viewController.followUserDelegate = self
        viewPopupController = STPopupController(rootViewController: viewController)
        viewPopupController.containerView.layer.cornerRadius = 4
        viewPopupController.present(in: self)
    }
    
    func showUsersFollowed() {
        STPopupNavigationBar.appearance().tintColor = UIColor.white
        STPopupNavigationBar.appearance().barTintColor = Global.colorMain
        STPopupNavigationBar.appearance().barStyle = .default
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white]
        }
        
        let viewController = UsersFollowedViewController()
        viewController.user = user
        viewController.followUserDelegate = self
        viewPopupController = STPopupController(rootViewController: viewController)
        viewPopupController.containerView.layer.cornerRadius = 4
        viewPopupController.present(in: self)
    }
    
    func userProfileClicked(user: UserResult) {
        viewPopupController.dismiss()
        let nav = UserDetailViewController()
        nav.user = user
        self.navigationController?.pushViewController(nav, animated: true)
    }
}
