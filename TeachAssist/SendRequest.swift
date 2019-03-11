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
    var requestFinished = false
    var resp:[Dictionary<String,String>]?
    
    func SendJSON(url:String, parameters:Dictionary<String, String>, completionHandler: @escaping ([Dictionary<String,String>]?) -> ()){
        print("sending request")
        let params = parameters

        AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default)
            .responseJSON{ response in
                switch response.result {
                    case .success(let value):
                        print("REQUEST FINISHED")
                        completionHandler(value as? [Dictionary<String,String>])
                    case .failure(let error):
                        print(error)
                        completionHandler(nil)
                }
        }
    }
}




