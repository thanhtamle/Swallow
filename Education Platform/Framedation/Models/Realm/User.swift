//
//  User.swift
//  MyLifeMatters
//
//  Created by MD101 on 11/25/16.
//  Copyright © 2016 Thanh-Tam Le. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    dynamic var id : Int = Int(0)
    dynamic var DisplayName: String = ""
    dynamic var UserName : String = ""
    dynamic var Email : String = ""
    dynamic var Password : String = ""
    dynamic var Status :String = ""
    dynamic var RoleId : Int = 1
//    dynamic var UserMeta : [Int] = [Int]()
    dynamic var account : String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
