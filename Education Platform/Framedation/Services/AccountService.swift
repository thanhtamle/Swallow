//
//  AccountService.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 2/14/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import Alamofire
import SwiftyJSON
import JSONModel
import UIKit

class AccountService: NSObject {

    static func login(username: String, password: String, completion: @escaping (_ success: Bool, _ message: String) -> Void) {
        
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let body = ["username": username, "password": password] as [String : Any]
        
        Alamofire.request(Global.baseURL + "api/authenticate", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                let responseResult = ResponseResult(data: response.data!)
                if responseResult.success == 0 {
                    completion(false, "username_or_password_is_incorrect".localized())
                }
                else {
                    Alamofire.request(Global.baseURL + "getrole").responseJSON { response in
                        SwiftOverlays.removeAllBlockingOverlays()
                        switch response.result {
                        case .success(_):
                            let roleResult = RoleResult(data: response.data!)
                            UserDefaultManager.getInstance().setCurrentUser(roleResult: roleResult)
                            completion(true, "")
                        case .failure(_):
                            completion(false, "could_not_connect_to_server_please_try_again".localized())
                        }
                    }
                }
            case .failure(_):
                completion(false, "could_not_connect_to_server_please_try_again".localized())
            }
        }
    }

    static func signup(userResult: UserResult, completion: @escaping (_ success: Bool, _ message: String) -> Void) {
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let body = ["Id": userResult.Id, "UserName": userResult.UserName, "Password": userResult.Password, "DisplayName": userResult.DisplayName, "Email": userResult.Email, "Status": userResult.Status, "RoleId": userResult.RoleId, "UserMeta": [], "Active" : 1] as [String : Any]
        
        Alamofire.request(Global.baseURL + "api/user/registerOrUpdate", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                let responseResult = ResponseResult(data: response.data!)
                if responseResult.success == 0 {
                    completion(false, "username_or_email_already_exists_please_try_again".localized())
                }
                else {
                    AccountService.login(username: userResult.UserName, password: userResult.Password) { (success, message) in
                        if success == true {
                            completion(true, "")
                        }
                        else {
                            completion(false, "could_not_connect_to_server_please_try_again".localized())
                        }
                    }
                }
            case .failure(_):
                completion(false, "could_not_connect_to_server_please_try_again".localized())
            }
        }
    }
    
    static func loginSocial(token: String, type: String, fullName: String, imageUrl: String, email: String, completion: @escaping (_ success: Bool, _ message: String) -> Void) {
        
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let body = ["Token": token, "TypeSocial": type, "DisplayName": fullName, "Avatar": imageUrl, "Email": email] as [String : Any]
        
        Alamofire.request(Global.baseURL + "api/authenticateSocial", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                let responseResult = ResponseResult(data: response.data!)
                if responseResult.success == 0 {
                    completion(false, "could_not_login_please_try_again".localized())
                }
                else {
                    Alamofire.request(Global.baseURL + "getrole").responseJSON { response in
                        SwiftOverlays.removeAllBlockingOverlays()
                        switch response.result {
                        case .success(_):
                            let roleResult = RoleResult(data: response.data!)
                            UserDefaultManager.getInstance().setCurrentUser(roleResult: roleResult)
                            completion(true, "")
                        case .failure(_):
                            completion(false, "could_not_login_please_try_again".localized())
                        }
                    }
                }
            case .failure(_):
                completion(false, "could_not_login_please_try_again".localized())
            }
        }
    }
}
