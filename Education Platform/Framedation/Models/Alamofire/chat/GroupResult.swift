//
//  GroupResult.swift
//  Education Platform
//
//  Created by nquan on 12/26/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import Foundation
import EVReflection

class GroupResult: EVObject {

    dynamic var Id:String = ""
    dynamic var LastMessage = ""
    dynamic var LastUid:Int64 = 0
    dynamic var updated_time = ""
    dynamic var UnSeen = 0
    dynamic var Users = [ChatUserResult]()
    
}
