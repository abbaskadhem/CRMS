//
//  TechAvgTimeCollectionViewCell.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit

class ServicerAvgTimeCollectionViewCell: UICollectionViewCell {
  
    //IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //rounding cell corners
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.masksToBounds = true

        //changing cell border color
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(red: 122, green: 167, blue: 188, alpha: 1.0).cgColor
        
        
    }
    
}
