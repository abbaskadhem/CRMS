//
//  FAQManagementTableViewCell.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class FAQManagementTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!

      func configure(with item: FAQ) {
          questionLabel.text = item.question
          answerLabel.text = item.answer
      }
}
