//
//  ta.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-10.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import Foundation
import HTMLString
import SwiftyJSON

class TA{
    var sessionToken:String = ""
    var studentID:String = ""
    var username:String = ""
    var password:String = ""
    var courses = [String]()
    var didRecursivelyCallGetTaData = false
    var didRecursivelyCallCalculateAssignmentAverage = false
    
    func GetTaData(username:String, password:String) -> [NSMutableDictionary]?{
        let htmlResp = GetTaData2(username: username, password: password)
        if(htmlResp != nil){
            return htmlResp
        }
        return nil
        /*//TODO add crashlitics
        self.username = username
        self.password = password
        let sr = SendRequest()
        let URL = "https://ta.yrdsb.ca/v4/students/json-20180628.php"
        var respToken = sr.SendJSON(url: URL, parameters: ["student_number":username, "password":password])
        
        //get main activity data
        if respToken == nil || respToken!["ERROR"] != nil{
            print("connection or auth error")
            let htmlResp = GetTaData2(username: username, password: password)
            if(htmlResp != nil){
                return htmlResp
            }
            return nil
        }
        self.studentID = respToken!["student_id"] as! String
        self.sessionToken = respToken!["token"] as! String
        let params = ["token":sessionToken, "student_id":self.studentID]
        if let resp:[[String:[Dictionary<String,String>]]]? = sr.SendJSON(url: URL, parameters: params)?["data"] as? [[String : [Dictionary<String,String>]]]{
            if(resp![0]["subjects"] == nil && !didRecursivelyCallGetTaData){
                didRecursivelyCallGetTaData = true
                return GetTaData(username:username, password:password)
            }
            var resp1 = resp![0]["subjects"]!
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
                var mark = course["mark"]! as! String
                if mark.contains("Please see teacher for current status regarding achievement in the course"){
                    course["mark"] = "NA"
                }else if mark.contains("Level") || mark.contains("Click"){
                    let returnValue = CalculateCourseAverage(subjectNumber: counter)
                    if(returnValue == -1.0){
                        course["mark"] = "NA"
                    }else{
                        course["mark"] = returnValue
                    }
                    
                }else if(mark.contains(" 0.0%")){
                    let returnValue = CalculateCourseAverage(subjectNumber: counter)
                    if(returnValue == -1.0){
                        course["mark"] = "NA"
                    }else{
                        course["mark"] = "0"
                    }
                }else if mark.contains("%"){
                    course["mark"] = Double(mark.replacingOccurrences(of:"%", with:"").trimmingCharacters(in: .whitespacesAndNewlines))
                }
                counter += 1
            }
            
            var httpResp = sr.Send(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "session_token": self.sessionToken, "student_id":self.studentID])
            if httpResp != nil{
                var courseNumber = 0
                for i in httpResp!.components(separatedBy: "<td>"){
                    if((i.contains("current mark = ") || i.contains("Please see teacher for current status regarding achievement in the course")||i.contains("Click Here")||i.contains("Level")||i.contains("Block")) && !i.contains("0000-00-00")) {
                        let Course_Name = i.components(separatedBy: ":")[1].components(separatedBy:"<br>")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
                        let Room_Number = i.components(separatedBy: "rm. ")[1].components(separatedBy:"</td>")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        let course = i.components(separatedBy: " :")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        if courseNumber < response.count{
                            response[courseNumber]["Room_Number"] = Room_Number
                            response[courseNumber]["Course_Name"] = Course_Name
                        }else{ //this would only normally get called at the start of the semester since the api takes longer than the website to update new courses.
                            let dict = NSMutableDictionary()
                            dict["Course_Name"] = Course_Name
                            dict["Room_Number"] = Room_Number
                            dict["mark"] = "NA"
                            dict["subject_id"] = "NA"
                            dict["course"] = course
                            response.append(dict)
                            self.courses.append("NA")
                        }
                        courseNumber += 1
                    }
                    
                }
            }
            return response
        }else{
            let htmlResp = GetTaData2(username: username, password: password)
            if(htmlResp != nil){
                return htmlResp
            }
            return nil
        }*/
    }
    
    func GetTaData2(username:String, password:String) -> [NSMutableDictionary]?{ //This is the html parsing method
        //TODO add crashlitics
        self.username = username
        self.password = password
        let sr = SendRequest()
        var response = [NSMutableDictionary]()
        var httpResp = sr.SendWithCookies(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "submit": "Login"], cookies:nil)
        print("HERE")
        print(httpResp)
        if httpResp != nil{
            self.studentID = httpResp![2]! as! String
            self.sessionToken = httpResp![1]! as! String
            var html = httpResp![0]!            
            
            var courseNumber = 0
            for i in html.components(separatedBy: "<td>"){
                if((i.contains("current mark = ") || i.contains("Please see teacher for current status regarding achievement in the course")||i.contains("Click Here")||i.contains("Level")||i.contains("Block")) && !i.contains("0000-00-00")) {
                    let Course_Name = i.components(separatedBy: ":")[1].components(separatedBy:"<br>")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
                    let Room_Number = i.components(separatedBy: "rm. ")[1].components(separatedBy:"</td>")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let courseCode = i.components(separatedBy: " :")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let dict = NSMutableDictionary()
                    dict["Course_Name"] = Course_Name
                    dict["Room_Number"] = Room_Number
                    dict["course"] = courseCode
                    if(i.contains("current mark = ")){
                        let subjectID = i.components(separatedBy: "subject_id=")[1].components(separatedBy:"&")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
                        let mark = i.components(separatedBy: "current mark = ")[1].components(separatedBy:"%</a>")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
                        dict["mark"] = Double(mark)
                        dict["subject_id"] = subjectID as? String
                        courses.append(subjectID)
                    }else if((i.contains("Click Here") || i.contains("Level")) && (i.components(separatedBy: "subject_id=").count > 1)){ //sometimes somewhere else on the website will have a "click here" so we need to make sure that there is actually a subject id here
                        let subjectID = i.components(separatedBy: "subject_id=")[1].components(separatedBy:"&")[0].trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
                        courses.append(subjectID)
                        let marks = GetMarks(subjectNumber: courseNumber)
                        let mark = CalculateCourseAverage(subjectNumber: courseNumber, markParam: marks)
                        dict["mark"] = mark
                        dict["subject_id"] = subjectID
                    }else{
                        dict["mark"] = "NA"
                        dict["subject_id"] = "NA"
                        courses.append("NA")
                    }
                    response.append(dict)
                    
                    courseNumber += 1
                }
                
            }
            
            return response
        }else{
            return nil
        }
    }
    func addCoursesForOfflineMode(response:[NSMutableDictionary]){
        for var course in response{
            if course["subject_id"] != nil{
                self.courses.append(course["subject_id"]! as! String)
            }else{
                self.courses.append("NA")
            }
        }
    }
    
    func CheckCredentials(username:String, password:String)-> Bool{
        //TODO add crashlitics
        let sr = SendRequest()
        let URL = "https://ta.yrdsb.ca/v4/students/json.php"
        //var resp1 = sr.SendJSON(url: URL, parameters: ["student_number":username, "password":password])
        var resp2 = sr.Send(url: "https://ta.yrdsb.ca/live/index.php?", parameters: ["subject_id":"0", "username":username, "password":password, "submit": "Login"])
        
        /*//get main activity data
        if resp1 != nil{ //check if user is registered in the api
            if resp1!["ERROR"] == nil{
                return true
            }
        }*/
        if resp2 != nil{//check if user is registered on the website
            if !resp2!.contains("By logging in"){
                return true
            }
            
        }
        return false
        
    }
    
    func GetMarks(subjectNumber:Int) -> [String:Any]?{
        if(courses[subjectNumber] == "NA"){
            return nil //this is to minimize network requests for the offline mode code block which tries to check every course that isint saved even when it is NA
        }
        let resp2 = GetMarks2(subjectNumber: subjectNumber)
        if(resp2 != nil){
            return resp2
        }
        return nil
        /*
        var sr = SendRequest()
        var params = ["student_id": self.studentID, "token":self.sessionToken, "subject_id":courses[subjectNumber]]
        var respCheck = sr.SendJSON(url: "https://ta.yrdsb.ca/v4/students/json-20180628.php", parameters: params)
        if respCheck == nil{
            print("REQUEST FAILED")
            let resp2 = GetMarks2(subjectNumber: subjectNumber)
            if(resp2 != nil){
                return resp2
            }
            return nil
        }else if respCheck!["ERROR"] != nil{
            print("INVALID TOKEN")
            //GetTaData(username: username, password: password)
        }
        var resp = respCheck! as! [String : Any]
        if var assignments = ((resp["data"] as? [String:Any])?["assessment"] as? [String:Any]){
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
            print("REQUEST FAILED")
            let resp2 = GetMarks2(subjectNumber: subjectNumber)
            if(resp2 != nil){
                return resp2
            }
            return nil
        }*/
    }
    
    func GetMarks2(subjectNumber:Int) -> [String:Any]?{
        var sr = SendRequest()
        var params = ["student_id": self.studentID, "token":self.sessionToken, "subject_id":courses[subjectNumber]]
        //print(sessionToken)
        var cookieProps = [
            HTTPCookiePropertyKey.domain: "ta.yrdsb.ca",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: "session_token",
            HTTPCookiePropertyKey.value: self.sessionToken,
            HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: 3600)//one hour
            ] as [HTTPCookiePropertyKey : Any]
        let cookie = HTTPCookie(properties: cookieProps)
        var respCheck = sr.SendWithCookies(url: "https://ta.yrdsb.ca/live/students/viewReport.php?", parameters: params, cookies:cookie)
        if respCheck == nil{
            return nil
        }else if((respCheck![0]?.contains("By logging in"))!){
            print("INVALID TOKEN")
            GetTaData(username: username, password: password)
            respCheck = sr.SendWithCookies(url: "https://ta.yrdsb.ca/live/students/viewReport.php?", parameters: params, cookies:cookie)
            if(respCheck == nil || (respCheck![0]?.contains("By logging in"))!){
                return nil
            }
        }
        var assignmentNumber = 0
        let html = respCheck![0]!
        var assignments = [String:Any]()
        for i in html.components(separatedBy:"rowspan="){ //each assignment
            var dict = NSMutableDictionary()
            
            if(i.contains("bgcolor=\"white\"")){ //each itteration is one assignment
                let title = i.components(separatedBy: "\"2\">")[1].components(separatedBy: "</td>")[0]
                dict["title"] = title
                dict["feedback"] = ""
                do{
                    let categoryList = ["K", "T", "C", "A", ""]
                    let categoryColourCodes = ["ffffaa", "c0fea4", "afafff", "ffd490", "#dedede"] //corresponding colours for K, T, C, A
                    var categoryNumber = -1
                    for j in i.components(separatedBy: " align=\"center\">"){ //each itteration is one category
                        if(categoryNumber < 0){
                            categoryNumber += 1
                            continue
                        }else if(j.contains("<td colspan=\"4\"")){//feedback
                            if(j.contains("Feedback:")){
                                let feedback = j.components(separatedBy: "Feedback:")[1].components(separatedBy: "</td>")[0]
                                    .htmlUnescape()
                                    .replacingOccurrences(of: "<br>", with: "")
                                    .trimmingCharacters(in: .newlines)
                                dict["feedback"] = feedback
                            }
                        }
                        let regexFloat = "[+-]?([0-9]*[.])?[0-9]+" //this will capture any number not just an int
                        //let regex1 = try NSRegularExpression(pattern: regexFloat+"\\s/\\s"+regexFloat+"\\s.\\s"+regexFloat) //https://www.rexegg.com/regex-quickstart.html
                        let regex1 = try NSRegularExpression(pattern: regexFloat+"\\s/\\s"+regexFloat+"\\s.\\s")
                        let markString1 = regex1.matches(in: j, range:NSRange(location: 0, length: j.count)).map {
                            String(j[Range($0.range, in: j)!])
                        }
                        if(markString1.count != 0){
                            //in almost every case this for loop should not actually change the category number, however its purpose is to skip over categories that are not yet defined ex: an assignment contains K, T, A but is missing C, therefore the A mark will be counted as C
                            if(!j.contains(categoryColourCodes[categoryNumber]+"\" align=")){
                                var colourCodeIndex = 0
                                for colourCode in categoryColourCodes{
                                    if(j.contains(colourCode+"\" align=") && categoryList[categoryNumber] != ""){ // make sure the category we are incrementing is not the 'other' category, partly because it will always be the last one, and partly because I dont have the colour code for it right now.
                                        categoryNumber = colourCodeIndex
                                    }
                                    colourCodeIndex += 1
                                }
                            }
                            dict[categoryList[categoryNumber]] = NSMutableDictionary()
                            var mark = markString1[0].components(separatedBy: " / ")[0]
                            var outOf = markString1[0].components(separatedBy: " / ")[1].components(separatedBy: "=")[0].trimmingCharacters(in: .whitespacesAndNewlines)
    
                            var weight = j.components(separatedBy: "<font size=\"-2\">")[1].components(separatedBy: "</")[0]
                            
                            if(Double(mark) != nil){
                                (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["mark"] = mark
                            }else{
                                (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["mark"] = ""
                            }
                            if(Double(outOf) != nil){
                                (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["outOf"] = outOf
                            }else{
                                (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["outOf"] = ""
                            }
                            if(weight.contains("weight=")){
                                (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["weight"] = weight.components(separatedBy: "weight=")[1]
                            }else if(weight.contains("no weight")){
                                (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["weight"] = "0"
                            }
                            
                        }else if(j.contains("No Mark") || j.contains("No mark") || j.contains("no Mark") || j.contains("no mark")){
                            dict[categoryList[categoryNumber]] = NSMutableDictionary()
                            let emptyString:String? = nil
                            (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["mark"] = emptyString
                            (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["outOf"] = emptyString
                            (dict[categoryList[categoryNumber]]!as! NSMutableDictionary) ["weight"] = emptyString
                        }
                        
                        /*let regex2 = try NSRegularExpression(pattern: "\\s/\\s\\d+\\s.\\s") //https://www.rexegg.com/regex-quickstart.html
                        let markString2 = regex2.matches(in: i, range:NSRange(location: 0, length: i.count)).map {
                            String(i[Range($0.range, in: i)!])
                        }
                        if(markString2.count != 0){
                            
                        }*/
                        assignments[String(assignmentNumber)] = dict
                        categoryNumber += 1
                    }
                    assignmentNumber += 1
                    
                }catch{print("ERROR ERROR ERROR PLEASE CHECK THIS")}
            }
            
            if(html.components(separatedBy:"rowspan=").count == assignmentNumber+1){
                if(i.contains("<td>Knowledge/Understanding</td>")){
                    let k = Double(i.components(separatedBy: "<td>Knowledge/Understanding</td>")[1].components(separatedBy: ">")[1].components(separatedBy: "%<")[0])!/100
                    let t = Double(i.components(separatedBy: "<td>Thinking</td>")[1].components(separatedBy: ">")[1].components(separatedBy: "%<")[0])!/100
                    let c = Double(i.components(separatedBy: "<td>Communication</td>")[1].components(separatedBy: ">")[1].components(separatedBy: "%<")[0])!/100
                    let a = Double(i.components(separatedBy: "<td>Application</td>")[1].components(separatedBy: ">")[1].components(separatedBy: "%<")[0])!/100
                    let categories = ["K":k, "T":t, "C":c, "A":a, "":0.3]
                    assignments["categories"] = categories
                }else{
                    let categories = ["K":0.175, "T":0.175, "C":0.175, "A":0.175, "":0.3]
                    assignments["categories"] = categories
                }
                
            }
            //assignemnts["categories"]
            
            
            
        }
        
        return assignments
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
    
    func CalculateCourseAverage(subjectNumber:Int? = nil, markParam:[String:Any]? = nil, averageCategory:String? = nil) -> Double{
        var marks:[String:Any]?
        var numberOfAssignments = 0
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
       
        if(marks!.count <= 1){//if this methods gets called when the mark feild is actually blank on the teachassist website since its impossible to tell via the api
            return -1.0
        }
        for (key, value) in marks!{
            if key != "categories"{
                numberOfAssignments += 1
                var temp = value as! [String:Any]
                temp["feedback"] = nil
                temp["title"] = nil
                var assignment = temp as! [String:[String:String?]]
                
                
                var markK = 0.0
                var outOfK = 0.0
                var weightK = -0.1
                if assignment["K"] != nil && assignment["K"]!["mark"] != nil && assignment["K"]!["mark"]! != nil && assignment["K"]!["mark"]! != "no mark"{
                    markK = Double(assignment["K"]!["mark"]!!)!
                }else{
                    weightK = 0.0;
                }
                if assignment["K"] != nil && assignment["K"]!["outOf"] != nil && assignment["K"]!["outOf"]! != nil{
                    outOfK = Double(assignment["K"]!["outOf"]!!)!
                }
                if weightK == -0.1{
                    if assignment["K"]!["weight"] != nil && assignment["K"]!["weight"]! != nil{
                        weightK = Double(assignment["K"]!["weight"]!!)!
                    }else{
                        weightK = 0.0
                    }
                }
                if outOfK != 0.0 && weightK != 0.0{
                    knowledge += markK / outOfK * weightK
                    totalWeightKnowledge += weightK
                }
                
                var markT = 0.0
                var outOfT = 0.0
                var weightT = -0.1
                if assignment["T"] != nil && assignment["T"]!["mark"] != nil && assignment["T"]!["mark"]! != nil && assignment["T"]!["mark"]! != "no mark"{
                    markT = Double(assignment["T"]!["mark"]!!)!
                }else{
                    weightT = 0.0;
                }
                if assignment["T"] != nil && assignment["T"]!["outOf"] != nil && assignment["T"]!["outOf"]! != nil{
                    outOfT = Double(assignment["T"]!["outOf"]!!)!
                }
                if weightT == -0.1{
                    if assignment["T"]!["weight"] != nil && assignment["T"]!["weight"]! != nil{
                        weightT = Double(assignment["T"]!["weight"]!!)!
                    }else{
                        weightT = 0.0
                    }
                }
                if outOfT != 0.0 && weightT != 0.0{
                    thinking += markT / outOfT * weightT
                    totalWeightThinking += weightT
                }
                
                var markC = 0.0
                var outOfC = 0.0
                var weightC = -0.1
                if assignment["C"] != nil && assignment["C"]!["mark"] != nil && assignment["C"]!["mark"]! != nil && assignment["C"]!["mark"]! != "no mark"{
                    markC = Double(assignment["C"]!["mark"]!!)!
                }else{
                    weightC = 0.0;
                }
                if assignment["C"] != nil && assignment["C"]!["outOf"] != nil && assignment["C"]!["outOf"]! != nil{
                    outOfC = Double(assignment["C"]!["outOf"]!!)!
                }
                if weightC == -0.1{
                    if assignment["C"]!["weight"] != nil && assignment["C"]!["weight"]! != nil{
                        weightC = Double(assignment["C"]!["weight"]!!)!
                    }else{
                        weightC = 0.0
                    }
                }
                if outOfC != 0.0 && weightC != 0.0{
                    communication += markC / outOfC * weightC
                    totalWeightCommunication += weightC
                }
                
                var markA = 0.0
                var outOfA = 0.0
                var weightA = -0.1
                if assignment["A"] != nil && assignment["A"]!["mark"] != nil && assignment["A"]!["mark"]! != nil && assignment["A"]!["mark"]! != "no mark"{
                    markA = Double(assignment["A"]!["mark"]!!)!
                }else{
                    weightA = 0.0;
                }
                if assignment["A"] != nil && assignment["A"]!["outOf"] != nil && assignment["A"]!["outOf"]! != nil{
                    outOfA = Double(assignment["A"]!["outOf"]!!)!
                }
                if weightA == -0.1{
                    if assignment["A"]!["weight"] != nil && assignment["A"]!["weight"]! != nil{
                        weightA = Double(assignment["A"]!["weight"]!!)!
                    }else{
                        weightA = 0.0
                    }
                }
                if outOfA != 0.0 && weightA != 0.0{
                    application += markA / outOfA * weightA
                    totalWeightApplication += weightA
                }
                
                var markO = 0.0
                var outOfO = 0.0
                var weightO = -0.1
                if assignment[""] != nil && assignment[""]!["mark"] != nil && assignment[""]!["mark"]! != nil && assignment[""]!["mark"]! != "no mark"{
                    markO = Double(assignment[""]!["mark"]!!)!
                }else{
                    weightO = 0.0;
                }
                if assignment[""] != nil && assignment[""]!["outOf"] != nil && assignment[""]!["outOf"]! != nil{
                    outOfO = Double(assignment[""]!["outOf"]!!)!
                }
                if weightO == -0.1{
                    if assignment[""]!["weight"] != nil && assignment[""]!["weight"]! != nil{
                        weightO = Double(assignment[""]!["weight"]!!)!
                    }else{
                        weightO = 0.0
                    }
                }
                if outOfO != 0.0 && weightO != 0.0{
                    other += markO / outOfO * weightO
                    totalWeightOther += weightO
                }
                
            }
        }
        
        if(numberOfAssignments == 1 && averageCategory == nil){
            var assignmentNumber:String = "-1"
            for i in 0...1000{
                if(marks![String(i)] != nil){
                    assignmentNumber = String(i)
                    break
                }
            }
            if(assignmentNumber != "-1"){
                var temp = marks![assignmentNumber] as! [String:Any]
                temp["feedback"] = nil
                temp["title"] = nil
                temp["categories"] = nil
                let assignmentDict = temp as! [String : [String : String]]
                if let returnVal = Double(self.calculateAssignmentAverage(assignment: assignmentDict , courseWeights: weights,
                                                       assignmentWeights: ["K": totalWeightKnowledge, "T":totalWeightThinking,
                                                                           "C":totalWeightCommunication, "A":totalWeightApplication, "":totalWeightOther])){
                    return returnVal
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
        
        if averageCategory == "K"{
            if totalWeightKnowledge != 0.0{
                return finalKnowledge * 100.0
            }else{
                return -1.0
            }
        }
        if averageCategory == "T"{
            if totalWeightThinking != 0.0{
                return finalThinking * 100.0
            }else{
                return -1.0
            }
        }
        if averageCategory == "C"{
            if totalWeightCommunication != 0.0{
                return finalCommunication * 100.0
            }else{
                return -1.0
            }
        }
        if averageCategory == "A"{
            if totalWeightApplication != 0.0{
                return finalApplication * 100.0
            }else{
                return -1.0
            }
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
        //print(marks)
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
                if assignment["K"] != nil && assignment["K"]!["mark"] != nil && assignment["K"]!["mark"]! != nil && assignment["K"]!["mark"]! != "no mark"{
                    markK = Double(assignment["K"]!["mark"]!!)!
                }else{
                    weightK = 0.0;
                }
                if assignment["K"] != nil && assignment["K"]!["outOf"] != nil && assignment["K"]!["outOf"]! != nil{
                    outOfK = Double(assignment["K"]!["outOf"]!!)!
                }
                if weightK == -0.1{
                    if assignment["K"]!["weight"] != nil && assignment["K"]!["weight"]! != nil{
                        weightK = Double(assignment["K"]!["weight"]!!)!
                    }else{
                        weightK = 0.0
                    }
                }
                if outOfK != 0.0 && weightK != 0.0{
                    knowledge += markK / outOfK * weightK;
                    totalWeightKnowledge += weightK;
                }
                
                var markT = 0.0
                var outOfT = 0.0
                var weightT = -0.1
                if assignment["T"] != nil && assignment["T"]!["mark"] != nil && assignment["T"]!["mark"]! != nil && assignment["T"]!["mark"]! != "no mark"{
                    markT = Double(assignment["T"]!["mark"]!!)!
                }else{
                    weightT = 0.0;
                }
                if assignment["T"] != nil && assignment["T"]!["outOf"] != nil && assignment["T"]!["outOf"]! != nil{
                    outOfT = Double(assignment["T"]!["outOf"]!!)!
                }
                if weightT == -0.1{
                    if assignment["T"]!["weight"] != nil && assignment["T"]!["weight"]! != nil{
                        weightT = Double(assignment["T"]!["weight"]!!)!
                    }else{
                        weightT = 0.0
                    }
                }
                if outOfT != 0.0 && weightT != 0.0{
                    thinking += markT / outOfT * weightT;
                    totalWeightThinking += weightT;
                }
                
                var markC = 0.0
                var outOfC = 0.0
                var weightC = -0.1
                if assignment["C"] != nil && assignment["C"]!["mark"] != nil && assignment["C"]!["mark"]! != nil && assignment["C"]!["mark"]! != "no mark"{
                    markC = Double(assignment["C"]!["mark"]!!)!
                }else{
                    weightC = 0.0;
                }
                if assignment["C"] != nil && assignment["C"]!["outOf"] != nil && assignment["C"]!["outOf"]! != nil{
                    outOfC = Double(assignment["C"]!["outOf"]!!)!
                }
                if weightC == -0.1{
                    if assignment["C"]!["weight"] != nil && assignment["C"]!["weight"]! != nil{
                        weightC = Double(assignment["C"]!["weight"]!!)!
                    }else{
                        weightC = 0.0
                    }
                }
                if outOfC != 0.0 && weightC != 0.0{
                    communication += markC / outOfC * weightC;
                    totalWeightCommunication += weightC;
                }
                
                var markA = 0.0
                var outOfA = 0.0
                var weightA = -0.1
                if assignment["A"] != nil && assignment["A"]!["mark"] != nil && assignment["A"]!["mark"]! != nil && assignment["A"]!["mark"]! != "no mark"{
                    markA = Double(assignment["A"]!["mark"]!!)!
                }else{
                    weightA = 0.0;
                }
                if assignment["A"] != nil && assignment["A"]!["outOf"] != nil && assignment["A"]!["outOf"]! != nil{
                    outOfA = Double(assignment["A"]!["outOf"]!!)!
                }
                if weightA == -0.1{
                    if assignment["A"]!["weight"] != nil && assignment["A"]!["weight"]! != nil{
                        weightA = Double(assignment["A"]!["weight"]!!)!
                    }else{
                        weightA = 0.0
                    }
                }
                if outOfA != 0.0 && weightA != 0.0{
                    application += markA / outOfA * weightA;
                    totalWeightApplication += weightA;
                }
                
                var markO = 0.0
                var outOfO = 0.0
                var weightO = -0.1
                if assignment[""] != nil && assignment[""]!["mark"] != nil && assignment[""]!["mark"]! != nil && assignment[""]!["mark"]! != "no mark"{
                    markO = Double(assignment[""]!["mark"]!!)!
                }else{
                    weightO = 0.0;
                }
                if assignment[""] != nil && assignment[""]!["outOf"] != nil && assignment[""]!["outOf"]! != nil{
                    outOfO = Double(assignment[""]!["outOf"]!!)!
                }
                if weightO == -0.1{
                    if assignment[""]!["weight"] != nil && assignment[""]!["weight"]! != nil{
                        weightO = Double(assignment[""]!["weight"]!!)!
                    }else{
                        weightO = 0.0
                    }
                }
                if outOfO != 0.0 && weightO != 0.0{
                    other += markO / outOfO * weightO;
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
            //Knowledge = 0.0;
        }
        if totalWeightThinking != 0.0 {
            finalThinking = thinking/totalWeightThinking;
        }else{
            finalThinking = 0.0;
            //Thinking = 0.0;
        }
        if totalWeightCommunication != 0.0 {
            finalCommunication = communication/totalWeightCommunication;
        }else{
            finalCommunication = 0.0;
            //Communication = 0.0;
        }
        if totalWeightApplication != 0.0 {
            finalApplication = application/totalWeightApplication;
        }else{
            finalApplication = 0.0;
            //Application = 0.0;
        }
        if totalWeightOther != 0.0 {
            finalOther = other/totalWeightOther;
        }else{
            finalOther = 0.0;
            //Other = 0.0;
        }
        //finalKnowledge = finalKnowledge*Knowledge
        //finalThinking = finalThinking*Thinking
        //finalCommunication = finalCommunication*Communication
        //finalApplication = finalApplication*Application
        //finalOther = finalOther*Other
        //round to the tens position
        var returnList = [round(finalKnowledge*1000)/10, round(finalThinking*1000)/10, round(finalCommunication*1000)/10, round(finalApplication*1000)/10, round(finalOther*1000)/10]
        for i in [round(Knowledge*1000)/10, round(Thinking*1000)/10, round(Communication*1000)/10, round(Application*1000)/10, round(Other*1000)/10]{
            returnList.append(i)
        }
        
        return returnList
    
    
    
    
    }
    
    func calculateAssignmentAverage(assignment:[String:[String:String]], courseWeights:[String:Double], assignmentWeights:[String:Double]) -> String{
        var weightList = ["K" : courseWeights["K"]!*10*0.7, "T" : courseWeights["T"]!*10*0.7, "C" : courseWeights["C"]!*10*0.7, "A" : courseWeights["A"]!*10*0.7, "":3.0]
        var markList = ["K" : 0.0, "T" : 0.0, "C" : 0.0, "A" : 0.0, "" : 0.0]
        let categoryList = ["K", "T", "C", "A", ""]
        
        for category in categoryList{
            weightList[category] = (weightList[category]!/10) * assignmentWeights[category]!
        }
        
        
        for category in categoryList{
            if assignment[category] != nil{
                if assignment[category]!["mark"] != nil && assignment[category]!["mark"]! == "no mark" || assignment[category]!["mark"] == "" || assignment[category]!["mark"] == "0.93741"{ //from add assignment
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
        
        if(String(average) == "nan"){
            if(!didRecursivelyCallCalculateAssignmentAverage){
                didRecursivelyCallCalculateAssignmentAverage = true
                return self.calculateAssignmentAverage(assignment: assignment, courseWeights: courseWeights, assignmentWeights: ["K" : 1.0, "T" : 1.0, "C" : 1.0, "A" : 1.0, "" : 1.0])
            }else{
                return "nan"
            }
        }
        if average == 0.0{
            average = 0
        }
        if average == 100.0{
            average = 100
        }
        return String(average)
        
    }
    func getCoursesFromJson(forUsername:String) -> [NSMutableDictionary]?{
        let filemgr = FileManager.default
        let path = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("userCourses.json")
        if let filePath = path?.path {
            do{
                let jsonDataString = try String(contentsOfFile: filePath)
                let jsonData = JSON(parseJSON: jsonDataString)[forUsername]
                if(jsonData.isEmpty){
                    return nil
                }
                var response = [NSMutableDictionary]()
                for (_, i) in jsonData{
                    let dict = NSMutableDictionary()
                    for (key, value) in i{
                        if(key == "mark"){
                            if(value == "NA"){
                                dict[key] = value.stringValue
                            }else{
                                dict[key] = value.doubleValue
                            }
                        }else{
                            dict[key] = value.stringValue
                        }
                    }
                    response.append(dict)
                }
                return response
            }catch{
                return nil
            }
        }
        return nil
    }
    func getCourseFromJson(forUsername:String, courseNumber:Int) -> NSMutableDictionary?{
        if let response = self.getCoursesFromJson(forUsername: username), response.count > courseNumber{
            return response[courseNumber]
        }else{
            return nil
        }
    }
    func saveCoursesToJson(username:String, response:[NSMutableDictionary]?){
        if let oldResponse = getCoursesFromJson(forUsername: username){
            var courseNumber = 0
            for course in response!{
                if((course["mark"] as? String) == "NA" && oldResponse.count > courseNumber){
                    course["mark"] = oldResponse[courseNumber]["mark"]
                }
                courseNumber += 1
            }
        }
        
        let dict = [username:response!]
        let json = JSON(dict)
        let str = json.description
        let data = str.data(using: String.Encoding.utf8)!
        let filemgr = FileManager.default
        let path = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("userCourses.json")
        if !filemgr.fileExists(atPath: (path?.path)!) { //create file if does not exist
            filemgr.createFile(atPath: (path?.path)!, contents: data, attributes: nil)
        }
        if(path?.path != nil){
            if let file = FileHandle(forWritingAtPath:path!.path) {
                file.truncateFile(atOffset: 0)//clear contents of file
                file.write(data)
            }
        }
        
    }
    func saveAssignmentsToJson(username:String, courseNumber:Int, response:[String:Any]?){
        var jsonData:JSON = JSON()
        jsonData[username] = [:] //cant be nil so I used an empty dict instead
        let filemgr = FileManager.default
        let path = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("userAssignments.json")
        do{
            if(path?.path != nil){
                let jsonDataString = try String(contentsOfFile: path!.path)
                if(!JSON(parseJSON: jsonDataString).isEmpty){
                    jsonData[username] = JSON(parseJSON: jsonDataString)[username]
                }
            }else{
                return
            }
        }catch{}
        
        do{
            jsonData[username][String(courseNumber)] = try JSON(JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)) //the course number cant be a integer because then accessing it would look like a list index
        }catch{return}
        let str = jsonData.description
        let data = str.data(using: String.Encoding.utf8)!
        if !filemgr.fileExists(atPath: (path?.path)!) { //create file if does not exist
            filemgr.createFile(atPath: (path?.path)!, contents: data, attributes: nil)
        }
        if let file = FileHandle(forWritingAtPath:path!.path) {
            file.truncateFile(atOffset: 0)//clear contents of file
            file.write(data)
        }
        
    }
    func getAssignmentsFromJson(forUsername:String, forCourse:Int) -> [String:Any]?{
        let filemgr = FileManager.default
        let path = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("userAssignments.json")
        if let filePath = path?.path {
            do{
                let jsonDataString = try String(contentsOfFile: filePath)
                if(jsonDataString.data(using: String.Encoding.utf8) == nil){
                    return nil
                }
                let jsonData = try (JSONSerialization.jsonObject(with: jsonDataString.data(using: String.Encoding.utf8)!, options: []) as? [String:Any])
                if(jsonData == nil || jsonData!.isEmpty){
                    return nil
                }
                let response = jsonData![forUsername] as? [String:Any]
                if(response == nil || response!.isEmpty){
                    return nil
                }
                if((response![String(forCourse)] as? [String:Any]) != nil){
                    return response![String(forCourse)] as? [String:Any]
                }else if(((response! as [String:Any])[String(forCourse)] as? [String:Any]) != nil){
                    return response![String(forCourse)] as? [String:Any]
                }else{
                    return nil
                }
            }catch{
                return nil
            }
        }
        return nil
    }
    func userDidLogout(forUsername:String){
        //clear offline courses
        let filemgr = FileManager.default
        let path = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("userCourses.json")
        if let filePath = path?.path {
            if let file = FileHandle(forWritingAtPath:filePath) {
                file.truncateFile(atOffset: 0)//clear contents of file
            }
        }
        //clear offline assignments
        let path1 = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("userAssignments.json")
        if let filePath = path1?.path {
            if let file = FileHandle(forWritingAtPath:filePath) {
                file.truncateFile(atOffset: 0)//clear contents of file
            }
        }
        print(self.getCoursesFromJson(forUsername: forUsername))
        
    }
}
