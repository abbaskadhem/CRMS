//
//  ReqCategory.swift
//  Inventory
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation
import UIKit

struct ItemCategoryModel: Codable, Identifiable {
    var id: UUID
    var name: String
    var isParent: Bool
    var parentCategoryRef: UUID?
    var createdOn: Date
    var createdBy: UUID
    var modifiedOn: Date?
    var modifiedBy: UUID?
    var inactive: Bool
    
    // UI state
    var isExpanded: Bool = true
}

class CategoryCell: UITableViewCell {

    static let reuseID = "CategoryCell"

    

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
