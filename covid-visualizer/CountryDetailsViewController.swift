//
//  CountryDetailsViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 07/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit
import Charts

class CountryDetailsViewController: UIViewController, ChartViewDelegate {

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
    let apiCountryDetailsPath: String = "/v3/covid-19/countries"
    let apiCountryTimeseriesPath: String = "/v3/covid-19/historical/"
    // Titles
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
    var daysToQueryForInGraphs = "30"

    // MARK - Class enums
    enum graphTypes {
        case cases
        case deaths
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        axisFormatDelegate = self
        
        initializeStaticLabels()
        retrieveCountryDetails()
        calculateNumberOfDatesToQueryForTimeseries()
    }
    
    func initializeStaticLabels() {
        DispatchQueue.main.async {
            self.casesPerDayGraph.text = self.casesPerDayGraphTitleText
            self.deathsPerDayGraph.text = self.deathsPerDayGraphTitleText
        }
    }
    
    func retrieveCountryDetails() {
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = "\(self.apiCountryDetailsPath)/\(selectedCountryName!)"
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
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = "\(self.apiCountryTimeseriesPath)\(selectedCountryName!)"
        urlComponents.queryItems = [
            URLQueryItem(name: "lastdays", value: self.daysToQueryForInGraphs),
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

        if graph == .cases {
            chartDataSet.setColor(.blue)
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.setDrawValues(false)
            self.newCasesGraph.data = chartData
            self.newCasesGraph.legend.enabled = false
            let xAxisValue = self.newCasesGraph.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate
            xAxisValue.labelPosition = .bottom
        } else {
            chartDataSet.setColor(.red)
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.setDrawValues(false)
            self.newDeathsGraph.data = chartData
            self.newDeathsGraph.legend.enabled = false
            let xAxisValue = self.newDeathsGraph.xAxis
            xAxisValue.valueFormatter = axisFormatDelegate
            xAxisValue.labelPosition = .bottom
        }
        
        setMarkersForCharts()
        
    }
    
    func setMarkersForCharts() {
        let markerCases = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: self.newCasesGraph.xAxis.valueFormatter!)
        markerCases.chartView = self.newCasesGraph
        markerCases.minimumSize = CGSize(width: 80, height: 40)
        self.newCasesGraph.marker = markerCases
        
        let markerDeaths = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: self.newDeathsGraph.xAxis.valueFormatter!)
        markerDeaths.chartView = self.newDeathsGraph
        markerDeaths.minimumSize = CGSize(width: 80, height: 40)
        self.newDeathsGraph.marker = markerDeaths
    }
    
    func calculateNumberOfDatesToQueryForTimeseries() {
        let maxAge : Int = 1000
        
        // Create the URL to query
        var urlComponents = URLComponents()
        urlComponents.scheme = self.apiProtocol
        urlComponents.host = self.apiDomainName
        urlComponents.path = "\(self.apiCountryTimeseriesPath)\(selectedCountryName!)"
        urlComponents.queryItems = [
           URLQueryItem(name: "lastdays", value: String(maxAge)),
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

                    var numberOfCasesArray : [Double] = Array(finalResult.timeline.cases.values).compactMap(Double.init)
                    numberOfCasesArray.sort()
                    
                    var daysNumber : String = ""
                    
                    for i in 0..<numberOfCasesArray.count {
                        if numberOfCasesArray[i] != 0 {
                            daysNumber = String(numberOfCasesArray.count - i)
                            break
                        }
                    }

                    self.daysToQueryForInGraphs = daysNumber
                    self.updateGraphs()
            }).resume()
    }

}

struct CountryTimeSeries: Codable {
    let timeline : WorldTimeseriesData
}

struct CountryDetails: Codable {
    let countryInfo: CountryInfo
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
}

extension CountryDetailsViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return timestampArray[Int(value)]
    }
}
