//
//  ViewController.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 06/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit

var selectedCountryName : String?

class CountriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var table: UITableView!
    
    let countriesURL: String = "https://corona.lmao.ninja/v3/covid-19/countries"
    
    var countries = [CountryCell]()
    
    @IBOutlet weak var searchCountry: UISearchBar!
    
    var dataFilter = [CountryCell]()
    var searchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(CovidTableViewCell.nib(), forCellReuseIdentifier: CovidTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        searchCountry.delegate = self
        
        retrieveCountriesList()

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchActive = true;
        self.dataFilter = countries
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchActive = false;
        self.searchCountry.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false;
        self.searchCountry.endEditing(true)
        self.dataFilter.removeAll(keepingCapacity: true)
        self.searchCountry.text = nil
        self.table.reloadData()
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false;
        self.searchCountry.endEditing(true)
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
        return !self.searchActive ? self.countries.count : self.dataFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CovidTableViewCell.identifier, for: indexPath) as! CovidTableViewCell
        if !self.searchActive {
            cell.configure(with: self.countries[indexPath.row])
        } else {
            cell.configure(with: self.dataFilter[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if searchActive {
            selectedCountryName = self.dataFilter[indexPath.row].country
        } else {
            selectedCountryName = self.countries[indexPath.row].country
        }
        performSegue(withIdentifier: "showCountryDetails", sender: self)
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dataFilter.removeAll(keepingCapacity: true)
        if !searchText.isEmpty {
            for item in self.countries {
                if item.country.lowercased().starts(with: searchText.lowercased()) {
                    self.dataFilter.append(item)
                    self.searchActive = true
                }
            }
        } else {
            self.dataFilter.removeAll(keepingCapacity: true)
            self.searchActive = false
        }
        self.table.reloadData()
    }
    
}

struct CountryCell: Codable {
    let country: String
    let countryInfo: CountryInfo
}

struct CountryInfo: Codable {
    let flag: String
}
