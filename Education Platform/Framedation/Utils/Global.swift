//
//  Global.swift
//  Signature
//
//  Created by Thanh-Tam Le on 9/23/16.
//  Copyright © 2016 Thanh-Tam Le. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift


class Global {
    
    static let colorMain = UIColor(0x1AA79B)
    static let colorSecond = UIColor(0x33B476)
    static let colorSelected = UIColor(0x434F5D)
    static let colorBg = UIColor(0xE6E7E8)
    static let colorStatus = UIColor(0x333333)
    static let colorGray = UIColor(0x9E9E9E)
    static let colorHeader = UIColor(0xF1F5F8)
    static let colorFacebook = UIColor(0x3C5A98)
    static let colorGoogle = UIColor(0xDD4D3E)
    static let colorIncomMessage = UIColor(0x448AFF)
    static let colorOutcomMessage = UIColor(0xBDBDBD)
    static let colorCloud = UIColor(0xecf0f1)
    static let colorFollow = UIColor(0x2AC437)
    static let colorUnSeen = UIColor(0xdfe3ee)
    static let colorDeepPurple = UIColor(0x5E35B1)
    static let colorBrown = UIColor(0x5D4037)
    static let colorOriganDark = UIColor(0xF57F17)

    static let imageSize = CGSize(width: 1024, height: 768)
    
    static var SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static var SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    
    static let baseURL = "http://54.238.242.158:80/"
    static let socketURL = "http://54.238.242.158:80/ws"
    
}


struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE  = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPAD    = UIDevice.current.userInterfaceIdiom == .pad
}


