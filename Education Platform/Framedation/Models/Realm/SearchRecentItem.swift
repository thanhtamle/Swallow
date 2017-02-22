//
//  SearchRecentItem.swift
//  Education Platform
//
//  Created by Duy Cao on 12/15/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import RealmSwift

class SearchRecentItem: Object {
    dynamic var dateCreate: NSDate = NSDate()
    dynamic var iTemstring : String  = ""
    
    override static func primaryKey() -> String? {
        return "iTemstring"
    }
}


