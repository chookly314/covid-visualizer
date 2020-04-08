//
//  CountryDetailsViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 07/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit
import Charts

class CountryDetailsViewController: UIViewController {

    // MARK - Outlets
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var cases: UILabel!
    @IBOutlet weak var todayCases: UILabel!
    @IBOutlet weak var deaths: UILabel!
    @IBOutlet weak var todayDeaths: UILabel!
    @IBOutlet weak var recovered: UILabel!
    @IBOutlet weak var active: UILabel!
    @IBOutlet weak var critical: UILabel!
    @IBOutlet weak var casesPerOneMillion: UILabel!
    @IBOutlet weak var deathsPerOneMillion: UILabel!
    @IBOutlet weak var tests: UILabel!
    @IBOutlet weak var testsPerOneMillion: UILabel!
    @IBOutlet weak var casesPerDayGraph: UILabel!
    @IBOutlet weak var deathsPerDayGraph: UILabel!
    @IBOutlet weak var detailsNavigatiomItem: UINavigationItem!
    @IBOutlet weak var newCasesGraph: BarChartView!
    @IBOutlet weak var newDeathsGraph: BarChartView!
    

    // MARK - Class constants
    // URLs
    let apiProtocol: String = "https"
    let apiDomainName: String = "corona.lmao.ninja"
    let apiCountryDetailsPath: String = "/countries"
    let apiCountryTimeseriesPath: String = "/v2/historical/"
    // Titles
    let countryDetailsUrl : String = "https://corona.lmao.ninja/countries/"
    let casesTitle: String = "Total cases: "
    let todayCasesTitle: String = "Total cases today: "
    let deathsTitle: String = "Total deaths: "
    let todayDeathsTitle: String = "Total deaths today: "
    let recoveredTitle: String = "Total recovered: "
    let activeTitle: String = "Total active: "
    let criticalTitle: String = "Total critical: "
    let casesPerOneMillionTitle: String = "Cases per one million: "
    let deathsPerOneMillionTitle: String = "Deaths per one million: "
    let testsTitle: String = "Total tests: "
    let testsPerOneMillionTitle: String = "Tests per one million: "
    let casesPerDayGraphTitleText: String = "Cases per day"
    let deathsPerDayGraphTitleText: String = "Deaths per day"

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

        initializeStaticLabels()
        retrieveCountryDetails()
        updateGraphs()
    }
    
    func initializeStaticLabels() {
        DispatchQueue.main.async {
            self.casesPerDayGraph.text = self.casesPerDayGraphTitleText
            self.deathsPerDayGraph.text = self.deathsPerDayGraphTitleText
        }
    }
    
    func retrieveCountryDetails() {
        
        let escapedCountry : String = selectedCountryName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = "\(self.apiCountryDetailsPath)/\(escapedCountry)"
        URLSession.shared.dataTask(with: URL(string: urlComponents.url!.absoluteString)!,
                completionHandler: { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    var result: CountryDetails?
                    do {
                        result = try JSONDecoder().decode(CountryDetails.self, from: data)
                    } catch {
                        print(error)
                    }
                    
                    guard let finalResult = result else {
                        return
                    }
                    
                    let newCountries = finalResult
                    let imageUrl = finalResult.countryInfo.flag

                    DispatchQueue.main.async {
                        // Update labels content
                        self.cases.text = "\(self.casesTitle) \(finalResult.cases.formattedWithSeparator)"
                        self.todayCases.text = "\(self.todayCasesTitle) \(finalResult.todayCases.formattedWithSeparator)"
                        self.deaths.text = "\(self.deathsTitle) \(finalResult.deaths.formattedWithSeparator)"
                        self.todayDeaths.text = "\(self.todayDeathsTitle) \(finalResult.todayDeaths.formattedWithSeparator)"
                        self.recovered.text = "\(self.recoveredTitle) \(finalResult.recovered.formattedWithSeparator)"
                        self.active.text = "\(self.activeTitle) \(finalResult.active.formattedWithSeparator)"
                        self.critical.text = "\(self.criticalTitle) \(finalResult.critical.formattedWithSeparator)"
                        self.casesPerOneMillion.text = "\(self.casesPerOneMillionTitle) \(finalResult.casesPerOneMillion.formattedWithSeparator)"
                        self.deathsPerOneMillion.text = "\(self.deathsPerOneMillionTitle) \(finalResult.deathsPerOneMillion.formattedWithSeparator)"
                        self.tests.text = "\(self.testsTitle) \(finalResult.tests.formattedWithSeparator)"
                        self.testsPerOneMillion.text = "\(self.testsPerOneMillionTitle) \(finalResult.testsPerOneMillion.formattedWithSeparator)"
                        self.detailsNavigatiomItem.title = selectedCountryName!
                        if let imageData = try? Data(contentsOf: URL(string:imageUrl)!) {
                                self.flag.image = UIImage(data: imageData)
                        }
                        self.todayCases.text = "\(finalResult.todayCases.formattedWithSeparator)"
                        self.todayDeaths.text = "\(finalResult.todayDeaths.formattedWithSeparator)"
                    }
                    
            }).resume()
    }
    
    func updateGraphs() {

        let escapedCountry : String = selectedCountryName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = "\(self.apiCountryTimeseriesPath)\(escapedCountry)"
        urlComponents.queryItems = [
           URLQueryItem(name: "lastdays", value: "40"),
        ]
        
        URLSession.shared.dataTask(with: URL(string: urlComponents.url!.absoluteString)!,
                completionHandler: { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    var result: CountryTimeSeries?
                    do {
                        result = try JSONDecoder().decode(CountryTimeSeries.self, from: data)
                    } catch {
                        print(error)
                    }
                    
                    guard let finalResult = result else {
                        return
                    }

                    // This assumes that the first day of both cases and deaths is the same
                    self.timestampArray = Array(finalResult.timeline.cases.keys)
                    self.timestampArray.sort()
                    for i in 0..<self.timestampArray.count {
                        self.timestampArray[i] = String(self.timestampArray[i].dropLast(3))
                    }
                    
                    var numberOfCasesArray : [Double] = Array(finalResult.timeline.cases.values).compactMap(Double.init)
                    numberOfCasesArray.sort()
                    var dailyIncrementOnNumberOfCases = [Double](repeatElement(0.0, count: numberOfCasesArray.count))
                    for i in 0..<numberOfCasesArray.count {
                        if i == 0 {
                            dailyIncrementOnNumberOfCases[i] = numberOfCasesArray[i]
                        } else {
                            dailyIncrementOnNumberOfCases[i] = numberOfCasesArray[i] - numberOfCasesArray[i-1]
                        }
                        
                    }
                    var numberOfDeathsArray : [Double] = Array(finalResult.timeline.deaths.values).compactMap(Double.init)
                    numberOfDeathsArray.sort()
                    var dailyIncrementOnNumberOfDeaths = [Double](repeatElement(0.0, count: numberOfCasesArray.count))
                    for i in 0..<numberOfCasesArray.count {
                        if i == 0 {
                            dailyIncrementOnNumberOfDeaths[i] = numberOfDeathsArray[i]
                        } else {
                            dailyIncrementOnNumberOfDeaths[i] = numberOfDeathsArray[i] - numberOfDeathsArray[i-1]
                        }
                        
                    }

                    // Update graphs
                    DispatchQueue.main.async {
                        self.setChart(self.timestampArray, values: dailyIncrementOnNumberOfCases, graph: graphTypes.cases)
                        self.setChart(self.timestampArray, values: dailyIncrementOnNumberOfDeaths, graph: graphTypes.deaths)
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
            self.newCasesGraph.data = chartData
            self.newCasesGraph.legend.enabled = false
            let xAxisValue = self.newCasesGraph.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate
        } else {
            self.newDeathsGraph.data = chartData
            self.newDeathsGraph.legend.enabled = false
            let xAxisValue = self.newDeathsGraph.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate

        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Entry X: \(entry.x)")
        print("Entry Y: \(entry.y)")
        print("Highlight X: \(highlight.x)")
        print("Highlight Y: \(highlight.y)")
        print("DataIndex: \(highlight.dataIndex)")
        print("DataSetIndex: \(highlight.dataSetIndex)")
        print("StackIndex: \(highlight.stackIndex)\n\n")
    }

}

struct CountryTimeSeries: Codable {
    let timeline : WorldTimeseriesData
}

struct CountryDetails: Codable {
    let countryInfo: CountryInfo
    let cases: Int
    let todayCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let active: Int
    let critical: Int
    let casesPerOneMillion: Int
    let deathsPerOneMillion: Int
    let tests: Int
    let testsPerOneMillion: Int
}
