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
    
    func GetTaData(username:String, password:String){
        //TODO add crashlitics
        self.username = username
        self.password = password
        let sr = SendRequest()
        let URL = "https://ta.yrdsb.ca/v4/students/json.php"
        let params = ["student_number":username, "password":password]
        var resp = sr.SendJSON(url: URL, parameters: params)
        /*func useToken(resp:Dictionary<String,String>){
            print(resp)
            self.studentID = resp["student_id"]!
            self.sessionToken = resp["sessionToken"]!
            let params = ["student_id":self.studentID, "token":sessionToken, "subject_id":"0"]
            sr.SendJSON(url: URL, parameters: params, completionHandler: <#T##([Dictionary<String, String>]?) -> ()#>)
        }*/
        print("IT WORKS")
        print(resp)
            
        
        
    }
}
