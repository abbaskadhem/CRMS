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
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        
        //changing cell border color
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = AppColors.primary.cgColor
        
        /*
         GColor is a Core Graphics representation of a color.
         It's a lower-level structure that doesn't have the same flexibility as UIColor
         The borderColor property of a CALayer expects a CGColor, not a UIColor. thats why we convert it
         */
        
    }
    
}
