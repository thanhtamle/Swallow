//
//  Location.swift
//  Education Platform
//
//  Created by Duy Cao on 12/15/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import EVReflection

class Location: EVObject {
    
    dynamic var Id : Int = 0
    dynamic var Title : String = ""
    dynamic var FullAddress: String = ""
    dynamic var PostId : Int = 0
    dynamic var PostalCode : Int = 0
    dynamic var StateCityLocation : String = ""
    dynamic var CountryCode : Int = 0
    dynamic var Latitude : Double = 0.0
    dynamic var Longtitude : Double = 0.0
}
