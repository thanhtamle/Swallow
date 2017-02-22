//
//  MainViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/2/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift

class MainViewController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    let gradientView = GradientView()
    static var newsFeedViewController = NewsFeedViewController()
    static var jobViewController = JobViewController()
    static var messageViewController = MasterChatViewController()
    static var searchViewController = SearchFirstViewController()
    static var menuViewController = MenuViewController()
    static var followviewController = FollowViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.setStatusBarBackgroundColor(color: Global.colorStatus)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.newsFeedViewController = NewsFeedViewController()
        MainViewController.jobViewController = JobViewController()
        MainViewController.followviewController = FollowViewController()
        MainViewController.messageViewController = MasterChatViewController()
        MainViewController.searchViewController = SearchFirstViewController()
        MainViewController.menuViewController = MenuViewController()
        
        let listIcon = FAKFontAwesome.listIcon(withSize: 25)
        listIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorBg)
        let listImg  = listIcon?.image(with: CGSize(width: 25, height: 25))
        
        let newsFeedTabBarItem = UITabBarItem(title: "news_feed".localized(), image: listImg, tag: 1)
        MainViewController.newsFeedViewController.tabBarItem = newsFeedTabBarItem
        let nc1 = UINavigationController(rootViewController: MainViewController.newsFeedViewController)
        
        let socialTwitterIcon = FAKIonIcons.socialTwitterIcon(withSize: 25)
        socialTwitterIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorBg)
        let socialTwitterImg  = socialTwitterIcon?.image(with: CGSize(width: 25, height: 25))
        
        let jobTabBarItem = UITabBarItem(title: "follow".localized(), image: socialTwitterImg, tag: 2)
        MainViewController.followviewController.tabBarItem = jobTabBarItem
        let nc3 = UINavigationController(rootViewController: MainViewController.followviewController)
        
        let chatbubbleWorkingIcon = FAKIonIcons.chatbubbleWorkingIcon(withSize: 25)
        chatbubbleWorkingIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorBg)
        let chatbubbleWorkingImg  = chatbubbleWorkingIcon?.image(with: CGSize(width: 25, height: 25))
        
        let messageTabBarItem = UITabBarItem(title: "message".localized(), image: chatbubbleWorkingImg, tag: 3)
        MainViewController.messageViewController.tabBarItem = messageTabBarItem
        let nc4 = UINavigationController(rootViewController: MainViewController.messageViewController)
        
        let searchIcon = FAKIonIcons.universityIcon(withSize: 25)
        searchIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorBg)
        let searchImg  = searchIcon?.image(with: CGSize(width: 25, height: 25))
        
        let searchTabBarItem = UITabBarItem(title: "school".localized(), image: searchImg, tag: 4)
        MainViewController.searchViewController.tabBarItem = searchTabBarItem
        let nc2 = UINavigationController(rootViewController: MainViewController.searchViewController)
        
        let barsIcon = FAKFontAwesome.barsIcon(withSize: 25)
        barsIcon?.addAttribute(NSForegroundColorAttributeName, value: Global.colorBg)
        let barsImg  = barsIcon?.image(with: CGSize(width: 25, height: 25))
        
        let menuTabBarItem = UITabBarItem(title: "more".localized(), image: barsImg, tag: 5)
        MainViewController.menuViewController.tabBarItem = menuTabBarItem
        let nc5 = UINavigationController(rootViewController: MainViewController.menuViewController)
        
        self.viewControllers = [nc1, nc3, nc4, nc2, nc5]
        
        FriendServices.getInstance().getDataUser()
        connectWebSocket()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ =  FriendServices.getInstance()
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    func connectWebSocket() {
        let currentUser = UserDefaultManager.getInstance().getCurrentUser()
        
        if currentUser == nil {
            return
        }
        
        if(currentUser?.User.Id != 0) {
            WebSocketServices.shared.Connect(UserId: (currentUser?.User.Id)!, Token: (currentUser?.User.Token)!)
        }
    }
    
    func loadBagdeMessage() {
        ChatAPIservices.getGroupContainUser { (groups) in
            GroupMessagesData.getInstance().messages.removeAll(keepingCapacity: true)
            GroupMessagesData.getInstance().messages =  groups
            
            let total = GroupMessagesData.getInstance().getCounter()
            Utils.setBadgeIndicator(badgeCount: total)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    var previousTag = 1
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 && previousTag == 1 {
            let indexPath = NSIndexPath(row: 0, section: 0)
            MainViewController.newsFeedViewController.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
        previousTag = item.tag
    }
    

}
