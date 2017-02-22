//
//  ChatUserResult.swift
//  Education Platform
//
//  Created by nquan on 12/26/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import Foundation
import EVReflection

class ChatUserResult: EVObject{
    
    dynamic var Id:Int64 = 0
    dynamic var UserName = ""
    dynamic var Password = ""
    dynamic var DisplayName = ""
    dynamic var Email = ""
    dynamic var Avatar = ""
    dynamic var ConfirmFlag = 0
}
