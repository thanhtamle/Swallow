//
//  Courses.swift
//  Education Platform
//
//  Created by nquan on 1/20/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import Foundation
import UIKit
import EVReflection

class Courses: EVObject {
    dynamic var Id : Int = 0
    dynamic var SchoolId : Int = 0
    dynamic var Name : String = ""
    dynamic var PriceStart : Int = 0
    dynamic var PriceEnd : Int = 0
    dynamic var TimeApply: String = ""
    dynamic var Description:String = ""
    var majors = [Majors]()
}
