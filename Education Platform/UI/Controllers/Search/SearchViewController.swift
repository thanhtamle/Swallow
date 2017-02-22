//
//  SearchViewController.swift
//  Education Platform
//
//  Created by Duy Cao on 12/18/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Localize_Swift

class SearchViewController: UIViewController, UISearchControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: Outlet Reference
    @IBOutlet weak var collectionView : UICollectionView!
    
    //MARK: Runtime 
    var searchController : UISearchController!
    var searchResultController : UIViewController!
    var cellSizeForSection : [CGSize] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barTintColor = Global.colorMain
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.tintColor = UIColor.white
        
        
        setLanguageRuntime()
        self.navigationItem.title = ""
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .vertical

        self.registerNib()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLanguageRuntime), name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        self.assignSearchBarToNav()
    }
    
    func assignSearchBarToNav() {
        self.navigationItem.titleView = self.searchController?.searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setLanguageRuntime(){

    }
    
    func SetUpSearchController(result_delegate : UISearchBarDelegate){
        self.searchController.searchBar.delegate = result_delegate
        self.searchController.searchBar.addDoneOnKeyboard(withTarget: self, action: #selector(done_Event(sender:)))
        self.searchController.delegate = self
        self.searchController.searchBar.tintColor = Global.colorMain
        self.definesPresentationContext = true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
    }

    func done_Event(sender: UIView){
        self.searchController.isActive = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(self.view.frame.size, "Check orientation")
        self.resizeCell()
        self.collectionView.reloadData()
    }
    
    func resizeCell(){
        
    }
    
    func registerNib (){
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize()
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

