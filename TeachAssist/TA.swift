//
//  ta.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-10.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import Foundation
import HTMLString

class TA{
    var sessionToken:String = ""
    var studentID:String = ""
    var username:String = ""
    var password:String = ""
    var courses = [String]()
    
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
            if course["subject_id"] != nil{
                self.courses.append(course["subject_id"]! as! String)
            }else{
                self.courses.append("NA")
            }
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
                    let Course_Name = i.components(separatedBy: ":")[1].components(separatedBy:"<br>")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities;
                    let Room_Number = i.components(separatedBy: "rm. ")[1].components(separatedBy:"</td>")[0].trimmingCharacters(in: .whitespacesAndNewlines);
                    response[courseNumber]["Room_Number"] = Room_Number
                    response[courseNumber]["Course_Name"] = Course_Name
                    courseNumber += 1
                }
                
            }
            print(response)
            GetMarks(subjectNumber: 0)
            CalculateCourseAverage(subjectNumber: 0)
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
    
    func GetMarks(subjectNumber:Int) -> [String:Any]?{
        var sr = SendRequest()
        var params = ["student_id": self.studentID, "token":self.sessionToken, "subject_id":courses[subjectNumber]]
        var resp = sr.SendJSON(url: "https://ta.yrdsb.ca/v4/students/json.php", parameters: params)! as! [String : Any]
        if resp == nil{
            return nil
        }
        var assignments = ((resp["data"]! as! [String:Any])["assessment"]! as! [String:Any])["data"] as! [String:AnyObject]
        print(assignments)
        return assignments
    }
    
    func CalculateCourseAverage(subjectNumber:Int){
        var marks = GetMarks(subjectNumber: subjectNumber)
        var knowledge = 0.0
        var thinking = 0.0
        var communication = 0.0
        var application = 0.0
        
        var totalWeightKnowledge = 0.0
        var totalWeightThinking = 0.0
        var totalWeightCommunication = 0.0
        var totalWeightApplication = 0.0

        var weights = marks!["categories"]
        
        for (key, value) in marks!{
            if key != "categories"{
                var temp = value as! [String:Any]
                temp["feedback"] = nil
                temp["title"] = nil
                var assignment = temp as! [String:[String:String]]
                var markK = 0.0
                var outOfK = 0.0
                var weightK = -0.1
                if assignment["K"] != nil && assignment["K"]!["mark"] != nil{
                    markK = Double(assignment["K"]!["mark"]!)!
                }else{
                    weightK = 0.0;
                }
                if assignment["K"] != nil && assignment["K"]!["outOf"] != nil{
                    outOfK = Double(assignment["K"]!["outOf"]!)!
                }
                if weightK == -0.1{
                    if assignment["K"]!["weight"] != nil{
                        weightK = Double(assignment["K"]!["weight"]!)!
                    }
                }
                if outOfK != 0.0{
                    knowledge += markK / outOfK * weightK;
                    totalWeightKnowledge += weightK;
                }


            }
        }
        print(knowledge)
        print(totalWeightKnowledge)
    
        
    }
}
