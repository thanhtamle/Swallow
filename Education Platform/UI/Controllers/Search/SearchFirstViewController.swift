//
//  SearchViewController.swift
//  Education Platform
//
//  Created by Duy Cao on 11/26/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Localize_Swift
import iCarousel
import RealmSwift
import Foundation
import Alamofire
import SwiftyJSON

class SearchFirstViewController: SearchViewController {
    var filterButton : UIBarButtonItem!
    let gradientView = GradientView()
    var schoolSuggests  = [SchoolSugestion]()
    let section = ["suggestion", "article_categories"]
    let titleid = "titleheader"
    let caoursel_cell = "carousel_cell"
    let categorycell_id = "categorycell"
    var listMajor = [SchoolStuff]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Global.colorHeader
        
        let resulvc = SchoolListViewController()
        resulvc.navVC = self.navigationController
        self.searchResultController = resulvc
        self.searchController = UISearchController(searchResultsController: self.searchResultController)
        self.SetUpSearchController(result_delegate: self.searchResultController as! UISearchBarDelegate)
        
        self.collectionView.backgroundColor = Global.colorHeader
        self.getDataSchool(numberItems: 5) { (success) in
            if(success == true) {
                self.collectionView.reloadData()
            }
        }
        
        StuffManager.sharedInstance.getStuff(complete: {
            SwiftOverlays.removeAllBlockingOverlays()
        })
    }
    
    override func setLanguageRuntime(){

    }
    
    override func SetUpSearchController(result_delegate: UISearchBarDelegate) {
        super.SetUpSearchController(result_delegate: result_delegate)
        self.searchController.searchResultsUpdater = self.searchResultController as! UISearchResultsUpdating?
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(SearchFirstViewController.FilterButtonEvent(sender:)))
        self.navigationItem.titleView = self.searchController.searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func FilterButtonEvent(sender : UIBarButtonItem){
        let advancedSearchViewController = AdvancedSearchViewController()
        advancedSearchViewController.title = "advanced_search"
        advancedSearchViewController.searchController = self.searchController
        self.navigationController?.pushViewController(advancedSearchViewController, animated: true)
    }
    
    override func registerNib (){
        self.collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil) , forCellWithReuseIdentifier: self.categorycell_id)
        self.collectionView.register(UINib(nibName: "SearchSectionTitleCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.titleid)
        self.collectionView.register(SuggestedCarouselView.self, forCellWithReuseIdentifier: self.caoursel_cell)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : listMajor.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell : UICollectionViewCell!
        let sec = indexPath.section
        switch sec {
        
        //MARK: Carousel View
        case 0:
            let cell1 = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.caoursel_cell, for: indexPath) as! SuggestedCarouselView
            cell1.updateUI()
            cell1.setData(data: schoolSuggests)
            cell = cell1
            
        //MARK: Category Cell
        default:
            let cell2 = self.collectionView.dequeueReusableCell(withReuseIdentifier: "categorycell", for: indexPath) as! CategoryCollectionViewCell
            cell2.setData(title: listMajor[indexPath.row].Name, image: #imageLiteral(resourceName: "university"))
            cell = cell2
        }
        
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                let viewreuse = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.titleid, for: indexPath) as! SearchSectionTitleCollectionReusableView
                viewreuse.setTitle(tit: section[indexPath.section].localized())
                return viewreuse
            default:
                return UICollectionReusableView()
            //assert(false, "Unexpected element kind")
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width : CGFloat, height : CGFloat
        switch indexPath.section {
        case 0:
            width = self.collectionView.frame.size.width
            height = width*2/3
        default:
            width = (self.collectionView.frame.size.width-1)/2
            height = 1/4 * width
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            SwiftOverlays.showBlockingWaitOverlay()
            SearchService.sharedInstrance.isCancelled = false
            let param = ["majors":listMajor[indexPath.row].Id]
            SearchService.sharedInstrance.searchSchool(params: param, complete: { (schools, total) in
                
                SwiftOverlays.removeAllBlockingOverlays()
                
                if schools.count == 0 {
                    Utils.showAlert(title: "sorry".localized(), message: "nothing_found".localized(), viewController: self)
                    return
                }
                let schoolvc = SchoolListViewController()
                schoolvc.navVC = self.navigationController
                schoolvc.setArgs(apiSearchString: "",
                                 params: param,
                                 initialList: schools,
                                 totalPage: total)
               //let nvschoolist = UINavigationController(rootViewController: schoolvc)
               self.navigationController?.pushViewController(schoolvc, animated: true)
                //self.present(nvschoolist, animated: true, completion: nil)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 20.0)
    }
    
    func getDataSchool(numberItems: Int,callback : @escaping (Bool) -> ()) {
        let header = ["lang":"jp"]
        Alamofire.request(Global.baseURL + "api/homes/list/\(numberItems)", method: .get, parameters: nil, encoding: URLEncoding.default,headers:header).responseJSON { response in
            switch response.result {
            case .success(let value):
               let json =  JSON(value)
               
               let data =  json["data"]
               let school_raw =  data["Schools"].arrayValue
               
               for each_raw in school_raw{
                let temp = SchoolSugestion(json: each_raw.rawString())
                self.schoolSuggests.append(temp)
                
               }
               self.getListMajor()
               callback(true)
               
                break
                
            case .failure(_):
               callback(false)
                break
            }
        }
    }
    
    func getListMajor(){
        Alamofire.request(Global.baseURL + "api/stuff/liststuff", method: .get, parameters: nil, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json =  JSON(value)
                
                let datas =  json["data"]["Majors"].arrayValue
                for each_raw in datas {
                    let temp = SchoolStuff(json: each_raw.rawString())
                    self.listMajor.append(temp)
                }
                self.listMajor.reverse()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                break
                
            case .failure(_):
                break
            }
        }

    
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchResultsController?.view.isHidden = false
    }
    
}

