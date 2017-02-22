//
//  SchoolData.swift
//  Education Platform
//
//  Created by Duy Cao on 12/15/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit

class School {
    var SchoolData : SchoolDataM!
    var photos : [Photo]?
    var services : [Service]?
    var SchoolPost : SchoolPostM!
    var LocationData : Location!
    var ContactData : Contact!
    func setData(data: SchoolDataM, post : SchoolPostM, LocationData: Location, photos : [Photo]?){
        self.SchoolData = data
        self.SchoolPost = post
        self.photos = photos == nil ? [Photo]() : photos
        self.LocationData = LocationData
    }
}
