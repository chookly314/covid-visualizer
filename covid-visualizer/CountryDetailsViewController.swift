//
//  CountryDetailsViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 07/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var casesGraph: UILabel!
    @IBOutlet weak var casesPerDayGraph: UILabel!
    @IBOutlet weak var deathsPerDayGraph: UILabel!
    @IBOutlet weak var detailsNavigatiomItem: UINavigationItem!
    
    // MARK - Class varialbes
    //var selectedCountryName : String?
    
    // MARK - Class constants
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
    let casesGraphTitleText: String = "Cases over time"
    let casesPerDayGraphTitleText: String = "Cases per day"
    let deathsGraphTitleText: String = "Deaths over time"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeStaticLabels()
        retrieveCountryDetails()
    }
    
    func initializeStaticLabels() {
        DispatchQueue.main.async {
            self.casesGraph.text = self.casesGraphTitleText
            self.casesPerDayGraph.text = self.casesPerDayGraphTitleText
            self.deathsPerDayGraph.text = self.deathsGraphTitleText
        }
    }
    
    func retrieveCountryDetails() {
        
        let escapedCountry : String = selectedCountryName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let urlToQuery : String = "\(self.countryDetailsUrl)\(escapedCountry)"
        
        URLSession.shared.dataTask(with: URL(string: urlToQuery)!,
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
                        
                    }
                    
            }).resume()
    }

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
