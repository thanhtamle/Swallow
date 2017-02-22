//
//  SearchViewController.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/2/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift

enum  SearchFieldType {
    case TEXT
    case SLIDER
    case RANGER
    case PICKER
    static var count: Int { return SearchFieldType.PICKER.hashValue + 1}
}



class AdvancedSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellSizeChangeDelegate {

    @IBOutlet var tableView: UITableView!
    var clearBtn : UIBarButtonItem!
    
    
    var searchController : UISearchController!
    
    //Language Strings
    let clear = "clear"
    let titleName = "filter"
    
    //Views
    var titlev : UILabel!
    
    //Predefined Data for this controller
    let searchfieldId = "SearchTableViewCellIdentifier"
    let searchService = SearchService.sharedInstrance
    let searchKeys : [[String]] = [[SearchKeys.sharedInstance.MAJOR],
                                    [SearchKeys.sharedInstance.SERVICE],
                                     [SearchKeys.sharedInstance.RANKING],
                                     [SearchKeys.sharedInstance.MINFEE,SearchKeys.sharedInstance.MAXFEE]]
    let search_fields = ["majors",
                         "services",
                         "minimum_ranking",
                         "fees"]
    let search_types = [[SearchFieldType.TEXT],
                        [.TEXT],
                        [.SLIDER],
                        [.PICKER,.RANGER]]
    let fields_pre_data = [StuffManager.sharedInstance.Majors,
                           StuffManager.sharedInstance.Services,
                           [[0.0,5.0,0.5]],
                           [["USD","VND","EUR"], [0.0,10000.0,1.0]]] as [Any]
    
    
    let gradientView = GradientView()
    var isClear = false
    
    
    
    
    //MARK: Built-in function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = Global.colorMain
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    
        
        
        setLanguageRuntime()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.backgroundColor = Global.colorHeader
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: clear.localized(), style: .plain, target: self, action: #selector(event_btnClear))
        
        self.registerNibs()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isClear {
            self.searchService.searchParams = [String : Any]()
        }
        
        if let vc = self.searchController.searchResultsController,
            (self.searchController.searchResultsController?.isKind(of: SchoolListViewController.self))!
        {
            let schoollist = vc as! SchoolListViewController
            let name = schoollist.params[self.searchService.searchField.SCHOOLNAME]
            searchService.searchParams[self.searchService.searchField.SCHOOLNAME] = name
            schoollist.params = searchService.searchParams
//            schoollist.params[] = name
            schoollist.executeSearch()
        }
        
        
    }
    /////
    /////MARK: Language Changing here
    func setLanguageRuntime(){
        self.navigationItem.title = self.titleName.localized()
        self.navigationItem.rightBarButtonItem?.title = clear.localized()
    }
    
    //MARK: Events
    func event_btnClear(){
        self.isClear = true
        self.navigationController?.popViewController(animated: true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: nil)
        print("SSSSS")
    }
    
    
    //MARK UITableView DataSource
    func registerNibs(){
        self.tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: self.searchfieldId as String)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.searchfieldId as String) as! SearchTableViewCell
        
        
        cell.updateUI(fields: self.search_types[indexPath.row],
                      predata: self.fields_pre_data[indexPath.row] as! [Any],
                      cellDelegate: self
                      )
        cell.updateData(cellType: self.searchKeys[indexPath.row],
                        title: self.search_fields[indexPath.row],
                        searchService: self.searchService)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.search_fields.count
    }
    
    func updateTableView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    
    
    
    //MARK UITAbleView delegate
    
}
