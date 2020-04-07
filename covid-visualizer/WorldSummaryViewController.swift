//
//  WorldSummaryViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 07/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit

class WorldSummaryViewController: UIViewController {

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
    
    // MARK - Class constants
    let worldSummaryUrl: String = "https://corona.lmao.ninja/all"
    let worldSummaryTitleText: String = "World summary statistics"
    let casesTitle: String = "Total cases: "
    let deathsTitle: String = "Total deaths: "
    let recoveredTitle: String = "Total recovered: "
    let activeTitle: String = "Total active: "
    let criticalTitle: String = "Total critical: "
    let testsTitle: String = "Total tests: "
    let countriesTitle: String = "Total countries: "
    let casesGraphTitleText: String = "Cases over time"
    let deathsGraphTitleText: String = "Deaths over time"
    
    // MARK - Clss variables
    var resultDataToDisplay: WorldSummaryDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeStaticLabels()
        retrieveWorldSummary()
    }
    
    func initializeStaticLabels() {
        DispatchQueue.main.async {
            self.worldSummaryTitle.text = self.worldSummaryTitleText
            self.casesGraphTitle.text = self.casesGraphTitleText
            self.deathsGraphTitle.text = self.deathsGraphTitleText
        }
    }
    
    func retrieveWorldSummary() {
        URLSession.shared.dataTask(with: URL(string: worldSummaryUrl)!,
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
                    }
                    
            }).resume()
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

struct WorldSummaryDetails: Codable {
    let cases: Int
    let todayCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let active: Int
    let critical: Int
    let casesPerOneMillion: Double
    let deathsPerOneMillion: Double
    let tests: Int
    let testsPerOneMillion: Double
    let affectedCountries: Int
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

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
