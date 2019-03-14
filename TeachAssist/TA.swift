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
        var resp = sr.SendJSON(url: URL, parameters: params)
        print(resp)
        if resp == nil{
            return nil
        }
        var response = resp!["subjects"]
        
        sr.Send(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "session_token": self.sessionToken, "student_id":self.studentID])
        return nil
            
        
        
    }
}
