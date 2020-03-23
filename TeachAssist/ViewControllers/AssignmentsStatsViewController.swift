//
//  AssignmentsStatsViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-03-20.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import Foundation
import UIKit
import Charts

class AssignmentsStatsViewController: UIViewController{
    
    @IBOutlet weak var courseAverageChart: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var dataEntries: [ChartDataEntry] = []
        for i in 1...20 {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(i))
            dataEntries.append(dataEntry)
        }
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: nil)
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        courseAverageChart.data = lineChartData
    }
}

