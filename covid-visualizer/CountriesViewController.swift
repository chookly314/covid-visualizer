//
//  ViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 06/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit

class CountriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView!
    
    let countriesURL: String = "https://corona.lmao.ninja/countries"
    
    var countries = [CountryCell]()
    
    var selectedCountryName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(CovidTableViewCell.nib(), forCellReuseIdentifier: CovidTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
        retrieveCountriesList()
    }
    
    func retrieveCountriesList() {
        self.countries.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: countriesURL)!,
                completionHandler: { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    var result: [CountryCell]?
                    do {
                        result = try JSONDecoder().decode([CountryCell].self, from: data)
                    } catch {
                        print(error)
                    }
                    
                    guard let finalResult = result else {
                        return
                    }
                    
                    let newCountries = finalResult
                    self.countries.append(contentsOf: newCountries)
                    
                    DispatchQueue.main.async {
                        self.table.reloadData()
                    }
            }).resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CovidTableViewCell.identifier, for: indexPath) as! CovidTableViewCell
        cell.configure(with: countries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedCountryName = countries[indexPath.row].country
        performSegue(withIdentifier: "showCountryDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CountryDetailsViewController
        {
            let vc = segue.destination as? CountryDetailsViewController
            vc?.selectedCountryName = self.selectedCountryName!
        }
    }
    
}

struct CountryCell: Codable {
    let country: String
    let countryInfo: CountryInfo
}

struct CountryInfo: Codable {
    let flag: String
}
