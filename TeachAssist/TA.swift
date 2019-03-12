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
        var resp = sr.SendJSON(url: URL, parameters: ["student_number":username, "password":password])
        print(resp)
        
        //get main activity data
        if resp == nil{
            print("returned nil")
            return nil
        }
        resp = resp!
        self.studentID = resp!["student_id"] as! String
        self.sessionToken = resp!["token"] as! String
        print(self.sessionToken)
        let params = ["token":sessionToken, "student_id":self.studentID]
        var response = sr.SendJSON(url: URL, parameters: params)
        print(response)
        if response == nil{
            return nil
        }
        response = response!
        return response
            
        
        
    }
}
