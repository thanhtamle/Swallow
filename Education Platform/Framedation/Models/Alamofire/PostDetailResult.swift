//
//  PostDetailResult.swift
//  Education Platform
//
//  Created by nquan on 2/6/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import Foundation
import UIKit
import EVReflection

class PostDetailResult : EVObject {
    dynamic var Id : Int64 = 0
    dynamic var Title : String = ""
    dynamic var Description : String = ""
    dynamic var DescriptionHtml : String = ""
    dynamic var ShortDescription : String = ""
    dynamic var created_time : String = ""
    dynamic var created_uid : Int64 = 0
    
}
