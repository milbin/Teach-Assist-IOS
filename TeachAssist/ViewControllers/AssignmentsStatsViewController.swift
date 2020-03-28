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
    
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeGreen = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemeBlue = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)
    
    @IBOutlet weak var courseAverageChart: LineChartView!
    @IBOutlet var backgroundView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.parent?.parent as? PageViewControllerContainer)!.lightThemeEnabled {
            lightThemeEnabled = true
            lightThemeLightBlack = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
            lightThemeWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            lightThemeBlack = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            lightThemeGreen = UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1.0)
            lightThemeBlue = UIColor(red: 114/255, green: 159/255, blue: 255/255, alpha: 1.0)
        }
        backgroundView.backgroundColor = lightThemeWhite
        
        
        var response = (parent as! CourseInfoPageViewController).response
        var assignmentsSoFar = [String:Any]()
        assignmentsSoFar["categories"] = response!["categories"]
        var dataEntries: [ChartDataEntry] = []
        let ta = TA()
        for i in 0...response!.count-2 {
            assignmentsSoFar[String(i)] = response![String(i)]
            let averageSoFar = ta.CalculateCourseAverage(markParam: assignmentsSoFar)/100.0
            let dataEntry = ChartDataEntry(x: Double(i+1), y: averageSoFar)
            dataEntries.append(dataEntry)
        }
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: nil)
        lineChartDataSet.circleColors = [lightThemeBlue]
        lineChartDataSet.circleHoleColor = lightThemeWhite
        lineChartDataSet.circleRadius = 4
        lineChartDataSet.circleHoleRadius = 2.5
        
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.setColor(lightThemeBlue)
        lineChartDataSet.mode = .cubicBezier
        //lineChartDataSet.valueTextColor = lightThemeBlack
        //lineChartDataSet.valueFont = UIFont(name: "Gilroy-Regular", size: 6)!
        //dont draw the percent values of each of the assignments above each assignment
        lineChartDataSet.drawValuesEnabled = false
        
        //format xAxis to show percent
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.locale = Locale.current
        let percentFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        lineChartDataSet.valueFormatter = percentFormatter
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        courseAverageChart.data = lineChartData
        
        courseAverageChart.xAxis.drawGridLinesEnabled = false
        courseAverageChart.xAxis.drawLabelsEnabled = false
        courseAverageChart.getAxis(YAxis.AxisDependency.right).enabled = false
        //courseAverageChart.getAxis(YAxis.AxisDependency.left).axisMinimum = 0.0
        courseAverageChart.getAxis(YAxis.AxisDependency.left).valueFormatter = DefaultAxisValueFormatter.init(formatter: numberFormatter)
        courseAverageChart.getAxis(YAxis.AxisDependency.left).labelTextColor = lightThemeBlack
        courseAverageChart.getAxis(YAxis.AxisDependency.left).labelFont = UIFont(name: "Gilroy-Regular", size: 10)!
        
        courseAverageChart.legend.enabled = false
        courseAverageChart.animate(xAxisDuration: 2, easingOption: .easeInCubic)
        
    }
}

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?
    
    convenience init(numberFormatter: NumberFormatter) {
        self.init()
        self.numberFormatter = numberFormatter
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        return numberFormatter.string(for: value)!
    }
}

