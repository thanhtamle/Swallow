//
//  MessageResult.swift
//  Education Platform
//
//  Created by nquan on 12/26/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import Foundation
import EVReflection

class MessageResult: EVObject {
    dynamic var Messages = [ChatRowResult]()
    dynamic var TotalPage = 0
    dynamic var CurrentPage = 0
    dynamic var PageSize = 0
}
