//
//  CourseViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-03-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//
import Foundation
import UIKit
import UICircularProgressRing


class CourseViewController: UIViewController {

    @IBOutlet weak var progressRing: UICircularProgressRing!
    override func viewDidLoad() {
        super.viewDidLoad()
        progressRing.font = UIFont.boldSystemFont(ofSize: 25.0)
        progressRing.value = 87.6
        
        progressRing.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
