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
    
    static let cache = NSCache<NSString, UIImage>()
    
    static func nib() -> UINib {
        return UINib (nibName: "CovidTableViewCell", bundle: nil)
    }
    
    func configure(with model: CountryCell) {
        self.countryNameLabel.text = model.country
        let imageUrl = model.countryInfo.flag
        
        if let cachedImage = CovidTableViewCell.cache.object(forKey: imageUrl as NSString){
            self.countryFlagImageView.image = cachedImage as? UIImage
        } else {
            
            
            URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: { [weak self] (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    let cacheItem = UIImage(data: data!)
                    CovidTableViewCell.cache.setObject(cacheItem!, forKey: imageUrl as NSString)
                    self!.countryFlagImageView.image = cacheItem
                }
            }
            
            }).resume()

        }
        
    }
    
    
}
