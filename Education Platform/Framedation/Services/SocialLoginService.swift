//
//  SocialLoginService.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 12/8/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Google
import Alamofire

class SocialLoginService: NSObject, GIDSignInDelegate {
    
    var viewController: UIViewController!
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func loginFacebook() {
        if AccessToken.current != nil {
            viewController.present(MainViewController(), animated:true, completion:nil)
        }
        else {
            let loginManager = LoginManager()
            
            loginManager.logIn([.publicProfile, .email], viewController: self.viewController, completion: {(loginResult: LoginResult) in
                switch loginResult {
                case .cancelled:
                    loginManager.logOut()
                    Utils.showAlert(title: "error".localized(), message: "could_not_login_please_try_again".localized(), viewController: self.viewController)
                case .failed(_):
                    loginManager.logOut()
                    Utils.showAlert(title: "error".localized(), message: "could_not_login_please_try_again".localized(), viewController: self.viewController)
                case .success(let grantedPermissions, _, let accessToken):
                    
                    if !grantedPermissions.isEmpty {
                        let connection = GraphRequestConnection()
                        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields":"id,email,name,picture.type(large),gender"], accessToken: accessToken, httpMethod: .GET, apiVersion: GraphAPIVersion.defaultVersion)) { httpResponse, result in
                            switch result {
                            case .success(let response):
                                var email:String = ""
                                var name:String = ""
                                var pictureUrl:String = ""
                                var pictdata:NSDictionary!
                                
                                if let Email = response.dictionaryValue?["email"] {
                                    email = Email as! String
                                }
                                
                                if let Name = response.dictionaryValue?["name"]{
                                    name = Name as! String
                                }
                                else {
                                    Utils.showAlert(title: "error".localized(), message: "could_not_login_please_check_facebook_account_security".localized(), viewController: self.viewController)
                                    loginManager.logOut()
                                    return
                                }
                                
                                if let picture = response.dictionaryValue?["picture"]{
                                    pictdata =  (picture as! NSDictionary)["data"] as? NSDictionary
                                    pictureUrl = pictdata?["url"] as! String
                                    
                                }
                                
                                SwiftOverlays.showBlockingWaitOverlay()
                                AccountService.loginSocial(token: accessToken.authenticationToken, type: "facebook", fullName: name, imageUrl: pictureUrl, email: email) { (success, message) in
                                    if success == true {
                                        UserDefaultManager.getInstance().setCurrentToken(value: accessToken.authenticationToken)
                                        UserDefaultManager.getInstance().setCurrentAccountType(value: "facebook")
                                        self.viewController.present(MainViewController(), animated:true, completion:nil)
                                    }
                                    else {
                                        loginManager.logOut()
                                        Utils.showAlert(title: "error".localized(), message: message, viewController: self.viewController)
                                    }
                                    SwiftOverlays.removeAllBlockingOverlays()
                                }
                            case .failed(_):
                                loginManager.logOut()
                                Utils.showAlert(title: "error".localized(), message: "could_not_login_please_try_again".localized(), viewController: self.viewController)
                            }
                        }
                        connection.start()
                    }
                }
            })
        }
    }
    
    func checkAccountParse(isHad: Bool) {
        SwiftOverlays.removeAllBlockingOverlays()
        let roleResult = UserDefaultManager.getInstance().getCurrentUser()!
        
        if (!isHad) {
            ParseMessage.registerUser(userName: roleResult.User.UserName, password: roleResult.User.UserName, email: roleResult.User.Email, fullName: roleResult.User.DisplayName, googleID: "", facebookID: "", avatarUrl: roleResult.User.Avatar)
        }
        else {
            ParseMessage.logInUser(userName: roleResult.User.UserName, password: roleResult.User.UserName, completion: loginFinished)
        }
        self.viewController.present(MainViewController(), animated:true, completion:nil)
    }
    
    func loginFinished(success: Bool) {
        print(success)
    }
    
    func loginGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            SwiftOverlays.showBlockingWaitOverlay()
            
            let token = user.authentication.accessToken as String
            let fullName = user.profile.name as String
            let email = user.profile.email as String
            
            var imageUrl = ""
            if user.profile.hasImage {
                imageUrl = user.profile.imageURL(withDimension: 300).absoluteString
            }
            
            AccountService.loginSocial(token: token, type: "google", fullName: fullName, imageUrl: imageUrl, email: email) { (success, message) in
                if success == true {
                    UserDefaultManager.getInstance().setCurrentToken(value: token)
                    UserDefaultManager.getInstance().setCurrentAccountType(value: "google")
                    self.viewController.present(MainViewController(), animated:true, completion:nil)
                }
                else {
                    GIDSignIn.sharedInstance().signOut()
                    Utils.showAlert(title: "error".localized(), message: message, viewController: self.viewController)
                }
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }
        else {
            GIDSignIn.sharedInstance().signOut()
            Utils.showAlert(title: "error".localized(), message: "could_not_login_please_try_again".localized(), viewController: self.viewController)
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().signOut()
        Utils.showAlert(title: "error".localized(), message: "could_not_login_please_try_again".localized(), viewController: self.viewController)
    }
    
}
