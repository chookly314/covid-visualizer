//
//  CovidTableViewCell.swift
//  covid-visualizer
//
//  Created by Fernando Cepeda on 06/04/2020.
//  Copyright © 2020 fcs. All rights reserved.
//

import UIKit

class CovidTableViewCell: UITableViewCell {
    
    @IBOutlet var countryNameLabel: UILabel!
    @IBOutlet var countryFlagImageView: UIImageView!

    override required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    static let identifier = "CovidTableViewCell"
    
    static func nib() -> UINib {
        return UINib (nibName: "CovidTableViewCell", bundle: nil)
    }
    
    func configure(with model: CountryCell) {
        self.countryNameLabel.text = model.country
        let imageUrl = model.countryInfo.flag
        if let data = try? Data(contentsOf: URL(string:imageUrl)!) {
                self.countryFlagImageView.image = UIImage(data: data)
        }
    }
    
    
}
