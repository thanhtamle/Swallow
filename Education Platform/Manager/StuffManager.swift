//
//  StuffManager.swift
//  Education Platform
//
//  Created by Duy Cao on 12/18/16.
//  Copyright © 2016 Duy Cao. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StuffManager {

    var Majors : [Major] = [Major]()
    var Services : [Service] = [Service]()
    var Countries : [Country] = [Country]()
    
    private init(){
        
    }
    
    static let sharedInstance =  StuffManager()
    
    func getStuff(complete : @escaping ()->()){
        Alamofire.request(Global.baseURL + "api/stuff/liststuff").responseJSON(completionHandler: {
            response in
            switch response.result {
            case .success(let val):
                let jsonObj = JSON(val)
                let success = jsonObj["success"].boolValue
                if success {
                    let countrieArray = jsonObj["data"].dictionaryValue["Countries"]?.arrayValue
                    let majorArray = jsonObj["data"].dictionaryValue["Majors"]?.arrayValue
                    let serviceArray = jsonObj["data"].dictionaryValue["Services"]?.arrayValue
                    self.Majors = majorArray!.map({Major(json: $0.rawString())})
                    self.Services = serviceArray!.map({Service(json: $0.rawString())})
                    self.Countries = countrieArray!.map({Country(json: $0.rawString())})
                }
                complete()
                break
            case .failure(let err):
                print(err.localizedDescription)
                //TODO: Manage when time out
                return
            }
        })
    }
    
    func serviceNames() -> [String] {
        return self.Services.map({$0.Name})
    }
    
    func serviceIdOf(name : String){
        Services.index(where: { $0.Name == name})
    }
    
    func countryNames() -> [String] {
        return self.Countries.map({$0.CountryName})
    }
    
    func majorNames() -> [Major] {
        return self.Majors
    }
}
