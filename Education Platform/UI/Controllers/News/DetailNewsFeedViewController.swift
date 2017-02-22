//
//  DetailNewsFeedViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/7/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift
import Alamofire
import SwiftyJSON
import Kingfisher
import CRNetworkButton
import STPopup
import TTTAttributedLabel
import SwiftyJSON
import ESPullToRefresh

class DetailNewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentDelegate, FollowServiceDelegate {
    
    let tableView = UITableView()
    let commentCellReuseIdentifier = "CommentCellReuseIdentifier"
    
    var headerView: NewsFeedDetailTableViewCell!
    
    var refreshHeaderAnimator: MTRefreshHeaderAnimator!
    var refreshFooterAnimator: ESRefreshFooterAnimator!
    
    var constraintsAdded = false
    var currentPage = 1
    
    var news: News!
    var NewId: Int!
    var commentPosts = [CommentPost]()
    var currentUser: RoleResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addTapToDismiss()
        
        currentUser = UserDefaultManager.getInstance().getCurrentUser()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: commentCellReuseIdentifier as String)
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        headerView = NewsFeedDetailTableViewCell.instanceFromNib() as? NewsFeedDetailTableViewCell
        tableView.backgroundColor = UIColor.white
        tableView.tableHeaderView = self.headerView
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        refreshHeaderAnimator = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
        refreshFooterAnimator = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        
        let _ = self.tableView.es_addPullToRefresh(animator: refreshHeaderAnimator) { [weak self] in
            self?.refresh()
        }
        
        //        let _ = self.tableView.es_addInfiniteScrolling(animator: refreshFooterAnimator) { [weak self] in
        //            self?.loadMore()
        //        }
        
        tableView.refreshIdentifier = "defaulttype"
        tableView.expriedTimeInterval = 20.0
        
        headerView.authorIconBtn.addTarget(self, action: #selector(authorIconBtnClicked), for: .touchUpInside)
        headerView.followBtn.addTarget(self, action: #selector(followBtnClicked), for: .touchUpInside)
        headerView.likeBtn.addTarget(self, action: #selector(likeBtnClicked), for: .touchUpInside)
        headerView.commentBtn.addTarget(self, action: #selector(commentBtnClicked), for: .touchUpInside)
        headerView.shareBtn.addTarget(self, action: #selector(shareBtnClicked), for: .touchUpInside)
        
        view.addSubview(tableView)
        setLanguageRuntime()
        self.view.setNeedsUpdateConstraints()
    }
    
    func refresh() {
        if !Utils.isInternetAvailable() {
            Utils.showAlert(title: "error".localized(), message: "internet_is_not_available_please_try_again".localized(), viewController: self)
            tableView.es_stopPullToRefresh()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.currentPage = 1
            self.loadCommentList(type: true, moveToBottom: false)
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
            self.loadCommentList(type: false, moveToBottom: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.edgesForExtendedLayout = UIRectEdge.left
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    func setLanguageRuntime() {
        SwiftOverlays.showBlockingWaitOverlay()
        self.navigationItem.title = ""
        
        NewsService.getNewsById(newId: NewId) { (success, message, news) in
            if success == true {
                if news?.author.Avatar != "" {
                    self.headerView.authorIconBtn.kf.setImage(with: URL(string: (news?.author.Avatar)!), for: .normal)
                }
                
                FollowService.getFollowingListOwner(followServiceDelegate: self)

                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let attrStr = try! NSMutableAttributedString(
                        data: (news?.newsInterface.DescriptionHtml.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,
                        options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                        documentAttributes: nil)
                    
                    self.refresh()
                    
                    attrStr.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attrStr.length), options: NSAttributedString.EnumerationOptions.init(rawValue: 0)) { (value, range, stop) -> Void in
                        if let attachement = value as? NSTextAttachment {
                            let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)
                            let screenSize: CGRect = UIScreen.main.bounds
                            if (image?.size.width)! > screenSize.width - 20 {
                                let newImage = image?.resizeImage(scale: (screenSize.width - 20)/(image?.size.width)!)
                                let newAttribut = NSTextAttachment()
                                newAttribut.image = newImage
                                attrStr.addAttribute(NSAttachmentAttributeName, value: newAttribut, range: range)
                            }
                        }
                    }
                    
                    self.headerView.descriptionLabel.attributedText = attrStr
                    self.headerView.authorStatusLabel.text = "I have been a professional job recruiter since 2002"
                    self.headerView.authorNameLabel.text = news?.author.DisplayName
                    self.headerView.timeLabel.text = NSDate().timeElapsed(Utils.stringtoDate(string: (news?.newsInterface.created_time)!), local: Localize.currentLanguage())
                    
                    self.headerView.titleLabel.text = news?.newsInterface.Title
                    self.news = news
                    
                    for item in (news?.photos)! {
                        if item.Url != "" {
                            self.headerView.newsImgView.kf.setImage(with: URL(string: item.Url))
                            break
                        }
                    }
                    
                    self.headerView.topView.isHidden = false
                    self.headerView.titleLabel.isHidden = false
                    self.headerView.newsImgView.isHidden = false
                    self.headerView.descriptionLabel.isHidden = false
                    self.headerView.socialContainerView.isHidden = false
                    self.tableView.es_startPullToRefresh()
                }
            }
            else {
                Utils.showAlert(title: "error".localized(), message: message, viewController: self)
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }
    }
    
    override func updateViewConstraints() {
        if !constraintsAdded {
            constraintsAdded = true
            
            tableView.autoPinEdgesToSuperviewEdges()
            
            headerView.topView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
            headerView.topView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            headerView.topView.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            headerView.topView.autoPinEdge(.bottom, to: .top, of: headerView.titleLabel, withOffset: -20)
            
            headerView.titleLabel.autoPinEdge(.top, to: .bottom, of: headerView.topView)
            headerView.titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            headerView.titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            headerView.titleLabel.autoPinEdge(.bottom, to: .top, of: headerView.newsImgView, withOffset: -20)
            
            headerView.newsImgView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            headerView.newsImgView.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            headerView.newsImgView.autoPinEdge(.bottom, to: .top, of: headerView.descriptionLabel, withOffset: -20)
            
            headerView.descriptionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            headerView.descriptionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            headerView.descriptionLabel.autoPinEdge(.bottom, to: .top, of: headerView.socialContainerView, withOffset: -30)
            
            headerView.socialContainerView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            headerView.socialContainerView.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            headerView.socialContainerView.autoSetDimension(.height, toSize: 40)
            headerView.socialContainerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
            
            headerView.authorIconBtn.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            headerView.authorIconBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
            headerView.authorIconBtn.autoSetDimension(.height, toSize: 40)
            headerView.authorIconBtn.autoSetDimension(.width, toSize: 40)
            
            headerView.followBtn.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            headerView.followBtn.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
            headerView.followBtn.autoSetDimension(.height, toSize: 25)
            headerView.followBtn.autoSetDimension(.width, toSize: 130)
            
            headerView.authorNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            headerView.authorNameLabel.autoPinEdge(.leading, to: .trailing, of: headerView.authorIconBtn, withOffset: 5)
            headerView.authorNameLabel.autoPinEdge(.trailing, to: .leading, of: headerView.followBtn, withOffset: -5)
            headerView.authorNameLabel.autoSetDimension(.height, toSize: 18)
            
//            headerView.authorStatusLabel.autoPinEdge(.top, to: .bottom, of: headerView.authorNameLabel, withOffset: 0)
//            headerView.authorStatusLabel.autoPinEdge(.leading, to: .trailing, of: headerView.authorIconBtn, withOffset: 5)
//            headerView.authorStatusLabel.autoPinEdge(.trailing, to: .leading, of: headerView.followBtn, withOffset: -5)
//            headerView.authorStatusLabel.autoPinEdge(.bottom, to: .top, of: headerView.timeLabel, withOffset: 0)
            
            headerView.timeLabel.autoPinEdge(.top, to: .bottom, of: headerView.authorNameLabel, withOffset: 0)
            headerView.timeLabel.autoPinEdge(.leading, to: .trailing, of: headerView.authorIconBtn, withOffset: 5)
            headerView.timeLabel.autoPinEdge(.trailing, to: .leading, of: headerView.followBtn, withOffset: -5)
            headerView.timeLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)
            
//            headerView.likeBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
//            headerView.likeBtn.autoSetDimension(.height, toSize: 25)
//            headerView.likeBtn.autoSetDimension(.width, toSize: 25)
//            headerView.likeBtn.autoAlignAxis(.horizontal, toSameAxisOf: headerView.shareBtn)
            
            headerView.commentBtn.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            headerView.commentBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
            headerView.commentBtn.autoSetDimension(.height, toSize: 30)
            headerView.commentBtn.autoSetDimension(.width, toSize: 30)
            
            headerView.shareBtn.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            headerView.shareBtn.autoPinEdge(.leading, to: .trailing, of: headerView.commentBtn, withOffset: 20)
            headerView.shareBtn.autoSetDimension(.height, toSize: 30)
            headerView.shareBtn.autoSetDimension(.width, toSize: 30)
            
            headerView.socialBorder.autoPinEdge(toSuperviewEdge: .bottom)
            headerView.socialBorder.autoPinEdge(toSuperviewEdge: .left)
            headerView.socialBorder.autoPinEdge(toSuperviewEdge: .right)
            headerView.socialBorder.autoSetDimension(.height, toSize: 1)
        }
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    func likeBtnClicked() {
        
    }
    
    func commentBtnClicked() {
        let commentViewController = CommentViewController()
        commentViewController.news = news.newsInterface
        commentViewController.commentDelegate = self
        let nav = UINavigationController(rootViewController: commentViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    func post() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.currentPage = 1
            self.loadCommentList(type: true, moveToBottom: true)
        }
    }
    
    func shareBtnClicked() {
        let textToShare = news.newsInterface.Title
        if let myWebsite = NSURL(string: "http://saigon.citynow.vn:9000/#/news/" + String(news.newsInterface.Id)) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if let wPPC = activityVC.popoverPresentationController {
                wPPC.sourceView = headerView.shareBtn
            }
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell! = tableView.dequeueReusableCell(withIdentifier: commentCellReuseIdentifier as String) as? CommentTableViewCell
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        let commentPost = commentPosts[indexPath.row]
        cell.commentPost = commentPost
        cell.bindingData(currentUser: self.currentUser)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func authorIconBtnClicked() {
        let nav = UserDetailViewController()
        nav.user = news.author
        self.navigationController?.pushViewController(nav, animated: true)
    }
    
    func getFollowingListOwnerFinished(success: Bool, message: String, result: [UserResult]) {
        for item in result {
            if self.news.author.Id == item.Id {
                self.headerView.followBtn.setTitle("followed_btn".localized(), for: .normal)
                self.headerView.setImageForFollowBtn(type: true)
                break
            }
        }
    }
    
    func getFollowingListFinished(success: Bool, message: String, result: [UserResult]) {

    }
    
    func getFollowedListFinished(success: Bool, message: String, result: [UserResult]) {

    }
    
    func followFinised(success: Bool, message: String) {
        SwiftOverlays.removeAllBlockingOverlays()
        if success {
            headerView.followBtn.setTitle("followed_btn".localized(), for: .normal)
            headerView.setImageForFollowBtn(type: true)
        }
    }
    
    func unFollowFinised(success: Bool, message: String) {
        SwiftOverlays.removeAllBlockingOverlays()
        if success {
            headerView.followBtn.setTitle("follow_btn".localized(), for: .normal)
            headerView.setImageForFollowBtn(type: false)
        }
    }
    
    func followBtnClicked(_ sender: UIButton) {
        
        SwiftOverlays.showBlockingWaitOverlay()
        if sender.titleLabel?.text == "follow_btn".localized() {
            FollowService.follow(userId: self.news.author.Id, followServiceDelegate: self)
            return
        }
        
        FollowService.unFollow(userId: self.news.author.Id, followServiceDelegate: self)
    }
    
    func loadCommentList(type: Bool, moveToBottom: Bool) {
        CommentService.loadCommentList(newId: news.newsInterface.Id) { (success, message, commentPosts) in
            if success == true {
                if type {
                    self.commentPosts = [CommentPost]()
                }
                self.commentPosts.append(contentsOf: commentPosts)
                self.tableView.reloadData()
                
                if moveToBottom {
                    let indexPath = NSIndexPath(row: self.commentPosts.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
                else {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
            else {
                Utils.showAlert(title: "error".localized() , message: message, viewController: self)
            }
            self.stopRefresh(type: type)
            SwiftOverlays.removeAllBlockingOverlays()
        }
    }
    
    
    func stopRefresh(type: Bool) {
        if type {
            self.tableView.es_stopPullToRefresh()
        }
        else {
            self.tableView.es_stopLoadingMore()
        }
    }
}
