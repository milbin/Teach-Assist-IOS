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
    @IBOutlet weak var knowledgeChart: LineChartView!
    @IBOutlet weak var thinkingChart: LineChartView!
    @IBOutlet weak var communicationChart: LineChartView!
    @IBOutlet weak var applicationChart: LineChartView!
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
        
        
        let response = (parent as! CourseInfoPageViewController).response
        if response != nil{
            if let dataEntries = generateChartData(response: response){
                setupChartTheme(chart: courseAverageChart, dataEntries: dataEntries, isCourseAverageChart: true)
            }
            
            let categoryList = ["K", "T", "C", "A"]
            var categoryIndex = 0
            for chart in [knowledgeChart, thinkingChart, communicationChart, applicationChart]{
                let category = categoryList[categoryIndex]
                if let categoryDataEntries = generateChartData(forCategory: category, response: response){
                    setupChartTheme(chart: chart!, dataEntries: categoryDataEntries, isCourseAverageChart: false)
                }
                categoryIndex += 1
            }
        }
    }
    
    func generateChartData(forCategory:String? = nil, response:[String:Any]?) -> [ChartDataEntry]?{
        var assignmentsSoFar = [String:Any]()
        assignmentsSoFar["categories"] = response!["categories"]
        var dataEntries: [ChartDataEntry] = []
        let ta = TA()
        for i in 0...response!.count-2 {
            assignmentsSoFar[String(i)] = response![String(i)]
            let averageSoFar = ta.CalculateCourseAverage(markParam: assignmentsSoFar, averageCategory: forCategory)/100.0
            if averageSoFar*100.0 != -1.0{
                print(averageSoFar)
                let dataEntry = ChartDataEntry(x: Double(i+1), y: averageSoFar)
                dataEntries.append(dataEntry)
            }
        }
        if dataEntries.count != 0{
            return dataEntries
        }else{
            return nil
        }
    }
    func setupChartTheme(chart: LineChartView, dataEntries: [ChartDataEntry], isCourseAverageChart:Bool){
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
        
        //check if chart is the course average chart and format colorurs accordinly
        if !isCourseAverageChart{
            lineChartDataSet.circleColors = [lightThemeGreen]
            lineChartDataSet.setColor(lightThemeGreen)
        }
        
        //format xAxis to show percent
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.locale = Locale.current
        let percentFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        lineChartDataSet.valueFormatter = percentFormatter
    
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        chart.data = lineChartData
        
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawLabelsEnabled = false
        chart.getAxis(YAxis.AxisDependency.right).enabled = false
        //chart.getAxis(YAxis.AxisDependency.left).axisMinimum = 0.0
        chart.getAxis(YAxis.AxisDependency.left).valueFormatter = DefaultAxisValueFormatter.init(formatter: numberFormatter)
        chart.getAxis(YAxis.AxisDependency.left).labelTextColor = lightThemeBlack
        chart.getAxis(YAxis.AxisDependency.left).labelFont = UIFont(name: "Gilroy-Regular", size: 10)!
        
        chart.legend.enabled = false
        chart.animate(xAxisDuration: 2, easingOption: .easeInCubic)
        
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

