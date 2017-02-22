//
//  NotificationServices.swift
//  Education Platform
//
//  Created by nquan on 2/6/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NotificationServices {
    
    private static var sharedInstance: NotificationServices!
    
    var notifications = [NotificationResult]()
    
    static func getInstance() -> NotificationServices {
        if(sharedInstance == nil) {
            sharedInstance = NotificationServices()
        }
        return sharedInstance
    }
    
    func refreshNotification(type: Bool, currentPage : Int,completion: @escaping (_ userData: [NotificationResult], _ success: Bool) -> Void) {
        var result = [NotificationResult]()
        
        let headers = ["lang":"jp"]
        Alamofire.request(Global.baseURL + "api/user/getNotification?pageSize=15&currentPage=" + String(currentPage),headers:headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let responseResult = ResponseResult(data: response.data!)
                if responseResult.success == 1 {
                    let json = JSON(value)
                    let data = json["data"]["Notifications"].arrayValue
   
                    for each in data {
                        let temp = NotificationResult()
                        temp.Id = each["Id"].int64Value
                        temp.Uid = each["Uid"].int64Value
                        temp.ContentId = each["ContentId"].int64Value
                        temp.SeenFlag = each["SeenFlag"].intValue
                        temp.created_time = each["created_time"].stringValue
                        temp.PostUid = each["PostUid"].int64Value
                        temp.PostType = each["PostType"].int64Value
                        temp.UserName = each["UserName"].stringValue
                        temp.Avatar = each["Avatar"].stringValue
                        temp.langId = each["langId"].int64Value
                        let postTemp = NewsInterface()
                        postTemp.Id = each["PostDetail"]["Id"].intValue
                        postTemp.Title = each["PostDetail"]["Title"].stringValue
                        postTemp.Description = each["PostDetail"]["Description"].stringValue
                        postTemp.DescriptionHtml = each["PostDetail"]["DescriptionHtml"].stringValue
                        postTemp.ShortDescription = each["PostDetail"]["ShortDescription"].stringValue
                        postTemp.created_time = each["PostDetail"]["created_time"].stringValue
                        postTemp.created_uid = each["PostDetail"]["created_uid"].intValue
                        temp.PostDetail = postTemp
                        result.append(temp)
                    }
                    completion(result, true)
                }
                
            case .failure(_):
                completion(result, false)
            }
        }
    }
    
    static func seenNotification(Id: Int64,completion: @escaping (_ success: Bool)->Void){
        
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let body = ["id":Id] as [String : Any]
        
        Alamofire.request(Global.baseURL + "api/user/seenNotification", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let success = json["success"].boolValue
                completion(success)
                break
            case .failure(_):
                completion(false)
                break
            }
        }
    }
}
