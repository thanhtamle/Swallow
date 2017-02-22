//
//  SchoolListViewController.swift
//  Education Platform
//
//  Created by Duy Cao on 12/9/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Localize_Swift
import FontAwesomeKit
import ESPullToRefresh

class SchoolListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    //MARK: Views
    @IBOutlet weak var tableView : UITableView!
    
    //MARK: data
    var list : [School] = []
    var currentPage = 1 {
        didSet {
            self.params[self.searchServive.searchField.CURRENT_PAGE] = self.currentPage
        }
    }
    var totalPage = -1
    //MARK: Services
    let searchServive = SearchService.sharedInstrance
    var navVC : UINavigationController!
    
    //MARK: API
    var isLoading : Bool = false
    let stuffManager = StuffManager.sharedInstance
    var params : [String : Any] = [:]
    var apiSearchString = ""

    
    //MARK: Built-in functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        
        navigationController?.navigationBar.barTintColor = Global.colorMain
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.setLanguageRuntime()
        
        //dismiss
        let image = FAKIonIcons.iosCloseIcon(withSize: 30.0).image(with: CGSize(width: 30.0, height: 30.0))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(event_dismiss(sender:)))
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        self.tableView.backgroundColor = Global.colorHeader
        self.tableView.tableFooterView = UIView()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //MARK: PulltoRefresh Implementation
        let refreshHeaderAnimator = MTRefreshHeaderAnimator.init(frame: CGRect.zero)

        _ = self.tableView.es_addPullToRefresh(animator: refreshHeaderAnimator) { [weak self] in
            if self?.isLoading == true {
                self?.tableView.es_stopPullToRefresh()
                return
            }
            self!.currentPage = 1
            self!.isLoading = true
            self!.searchServive.searchSchool(apiSearchString : self!.apiSearchString,
                                             params: self!.params,
                                             complete: {
                                                schools, totalPage in
                                                self?.totalPage = totalPage
                                                if schools.count > 0 {
                                                    self!.list = schools
                                                    self!.tableView.reloadData()
                                                }else{
                                                    Utils.showAlert(title: "error", message: "time_out", viewController: self!)
                                                }
                                                self?.isLoading = false
                                                self?.tableView.es_stopPullToRefresh()
            })
            self?.refreshdata()
            
        }
        

        _ = self.tableView.es_addInfiniteScrolling{ [weak self] in
            self?.loadMore()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.edgesForExtendedLayout = .left
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Event
    func event_dismiss(sender : UIBarButtonItem){
        print("Hello Exit")
        self.navVC.popViewController(animated: true)
        
    }
    
    func setLanguageRuntime(){
        self.navigationItem.title = self.title?.localized()
        tabBarItem.title = "search".localized()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: nil)
        _ = self.searchServive.cancel()
        self.searchServive.searchParams[searchServive.searchField.CURRENT_PAGE] = 1
    }
    
    func setArgs(apiSearchString : String, params : [String:Any], initialList : [School], totalPage : Int) {
        self.list = initialList
        self.apiSearchString = apiSearchString
        self.params = params
        self.totalPage = totalPage
    }
    
    func refreshdata(){
        if self.isLoading == true {
            self.tableView.es_stopPullToRefresh(ignoreDate: true)
            return
        }
        self.currentPage = 1
        self.isLoading = true
        self.searchServive.searchSchool(apiSearchString : self.apiSearchString,
                                         params: self.params,
                                         complete: {
                                            schools, totalPage in
                                            self.totalPage = totalPage
                                            if schools.count > 0 {
                                                self.list = schools
                                                self.tableView.reloadData()
                                            }
                                            self.isLoading = false
                                            self.tableView.es_stopPullToRefresh(ignoreDate: true)
        })

    }
    
    func loadMore(){
        self.currentPage = self.currentPage + 1
        self.isLoading = true
        self.searchServive.searchSchool(apiSearchString : self.apiSearchString,
                                         params: self.params,
                                         complete: {
                                            schools, totalPage in
                                            if schools.count > 0 {
                                                self.list.append(contentsOf: schools)
                                                self.currentPage += 1
                                                self.tableView.reloadData()
                                            }
                                            else {
                                                if self.currentPage > self.totalPage {
                                                    self.currentPage -= 1
                                                }
                                            }
                                            self.isLoading = false
                                            self.tableView.es_stopLoadingMore()
                                            if self.list.count < 3 {
                                                self.tableView.es_removeRefreshFooter()
                                            }
        })
    }


    func registerNib(){
        self.tableView.register(UINib.init(nibName: "SchoolTableViewCell", bundle: nil) , forCellReuseIdentifier: "schoolcell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolcell") as! SchoolTableViewCell
        cell.setData(school: &list[indexPath.row], stuffManager: stuffManager)
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let schooldetails = SchoolDetailsController()
        schooldetails.school = self.list[indexPath.row]
        schooldetails.schoolID = self.list[indexPath.row].SchoolData.Id
        self.navVC.pushViewController(schooldetails, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.currentPage = 1
        if let text = searchController.searchBar.text, !text.isEmpty && !text.removeSpaceAndTolowerCaseString().isEmpty {
            self.params[searchServive.searchField.SCHOOLNAME] = text
        }else{
            self.params[searchServive.searchField.SCHOOLNAME] = ""
        }
        _ = self.searchServive.cancel()
//        self.tableView.es_startPullToRefresh()
        self.executeSearch()
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func executeSearch(){
        self.showWaitOverlay()
        searchServive.isCancelled = false
//        print(self.params, "DSADSAD")
        searchServive.searchSchool(params: self.params, complete: {
            schools, totalPage in
            DispatchQueue.main.async {
                self.list = schools
                self.totalPage = totalPage
                self.tableView.reloadData()
                print(self.params)
                self.removeAllOverlays()
            }
            
        })
    }
    
}
