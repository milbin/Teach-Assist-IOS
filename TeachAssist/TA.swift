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
        
        var counter = 0
        for var course in response{
            if course["subject_id"] != nil{
                self.courses.append(course["subject_id"]! as! String)
            }else{
                self.courses.append("NA")
            }
            let mark = course["mark"]! as! String
            if mark.contains("Please see teacher for current status regarding achievement in the course"){
                course["mark"] = "NA"
            }else if mark.contains("Level") || mark.contains("Click"){
                //TODO add a method to get the mark thingy
                course["mark"] = CalculateCourseAverage(subjectNumber: counter)
            }else if mark.contains("%"){
                course["mark"] = CalculateCourseAverage(subjectNumber: counter)
                print(CalculateCourseAverage(subjectNumber: counter))
                //course["mark"] = Double(mark.replacingOccurrences(of:"%", with:"").trimmingCharacters(in: .whitespacesAndNewlines))
            }
            counter += 1
        }
        
        var httpResp = sr.Send(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "session_token": self.sessionToken, "student_id":self.studentID])
        
        if httpResp != nil{
            var courseNumber = 0
            for i in httpResp!.components(separatedBy: "<td>"){
                if((i.contains("current mark = ") || i.contains("Please see teacher for current status regarding achievement in the course")||i.contains("Click Here")||i.contains("Level")||i.contains("Block")) && !i.contains("0000-00-00")) {
                    let Course_Name = i.components(separatedBy: ":")[1].components(separatedBy:"<br>")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities;
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
    
    func GetMarks(subjectNumber:Int) -> [String:Any]?{
        var sr = SendRequest()
        var params = ["student_id": self.studentID, "token":self.sessionToken, "subject_id":courses[subjectNumber]]
        var resp = sr.SendJSON(url: "https://ta.yrdsb.ca/v4/students/json.php", parameters: params)! as! [String : Any]
        if resp == nil{
            return nil
        }
        print(resp)
        if var assignments = ((resp["data"]! as! [String:Any])["assessment"]! as? [String:Any]){
            assignments = assignments["data"] as! [String:Any]
            for assignment in assignments{
                assignments[assignment.key] = assignment.value as! [String:Any]
            }
            for assignment in assignments{
                
                if assignment.key != "categories"{
                    var value = assignment.value as! [String:Any]
                    var feedback = value["feedback"] as? String
                    if feedback == nil{
                        feedback = ""
                    }
                    
                    assignments[assignment.key] = value
                }
            }
            
            
            
            return assignments
        }else{
            return nil
        }
        
        
        
    }
    
    func CalculateAverage(response:[NSMutableDictionary]) -> Double{
        var Average = 0.0
        var courses = 0.0
        var courseNum = 0
        for course in response{
            if let mark = course["mark"] as? String{
                if mark.contains("Level"){
                    Average += CalculateCourseAverage(subjectNumber: courseNum)
                    courses += 1
                }
            } else{
                Average += course["mark"] as! Double
                courses += 1
            }
            courseNum += 1
        }
        
        Average = round(10 * (Average / courses)) / 10
        
        return Average
    }
    
    func CalculateCourseAverage(subjectNumber:Int? = nil, markParam:[String:Any]? = nil) -> Double{
        var marks:[String:Any]?
        if markParam == nil{
            marks = GetMarks(subjectNumber: subjectNumber!)
        }else{
            marks = markParam!
        }
        
        var knowledge = 0.0
        var thinking = 0.0
        var communication = 0.0
        var application = 0.0
        var other = 0.0
        
        var totalWeightKnowledge = 0.0
        var totalWeightThinking = 0.0
        var totalWeightCommunication = 0.0
        var totalWeightApplication = 0.0
        var totalWeightOther = 0.0

        var weights = marks!["categories"] as! [String:Double]
        weights["O"] = nil
        for (key, value) in weights{
            weights[key] = value * 0.7
        }
        weights[""] = 0.3
       
        
        
        for (key, value) in marks!{
            if key != "categories"{
                var temp = value as! [String:Any]
                temp["feedback"] = nil
                temp["title"] = nil
                var assignment = temp as! [String:[String:String?]]
                
                
                var markK = 0.0
                var outOfK = 0.0
                var weightK = -0.1
                if assignment["K"] != nil && assignment["K"]!["mark"]! != nil{
                    markK = Double(assignment["K"]!["mark"]!!)!
                }else{
                    weightK = 0.0;
                }
                if assignment["K"] != nil && assignment["K"]!["outOf"]! != nil{
                    outOfK = Double(assignment["K"]!["outOf"]!!)!
                }
                if weightK == -0.1{
                    if assignment["K"]!["weight"]! != nil{
                        weightK = Double(assignment["K"]!["weight"]!!)!
                    }
                }
                if outOfK != 0.0{
                    knowledge += markK / outOfK * weightK;
                    totalWeightKnowledge += weightK;
                }
                
                var markT = 0.0
                var outOfT = 0.0
                var weightT = -0.1
                if assignment["T"] != nil && assignment["T"]!["mark"]! != nil{
                    markT = Double(assignment["T"]!["mark"]!!)!
                }else{
                    weightT = 0.0;
                }
                if assignment["T"] != nil && assignment["T"]!["outOf"]! != nil{
                    outOfT = Double(assignment["T"]!["outOf"]!!)!
                }
                if weightT == -0.1{
                    if assignment["T"]!["weight"]! != nil{
                        weightT = Double(assignment["T"]!["weight"]!!)!
                    }
                }
                if outOfT != 0.0{
                    thinking += markT / outOfT * weightT;
                    totalWeightThinking += weightT;
                }
                
                var markC = 0.0
                var outOfC = 0.0
                var weightC = -0.1
                if assignment["C"] != nil && assignment["C"]!["mark"]! != nil{
                    markC = Double(assignment["C"]!["mark"]!!)!
                }else{
                    weightC = 0.0;
                }
                if assignment["C"] != nil && assignment["C"]!["outOf"]! != nil{
                    outOfC = Double(assignment["C"]!["outOf"]!!)!
                }
                if weightC == -0.1{
                    if assignment["C"]!["weight"]! != nil{
                        weightC = Double(assignment["C"]!["weight"]!!)!
                    }
                }
                if outOfC != 0.0{
                    communication += markC / outOfC * weightC;
                    totalWeightCommunication += weightC;
                }
                
                var markA = 0.0
                var outOfA = 0.0
                var weightA = -0.1
                if assignment["A"] != nil && assignment["A"]!["mark"]! != nil{
                    markA = Double(assignment["A"]!["mark"]!!)!
                }else{
                    weightA = 0.0;
                }
                if assignment["A"] != nil && assignment["A"]!["outOf"]! != nil{
                    outOfA = Double(assignment["A"]!["outOf"]!!)!
                }
                if weightA == -0.1{
                    if assignment["A"]!["weight"]! != nil{
                        weightA = Double(assignment["A"]!["weight"]!!)!
                    }
                }
                if outOfA != 0.0{
                    application += markA / outOfA * weightA;
                    totalWeightApplication += weightA;
                }
                
                var markO = 0.0
                var outOfO = 0.0
                var weightO = -0.1
                if assignment[""] != nil && assignment[""]!["mark"]! != nil{
                    markO = Double(assignment[""]!["mark"]!!)!
                }else{
                    weightO = 0.0;
                }
                if assignment[""] != nil && assignment[""]!["outOf"]! != nil{
                    outOfO = Double(assignment[""]!["outOf"]!!)!
                }
                if weightO == -0.1{
                    if assignment[""]!["weight"]! != nil{
                        weightO = Double(assignment[""]!["weight"]!!)!
                    }
                }
                if outOfO != 0.0{
                    application += markO / outOfO * weightO;
                    totalWeightOther += weightO;
                }
                
            }
        }
        
        var Knowledge = weights["K"]!
        var Thinking = weights["T"]!
        var Communication = weights["C"]!
        var Application = weights["A"]!
        var Other = weights[""]!
        
        var finalKnowledge = 0.0
        var finalThinking = 0.0
        var finalCommunication = 0.0
        var finalApplication = 0.0
        var finalOther = 0.0
        
        //omit category if there is no assignment in it
        if totalWeightKnowledge != 0.0 {
            finalKnowledge = knowledge / totalWeightKnowledge;
        }else{
            finalKnowledge = 0.0;
            Knowledge = 0.0;
        }
        if totalWeightThinking != 0.0 {
            finalThinking = thinking/totalWeightThinking;
        }else{
            finalThinking = 0.0;
            Thinking = 0.0;
        }
        if totalWeightCommunication != 0.0 {
            finalCommunication = communication/totalWeightCommunication;
        }else{
            finalCommunication = 0.0;
            Communication = 0.0;
        }
        if totalWeightApplication != 0.0 {
            finalApplication = application/totalWeightApplication;
        }else{
            finalApplication = 0.0;
            Application = 0.0;
        }
        if totalWeightOther != 0.0 {
            finalOther = other/totalWeightOther;
        }else{
            finalOther = 0.0;
            Other = 0.0;
        }
        finalKnowledge = finalKnowledge*Knowledge
        finalThinking = finalThinking*Thinking
        finalCommunication = finalCommunication*Communication
        finalApplication = finalApplication*Application
        finalOther = finalOther*Other
    
        var Average = finalApplication + finalKnowledge + finalThinking + finalCommunication + finalOther
        Average = Average / (Knowledge + Thinking + Communication + Application + Other) * 100
        return round(Average*10) / 10 // will round to the tens position

    
        
    }
    
    
    
    func GetCategoryAndWeightsForCourse(marks:[String:Any]?) -> [Double]{
        
        var knowledge = 0.0
        var thinking = 0.0
        var communication = 0.0
        var application = 0.0
        var other = 0.0
        
        var totalWeightKnowledge = 0.0
        var totalWeightThinking = 0.0
        var totalWeightCommunication = 0.0
        var totalWeightApplication = 0.0
        var totalWeightOther = 0.0
        
        var weights = marks!["categories"] as! [String:Double]
        weights["O"] = nil
        for (key, value) in weights{
            weights[key] = value * 0.7
        }
        weights[""] = 0.3

        
        
        for (key, value) in marks!{
            if key != "categories"{
                var temp = value as! [String:Any]
                temp["feedback"] = nil
                temp["title"] = nil
                var assignment = temp as! [String:[String:String?]]
                
                
                var markK = 0.0
                var outOfK = 0.0
                var weightK = -0.1
                if assignment["K"] != nil && assignment["K"]!["mark"]! != nil{
                    markK = Double(assignment["K"]!["mark"]!!)!
                }else{
                    weightK = 0.0;
                }
                if assignment["K"] != nil && assignment["K"]!["outOf"]! != nil{
                    outOfK = Double(assignment["K"]!["outOf"]!!)!
                }
                if weightK == -0.1{
                    if assignment["K"]!["weight"]! != nil{
                        weightK = Double(assignment["K"]!["weight"]!!)!
                    }
                }
                if outOfK != 0.0{
                    knowledge += markK / outOfK * weightK;
                    totalWeightKnowledge += weightK;
                }
                
                var markT = 0.0
                var outOfT = 0.0
                var weightT = -0.1
                if assignment["T"] != nil && assignment["T"]!["mark"]! != nil{
                    markT = Double(assignment["T"]!["mark"]!!)!
                }else{
                    weightT = 0.0;
                }
                if assignment["T"] != nil && assignment["T"]!["outOf"]! != nil{
                    outOfT = Double(assignment["T"]!["outOf"]!!)!
                }
                if weightT == -0.1{
                    if assignment["T"]!["weight"]! != nil{
                        weightT = Double(assignment["T"]!["weight"]!!)!
                    }
                }
                if outOfT != 0.0{
                    thinking += markT / outOfT * weightT;
                    totalWeightThinking += weightT;
                }
                
                var markC = 0.0
                var outOfC = 0.0
                var weightC = -0.1
                if assignment["C"] != nil && assignment["C"]!["mark"]! != nil{
                    markC = Double(assignment["C"]!["mark"]!!)!
                }else{
                    weightC = 0.0;
                }
                if assignment["C"] != nil && assignment["C"]!["outOf"]! != nil{
                    outOfC = Double(assignment["C"]!["outOf"]!!)!
                }
                if weightC == -0.1{
                    if assignment["C"]!["weight"]! != nil{
                        weightC = Double(assignment["C"]!["weight"]!!)!
                    }
                }
                if outOfC != 0.0{
                    communication += markC / outOfC * weightC;
                    totalWeightCommunication += weightC;
                }
                
                var markA = 0.0
                var outOfA = 0.0
                var weightA = -0.1
                if assignment["A"] != nil && assignment["A"]!["mark"]! != nil{
                    markA = Double(assignment["A"]!["mark"]!!)!
                }else{
                    weightA = 0.0;
                }
                if assignment["A"] != nil && assignment["A"]!["outOf"]! != nil{
                    outOfA = Double(assignment["A"]!["outOf"]!!)!
                }
                if weightA == -0.1{
                    if assignment["A"]!["weight"]! != nil{
                        weightA = Double(assignment["A"]!["weight"]!!)!
                    }
                }
                if outOfA != 0.0{
                    application += markA / outOfA * weightA;
                    totalWeightApplication += weightA;
                }
                
                var markO = 0.0
                var outOfO = 0.0
                var weightO = -0.1
                if assignment[""] != nil && assignment[""]!["mark"]! != nil{
                    markO = Double(assignment[""]!["mark"]!!)!
                }else{
                    weightO = 0.0;
                }
                if assignment[""] != nil && assignment[""]!["outOf"]! != nil{
                    outOfO = Double(assignment[""]!["outOf"]!!)!
                }
                if weightO == -0.1{
                    if assignment[""]!["weight"]! != nil{
                        weightO = Double(assignment[""]!["weight"]!!)!
                    }
                }
                if outOfO != 0.0{
                    application += markO / outOfO * weightO;
                    totalWeightOther += weightO;
                }
                
            }
        }
        
        var Knowledge = weights["K"]!
        var Thinking = weights["T"]!
        var Communication = weights["C"]!
        var Application = weights["A"]!
        var Other = weights[""]!
        
        var finalKnowledge = 0.0
        var finalThinking = 0.0
        var finalCommunication = 0.0
        var finalApplication = 0.0
        var finalOther = 0.0
        
        //omit category if there is no assignment in it
        if totalWeightKnowledge != 0.0 {
            finalKnowledge = knowledge / totalWeightKnowledge;
        }else{
            finalKnowledge = 0.0;
            Knowledge = 0.0;
        }
        if totalWeightThinking != 0.0 {
            finalThinking = thinking/totalWeightThinking;
        }else{
            finalThinking = 0.0;
            Thinking = 0.0;
        }
        if totalWeightCommunication != 0.0 {
            finalCommunication = communication/totalWeightCommunication;
        }else{
            finalCommunication = 0.0;
            Communication = 0.0;
        }
        if totalWeightApplication != 0.0 {
            finalApplication = application/totalWeightApplication;
        }else{
            finalApplication = 0.0;
            Application = 0.0;
        }
        if totalWeightOther != 0.0 {
            finalOther = other/totalWeightOther;
        }else{
            finalOther = 0.0;
            Other = 0.0;
        }
        //finalKnowledge = finalKnowledge*Knowledge
        //finalThinking = finalThinking*Thinking
        //finalCommunication = finalCommunication*Communication
        //finalApplication = finalApplication*Application
        //finalOther = finalOther*Other
        print(finalKnowledge)
        //round to the tens position
        var returnList = [round(finalKnowledge*1000)/10, round(finalThinking*1000)/10, round(finalCommunication*1000)/10, round(finalApplication*1000)/10, round(finalOther*1000)/10]
        for i in [round(Knowledge*1000)/10, round(Thinking*1000)/10, round(Communication*1000)/10, round(Application*1000)/10, round(Other*1000)/10]{
            returnList.append(i)
        }
        
        print(returnList)
        return returnList
    
    
    
    
    }
    
    func calculateAssignmentAverage(assignment:[String:[String:String]], weights:[String:Double]) -> String{
        var weightList = ["K" : weights["K"]!*10*0.7, "T" : weights["T"]!*10*0.7, "C" : weights["C"]!*10*0.7, "A" : weights["A"]!*10*0.7, "":3.0]
        var markList = ["K" : 0.0, "T" : 0.0, "C" : 0.0, "A" : 0.0, "" : 0.0]
        let categoryList = ["K", "T", "C", "A", ""]
        
        
        for category in categoryList{
            if assignment[category] != nil{
                if assignment[category]!["mark"] != nil && assignment[category]!["mark"]! == "no mark" || assignment[category]!["mark"] == ""{
                    weightList[category] = 0.0
                }
                if assignment[category]!["outOf"] != nil && assignment[category]!["outOf"]! != "0" && assignment[category]!["outOf"]! != "0.0" {
                    if assignment[category]!["mark"] != nil{
                        markList[category] = round(10 * (Double(assignment[category]!["mark"]!)! / Double(assignment[category]!["outOf"]!)! * 100)) / 10
                    }else{
                        weightList[category] = 0.0
                    }
                    
                }
                
            }else{
                weightList[category] = 0.0
            }
            
            if markList[category] != nil && weightList[category] != nil{
                markList[category] = markList[category]! * weightList[category]!
            }
            
        }
        
        var average = (markList["K"]! + markList["T"]! + markList["C"]! + markList["A"]! + markList[""]!)
        average = average / (weightList["K"]! + weightList["T"]! + weightList["C"]! + weightList["A"]! + weightList[""]!)
        average = round(10 * average) / 10
        
        
        if average == 0.0{
            average = 0
        }
        if average == 100.0{
            average = 100
        }
        return String(average)
        
        
        
        
        
    }
}
