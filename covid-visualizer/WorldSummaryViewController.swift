//
//  WorldSummaryViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 07/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit
import Charts

class WorldSummaryViewController: UIViewController, ChartViewDelegate {

    //MARK - Outlets
    @IBOutlet weak var worldSummaryTitle: UILabel!
    @IBOutlet weak var cases: UILabel!
    @IBOutlet weak var deaths: UILabel!
    @IBOutlet weak var recovered: UILabel!
    @IBOutlet weak var active: UILabel!
    @IBOutlet weak var critical: UILabel!
    @IBOutlet weak var tests: UILabel!
    @IBOutlet weak var countries: UILabel!
    @IBOutlet weak var casesGraphTitle: UILabel!
    @IBOutlet weak var deathsGraphTitle: UILabel!
    @IBOutlet weak var casesGraph: BarChartView!
    @IBOutlet weak var deathsGraph: BarChartView!
    @IBOutlet weak var casesIncrement: UILabel!
    @IBOutlet weak var deathsIncrement: UILabel!

    
    // MARK - Class constants
    // URLs
    let apiProtocol: String = "https"
    let apiDomainName: String = "corona.lmao.ninja"
    let apiWorldSummaryPath: String = "/v3/covid-19/all"
    let apiWorldTimeseriesStatsPath: String = "/v3/covid-19/historical/all"
    // Titles
    let worldSummaryTitleText: String = "World summary statistics"
    let casesTitle: String = "Total cases: "
    let deathsTitle: String = "Total deaths: "
    let recoveredTitle: String = "Total recovered: "
    let activeTitle: String = "Total active: "
    let criticalTitle: String = "Total critical: "
    let testsTitle: String = "Total tests: "
    let countriesTitle: String = "Total countries: "
    let casesGraphTitleText: String = "Cases over time (millions)"
    let deathsGraphTitleText: String = "Deaths over time"
    
    // MARK - Class variables
    var resultDataToDisplay: WorldSummaryDetails?
    weak var axisFormatDelegate: IAxisValueFormatter?
    var timestampArray: [String] = []
    
    // MARK - Class enums
    enum graphTypes {
        case cases
        case deaths
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self
        
        // MARK: General
        casesGraph.delegate                  = self
        casesGraph.pinchZoomEnabled          = false
        casesGraph.drawBarShadowEnabled      = false
        casesGraph.doubleTapToZoomEnabled    = false
        casesGraph.fitBars                   = true
        
        deathsGraph.delegate                  = self
        deathsGraph.pinchZoomEnabled          = false
        deathsGraph.drawBarShadowEnabled      = false
        deathsGraph.doubleTapToZoomEnabled    = false
        deathsGraph.fitBars                   = true
        
        // MARK: Functions
        initializeStaticLabels()
        retrieveWorldSummary()
        updateGraphs()
    }
    
    func initializeStaticLabels() {
        DispatchQueue.main.async {
            self.worldSummaryTitle.text = self.worldSummaryTitleText
            self.casesGraphTitle.text = self.casesGraphTitleText
            self.deathsGraphTitle.text = self.deathsGraphTitleText
        }
    }
    
    func retrieveWorldSummary() {
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = self.apiWorldSummaryPath
        
        URLSession.shared.dataTask(with: URL(string: urlComponents.url!.absoluteString)!,
                completionHandler: { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    var result: WorldSummaryDetails?
                    do {
                        result = try JSONDecoder().decode(WorldSummaryDetails.self, from: data)
                    } catch {
                        print(error)
                    }
                    
                    guard let finalResult = result else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // Update labels content
                        self.cases.text = "\(self.casesTitle) \(finalResult.cases.formattedWithSeparator)"
                        self.deaths.text = "\(self.deathsTitle) \(finalResult.deaths.formattedWithSeparator)"
                        self.recovered.text = "\(self.recoveredTitle) \(finalResult.recovered.formattedWithSeparator)"
                        self.active.text = "\(self.activeTitle) \(finalResult.active.formattedWithSeparator)"
                        self.critical.text = "\(self.criticalTitle) \(finalResult.critical.formattedWithSeparator)"
                        self.tests.text = "\(self.testsTitle) \(finalResult.tests.formattedWithSeparator)"
                        self.countries.text = "\(self.countriesTitle) \(finalResult.affectedCountries.formattedWithSeparator)"
                        self.casesIncrement.text = "\(finalResult.todayCases.formattedWithSeparator)"
                        self.deathsIncrement.text = "\(finalResult.todayDeaths.formattedWithSeparator)"
                    }
                    
            }).resume()
    }
    
    func updateGraphs() {
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = self.apiWorldTimeseriesStatsPath
        urlComponents.queryItems = [
           URLQueryItem(name: "lastdays", value: "90"),
        ]
        
        URLSession.shared.dataTask(with: URL(string: urlComponents.url!.absoluteString)!,
                completionHandler: { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    var result: WorldTimeseriesData?
                    do {
                        result = try JSONDecoder().decode(WorldTimeseriesData.self, from: data)
                    } catch {
                        print(error)
                    }
                    
                    guard let finalResult = result else {
                        return
                    }

                    // This assumes that the first day of both cases and deaths is the same
                    self.timestampArray = Array(finalResult.cases.keys)
                    self.timestampArray.sort()
                    for i in 0..<self.timestampArray.count {
                        self.timestampArray[i] = String(self.timestampArray[i].dropLast(3))
                    }
                    
                    var numberOfCasesArray : [Double] = Array(finalResult.cases.values).compactMap(Double.init)
                    for (index, item) in numberOfCasesArray.enumerated() {
                        numberOfCasesArray[index] = item/1000000
                    }
                    numberOfCasesArray.sort()
                    var numberOfDeathsArray : [Double] = Array(finalResult.deaths.values).compactMap(Double.init)
                    numberOfDeathsArray.sort()
                    
                    // Update graphs
                    DispatchQueue.main.async {
                        self.setChart(self.timestampArray, values: numberOfCasesArray, graph: graphTypes.cases)
                        self.setChart(self.timestampArray, values: numberOfDeathsArray, graph: graphTypes.deaths)
                    }
                    
            }).resume()
                
    }

    // MARK - Graph functions
    func setChart(_ dataPoints: [String], values: [Double], graph: graphTypes) {
        var dataEntries: [BarChartDataEntry] = []
                
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]], data: dataPoints as AnyObject?)
            dataEntries.append(dataEntry)
        }
                
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Cases")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.setDrawValues(false)
        if graph == .cases {
            self.casesGraph.data = chartData
            self.casesGraph.legend.enabled = false
            let xAxisValue = self.casesGraph.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate
        } else {
            self.deathsGraph.data = chartData
            self.deathsGraph.legend.enabled = false
            let xAxisValue = self.deathsGraph.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate

        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Entry X: \(entry.x)")
        print("Entry Y: \(entry.y)")
        print("Highlight X: \(highlight.x)")
        print("Highlight Y: \(highlight.y)")
    }
    
}

struct WorldSummaryDetails: Codable {
    let cases: Double
    let todayCases: Double
    let deaths: Double
    let todayDeaths: Double
    let recovered: Double
    let active: Double
    let critical: Double
    let casesPerOneMillion: Double
    let deathsPerOneMillion: Double
    let tests: Double
    let testsPerOneMillion: Double
    let affectedCountries: Double
}

struct WorldTimeseriesData: Codable {
    let cases : [String : Int]
    let deaths: [String : Int]
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        return numberFormatter
    }()
}

extension Double {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension WorldSummaryViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return timestampArray[Int(value)]
    }
}
