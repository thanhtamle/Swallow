
//  SearchResultController.swift
//  Education Platform
//
//  Created by Duy Cao on 12/1/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import RealmSwift
import Realm

class SuggestSearchViewController: UIViewController,UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let iconSearch = FAKIonIcons.iosSearchIcon(withSize: 25.0).image(with: CGSize(width: 25.0, height: 25.0))
    var querystring : [SearchRecentItem]!
    var imageView : UIImageView!
    let searchService = SearchService.sharedInstrance
    let searchRecentItemDAO = SearchRecentItemDAO.sharedInstanced
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView = UIImageView(image: iconSearch)
        
//        self.querystring = SearchRecentItemDAO.getItemStartWith(searchString: "")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: SEARCh result update
    
    func updateSearchResults(for searchController: UISearchController) {
        //update table view here
        self.querystring = searchRecentItemDAO.getItemStartWith(searchString: searchController.searchBar.text!)
        self.tableView.reloadData()
    }
    
    //MARK: Datasource and Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let par = querystring {
            return par.count
        }
        return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.imageView?.tintColor = Global.colorMain
        cell.imageView?.image = self.iconSearch?.withRenderingMode(.alwaysTemplate)
        cell.textLabel?.text = self.querystring[indexPath.row].iTemstring
        cell.textLabel?.textColor = Global.colorMain
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.executeSearch(searchItem: querystring[indexPath.row].iTemstring)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
//  MARK:  searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.executeSearch(searchItem: searchBar.text!)
    }
    
    func executeSearch(searchItem : String){
        SwiftOverlays.showBlockingWaitOverlay()
        if !searchItem.isEmpty && !searchItem.removeSpaceAndTolowerCaseString().isEmpty {
            searchRecentItemDAO.addItem(str: searchItem)
            searchService.searchParams[searchService.searchField.SCHOOLNAME] = searchItem
        }else{
            searchService.searchParams[searchService.searchField.SCHOOLNAME] = ""
        }
        searchService.isCancelled = false
        searchService.searchSchool(params: searchService.searchParams, complete: {
            schools, totalPage in
            SwiftOverlays.removeAllBlockingOverlays()
            
            if schools.count == 0 {
                Utils.showAlert(title: "sorry".localized(), message: "nothing_found".localized(), viewController: self)
                return
            }
            let schoolvc = SchoolListViewController()
            schoolvc.setArgs(apiSearchString: "",
                             params: self.searchService.searchParams,
                             initialList: schools,
                             totalPage: totalPage)
            let nvschoolist = UINavigationController(rootViewController: schoolvc)
            self.present(nvschoolist, animated: true, completion: nil)
        })
    }

    
}
