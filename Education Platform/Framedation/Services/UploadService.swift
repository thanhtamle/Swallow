//
//  UploadService.swift
//  Education Platform
//
//  Created by Thanh-Tam Le on 2/8/17.
//  Copyright © 2017 Duy Cao. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JSONModel

protocol UploadServiceDelegate {
    func uploadImageFinished(success: Bool, message: String, data: String)
}

class UploadService: NSObject {

    static func uploadImage(image: Data, uploadServiceDelegate: UploadServiceDelegate?) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image, withName: "picture", fileName: "photo.jpeg", mimeType: "image/jpeg")
                
        },to: Global.baseURL + "api/image/uploads",
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let responseResult = ResponseResult(data: response.data!)
                    if responseResult.success == 1 {
                        if uploadServiceDelegate != nil {
                            uploadServiceDelegate?.uploadImageFinished(success: true, message: "" ,data: responseResult.data)
                        }
                    }
                    else {
                        if uploadServiceDelegate != nil {
                            uploadServiceDelegate?.uploadImageFinished(success: false, message: "could_not_connect_to_server_please_try_again".localized() ,data: "")
                        }
                    }
                }
            case .failure(_):
                if uploadServiceDelegate != nil {
                    uploadServiceDelegate?.uploadImageFinished(success: false, message: "could_not_connect_to_server_please_try_again".localized() ,data: "")
                }
            }
        })
    }
}
