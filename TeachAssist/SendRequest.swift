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
        var notificationResp:[String:Any]?
        
        AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default).responseJSON(queue: DispatchQueue.global(qos: .default)) { response in
            switch response.result {
            case .success(let value):
                resp = value as? [[String:Any]]
                if resp == nil{
                    notificationResp = value as? [String:Any]
                    if notificationResp == nil || notificationResp!["result"] == nil{
                        notificationResp = nil
                    }
                }
            case .failure(let error):
                resp = nil
                print(error)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if notificationResp != nil{
            return notificationResp
        }
        if resp == nil{
            return nil
        }
        
        return resp![0]
    }
    
    func Send(url:String, parameters:Dictionary<String, String>)->String?{
        //print("sending request")
        let semaphore = DispatchSemaphore(value: 0)
        //var request = AF.request(url, method:.post, parameters:params, encoding:JSONEncoding.default)
        var resp:String?
        
        AF.request(url, method:.post, parameters:parameters).responseString(queue: DispatchQueue.global(qos: .default)) { response in
            switch response.result {
            case .success(let value):
                resp = value
            case .failure(let error):
                resp = nil
                print(error)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if resp == nil{
            return nil
        }
        return resp!
    }
    func SendWithCookies(url:String, parameters:Dictionary<String, String>, cookies:HTTPCookie?)->[String?]?{
        //print("sending request")
        let semaphore = DispatchSemaphore(value: 0)
        var resp:[String?] = [String?]()
        if(cookies != nil){
            HTTPCookieStorage.shared.setCookie(cookies!)
        }
        
        AF.request(url, method:.post, parameters:parameters).responseString(queue: DispatchQueue.global(qos: .default)) { response in
            switch response.result {
            case .success(let value):
                resp.append(value)
                let cookies = HTTPCookieStorage.shared.cookies!
                for cookie in cookies{
                    if cookie.name == "session_token"{
                        resp.append(cookie.value)
                    }else if cookie.name == "student_id"{
                        resp.append(cookie.value)
                    }
                }
                
                
            case .failure(let error):
                print(error)
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        if resp.count == 0{
            return nil
        }
        return resp
    }
}




