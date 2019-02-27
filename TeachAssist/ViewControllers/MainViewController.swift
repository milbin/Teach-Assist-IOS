//
//  ViewController.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let sr = SendRequest()
        sr.SendJSON(url:"https://ta.yrdsb.ca/v4/students/json.php", parameters: ["student_number":"your username here","password":"add your password here"])
        self.navigationItem.title = "TeachAssist";
    }


}


