//
//  Item.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation
import UIKit

struct ItemModel: Codable, Identifiable {
var id: UUID // UUID
var name: String // Name
var partNo: String? // Part No.
var unitCost: Double? // Unit Cost
var vendor: String? // Vendor
var itemCategoryRef: UUID? // Item Category Ref.
var itemSubcategoryRef: UUID? // Item Subcategory Ref.
var quantity: Int? // Quantity
var description: String? // Description
var usage: String? // Usage

// Default Common Fields
var createdOn: Date // Created on
var createdBy: UUID // Created by
var modifiedOn: Date? // Modified on
var modifiedBy: UUID? // Modified by
var inactive: Bool // Inactive
}

class ItemCell: UITableViewCell {
    static let reuseID = "ItemCell"
    
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        nameLabel.font = .boldSystemFont(ofSize: 18)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
