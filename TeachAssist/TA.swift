//
//  ta.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-10.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import Foundation

class TA{
    var sessionToken:String = ""
    var studentID:String = ""
    var username:String = ""
    var password:String = ""
    
    func GetTaData(username:String, password:String) -> Any?{
        //TODO add crashlitics
        self.username = username
        self.password = password
        let sr = SendRequest()
        let URL = "https://ta.yrdsb.ca/v4/students/json.php"
        var respToken = sr.SendJSON(url: URL, parameters: ["student_number":username, "password":password])
        print(respToken)
        
        //get main activity data
        if respToken == nil{
            print("returned nil")
            return nil
        }
        self.studentID = respToken!["student_id"] as! String
        self.sessionToken = respToken!["token"] as! String
        print(self.sessionToken)
        let params = ["token":sessionToken, "student_id":self.studentID]
        var resp:[[String:[Dictionary<String,String>]]] = sr.SendJSON(url: URL, parameters: params)!["data"]! as! [[String : [Dictionary<String,String>]]]
        if resp == nil{
            return nil
        }
        var resp1 = resp[0]["subjects"]!
        print(resp)
        var response = [NSMutableDictionary]()
        for course in resp1{
            let dict = NSMutableDictionary()
            for (key, value) in course{
                dict[key] = value
            }
            response.append(dict)
        }
        
        for var course in response{
            let mark = course["mark"]! as! String
            if mark.contains("Please see teacher for current status regarding achievement in the course"){
                course["mark"] = "NA"
            }else if mark.contains("Level"){
                //TODO add a method to get the mark thingy
            }else if mark.contains("%"){
                course["mark"] = Double(mark.replacingOccurrences(of:"%", with:"").trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        print(response)
        
        var httpResp = sr.Send(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "session_token": self.sessionToken, "student_id":self.studentID])
        
        return nil
            
        
        
    }
}
