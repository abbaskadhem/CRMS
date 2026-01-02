//
//  InventoryCategoryCell.swift
//  CRMS
//
//  Created by Reem Janahi on 02/01/2026.
//

import Foundation
import UIKit


class InventoryCategoryCell: UITableViewCell {

    static let reuseID = "InventoryCategoryCell"


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.directionalLayoutMargins =
            NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)


        contentView.directionalLayoutMargins =
            NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        textLabel?.numberOfLines = 0
        textLabel?.preservesSuperviewLayoutMargins = true

    }
}
