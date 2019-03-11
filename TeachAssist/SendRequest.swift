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
        let semaphore = DispatchSemaphore(value: 0)
        var request = AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default)
        var resp:[Dictionary<String,String>]?
        
        request.responseJSON(queue: DispatchQueue.global(qos: .default)) { response in
            switch response.result {
            case .success(let value):
                print("REQUEST FINISHED")
                resp = value as? [Dictionary<String,String>]
                completionHandler(value as? [Dictionary<String,String>])
            case .failure(let error):
                print(error)
                completionHandler(nil)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        print(resp)
            /*response
            .responseJSON{ response in
                switch response.result {
                    case .success(let value):
                        print("REQUEST FINISHED")
                        completionHandler(value as? [Dictionary<String,String>])
                    case .failure(let error):
                        print(error)
                        completionHandler(nil)
                }
        }*/
    }
}




