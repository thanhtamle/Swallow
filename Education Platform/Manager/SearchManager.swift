//
//  SearchManager.swift
//  Education Platform
//
//  Created by Duy Cao on 12/15/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Alamofire

class SearchManager {
    private static var sharedInstance : SearchManager!
    
    func querySchool(params: [String: Any], complete: ()->()){
        
    }
    
    static func getInstance() -> SearchManager{
        if let instance = SearchManager.sharedInstance {
            return instance
        }
        SearchManager.sharedInstance = SearchManager()
        return SearchManager.sharedInstance
    }
    
    private init(){
        
    }
}
