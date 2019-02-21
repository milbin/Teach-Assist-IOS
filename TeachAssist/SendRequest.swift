//
//  SendRequest.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-08.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import Foundation
import Alamofire

class SendRequest{
    func SendJSON(url:String, parameters:Dictionary<String, String>){
        let params = parameters
        AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default).responseJSON{ response in
            if let result = response.result.value{
               // let JSON = result as! NSDictionary
                print(result)
            }
        }
        
    }
}




