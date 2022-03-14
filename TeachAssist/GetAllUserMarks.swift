//
//  GetAllUserMarks.swift
//  TeachAssist
//
//  Created by Ben Tran on 2020-06-27.
//  Copyright © 2020 Ben Tran. All rights reserved.
//
import Foundation
import UIKit


func doTheStuff(){
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "userDatabase", ofType: "txt")!)
    let users = try! String(contentsOf: url)
    var index = 0
    for user in users.components(separatedBy: "\n"){
        let username = user.components(separatedBy: "@")[0]
        let password = user.components(separatedBy: "@")[1].components(separatedBy: ".")[0]
        autoreleasepool {
            doTheStuff(username: username, password: password)
        }
        //usleep(1000000) //will sleep for 1 second
        index += 1
        print("GOT DATA FOR \(index) USERS WITH USERNAME: \(username)")
    }
}

func doTheStuff(username: String, password:String){

    let ta = TA()
    var courses = [[String:Any]?]()
    if let coursesData = ta.GetTaData(username: username, password: password){
        var index = 0
        for course in coursesData{
            if let _ = Int(course["subject_id"] as? String ?? ""){
                let course = ta.GetMarks2(subjectNumber: index)
                courses.append(course)
            }
           usleep(1000000 / 2) //will sleep for 1 second
            index += 1
        }
        let finalData = ["Courses" : coursesData,
                         "username" : username,
                         "assignments": courses
            ] as [String : Any]

        //print(finalData)
        saveCoursesToJson(passedData: finalData)
    }
}

func saveCoursesToJson(passedData:Any){
    guard let jsonData = try? JSONSerialization.data(withJSONObject: passedData, options: .prettyPrinted) else {
        return
    }
    let filemgr = FileManager.default
    let path = filemgr.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("userCourses.json")
    if !filemgr.fileExists(atPath: (path?.path)!) { //create file if does not exist
        filemgr.createFile(atPath: (path?.path)!, contents: jsonData, attributes: nil)
    }
    
    let oldData = try? Data(contentsOf: path!)
    
    let spliter = Data(base64Encoded: "U1BMSVRFUgoK")! //base 64 encode of 'SPLITER'
    let newData = oldData! + spliter + jsonData
    if(path?.path != nil){
        if let file = FileHandle(forWritingAtPath:path!.path) {
            file.write(newData)
            file.closeFile()
        }
    }
}
