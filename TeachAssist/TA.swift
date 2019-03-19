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
    
    func GetTaData(username:String, password:String) -> [NSMutableDictionary]?{
        //TODO add crashlitics
        self.username = username
        self.password = password
        let sr = SendRequest()
        let URL = "https://ta.yrdsb.ca/v4/students/json.php"
        var respToken = sr.SendJSON(url: URL, parameters: ["student_number":username, "password":password])
        
        //get main activity data
        if respToken == nil || respToken!["ERROR"] != nil{
            print("connection or auth error")
            print(respToken)
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
                course["mark"] = 80.0
            }else if mark.contains("%"){
                course["mark"] = Double(mark.replacingOccurrences(of:"%", with:"").trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        var httpResp = sr.Send(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "session_token": self.sessionToken, "student_id":self.studentID])
        
        if httpResp != nil{
            var courseNumber = 0
            for i in httpResp!.components(separatedBy: "<td>"){
                if(i.contains("current mark = ") || i.contains("Please see teacher for current status regarding achievement in the course")||i.contains("Click Here")||i.contains("Level")) {
                    let Course_Name = i.components(separatedBy: ":")[1].components(separatedBy:"<br>")[0].trimmingCharacters(in: .whitespacesAndNewlines);
                    let Room_Number = i.components(separatedBy: "rm. ")[1].components(separatedBy:"</td>")[0].trimmingCharacters(in: .whitespacesAndNewlines);
                    response[courseNumber]["Room_Number"] = Room_Number
                    response[courseNumber]["Course_Name"] = Course_Name
                    courseNumber += 1
                }
                
            }
            print(response)
        }
        
        return response
            
        
        
    }
    
    func CheckCredentials(username:String, password:String)-> Bool{
        //TODO add crashlitics
        let sr = SendRequest()
        let URL = "https://ta.yrdsb.ca/v4/students/json.php"
        var respToken = sr.SendJSON(url: URL, parameters: ["student_number":username, "password":password])
        
        //get main activity data
        if respToken == nil{
            print("returned nil")
            return false
        }
        if respToken!["ERROR"] != nil{
            return false
        }else{
            return true
        }
        
    }
}
