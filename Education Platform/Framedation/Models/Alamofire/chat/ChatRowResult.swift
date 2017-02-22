//
//  ChatRowResult.swift
//  Education Platform
//
//  Created by nquan on 12/26/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import Foundation
import EVReflection

class ChatRowResult: EVObject
{
    dynamic var Id:Int64 = 0
    dynamic var User = ChatUserResult()
    dynamic var Message = ""
    dynamic var GroupId = ""
    dynamic var SeenFlag = 0
    dynamic var updated_time = ""
}
