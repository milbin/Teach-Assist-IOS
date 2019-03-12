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
    func SendJSON(url:String, parameters:Dictionary<String, String>)->[String:Any]?{
        print("sending request")
        let params = parameters
        let semaphore = DispatchSemaphore(value: 0)
        //var request = AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default)
        var resp:[[String:Any]]?
        
        AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default).responseJSON(queue: DispatchQueue.global(qos: .default)) { response in
            switch response.result {
            case .success(let value):
                print(value)
                resp = value as! [[String:Any]]
                print(resp)
            case .failure(let error):
                resp = nil
                print(error)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        print("REQUEST FINISHED")
        if resp == nil{
            return nil
        }
        return resp![0]
    }
}




