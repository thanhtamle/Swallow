
//
//  AppDelegate.swift
//  Education Platform
//
//  Created by Duy Cao on 11/26/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import CoreData
import PureLayout
import IQKeyboardManager
import Fabric
import Crashlytics
import Localize_Swift
import FacebookCore
import Google
import UserNotifications
import Parse
import Alamofire
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.black
        self.window?.makeKeyAndVisible()
        
        if UserDefaultManager.getInstance().getCurrentLanguage() == 0 {
            Localize.setCurrentLanguage("en")
        }
        else {
            let language = LanguageManager.getInstance().languages[UserDefaultManager.getInstance().getCurrentLanguage()!]
            Localize.setCurrentLanguage(language.code)
        }
        
        self.window?.rootViewController = SplashScreenViewController()
        
        //TestFairy
        TestFairy.begin("9dde72eec2ad7ff5df731451ef5079d47f21d309")
        
        //Crashlytics
        Fabric.with([Crashlytics.self])
        
        //set light status bar for whole ViewController
        UIApplication.shared.statusBarStyle = .lightContent
        
        // change status bar background color
//        let statusView = (application.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as! UIView
//        statusView.backgroundColor = Global.colorStatus
        
        // change navigation bar background color and tint color
        UINavigationBar.appearance().backgroundColor = Global.colorSelected
        UINavigationBar.appearance().setBackgroundImage(UIImage(named:"navBar.png"), for: .default)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //Change color of text in bar button
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
        
        // change tab bar background color and tint color
        UITabBar.appearance().tintColor = Global.colorMain
        UITabBar.appearance().barTintColor = UIColor.white
        UITextField.appearance().tintColor = Global.colorMain
        
        // keyboard
        let keyboardManager = IQKeyboardManager.shared()
        keyboardManager.isEnabled = true
        keyboardManager.previousNextDisplayMode = .alwaysShow
        keyboardManager.shouldShowTextFieldPlaceholder = false
        
        //FB
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Google
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        //Local Notification
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes , categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //Parse Configuration
        let configuration = ParseClientConfiguration {
            $0.applicationId = "swallow_parse_server"
            $0.clientKey = "123456789"
            $0.server = "http://115.73.217.225:1337/parse"
        }
        Parse.initialize(with: configuration)
        
        //change orientation
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        return true
    }
    
    var isInit = false
    func rotated() {
        if isInit {
            return
        }
  
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            print("Landscape")
            Global.SCREEN_WIDTH = UIScreen.main.bounds.size.height
            Global.SCREEN_HEIGHT = UIScreen.main.bounds.size.width
            isInit = true
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("Portrait")
            Global.SCREEN_WIDTH = UIScreen.main.bounds.size.width
            Global.SCREEN_HEIGHT = UIScreen.main.bounds.size.height
            isInit = true
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        WebSocketServices.shared.Disconnect()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        let currentUser = UserDefaultManager.getInstance().getCurrentUser()
        
        if currentUser == nil {
            return
        }
        
        if(currentUser?.User.Id != 0) {
            WebSocketServices.shared.Connect(UserId: (currentUser?.User.Id)!, Token: (currentUser?.User.Token)!)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
        print("applicationDidBecomeActive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.channels = ["global"]
        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //PFPush.handle(userInfo)
        print("User Infor Push \(userInfo)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadMessages"), object: nil)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options) || GIDSignIn.sharedInstance().handle(url,sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return SDKApplicationDelegate.shared.application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
   

  
}

