//
//  NotificationManager.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 1/19/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit

class NotificationManager {

    private static var sharedInstance: NotificationManager!
    
    var news = [News]()
    
    static func getInstance() -> NotificationManager {
        if(sharedInstance == nil) {
            sharedInstance = NotificationManager()
        }
        return sharedInstance
    }
    
    private init() {
        
    }

}
