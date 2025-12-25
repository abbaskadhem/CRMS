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

class InfoCell: UITableViewCell {

    static let reuseID = "InfoCell"

    let titleLabel = UILabel()
    let valueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .darkGray
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center // ensures vertical alignment
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor(hex: "#53697f")
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomBorder)

        NSLayoutConstraint.activate([
            bottomBorder.heightAnchor.constraint(equalToConstant: 0.5),
            bottomBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

class TextAreaCell: UITableViewCell {

    static let reuseID = "TextAreaCell"

    let titleLabel = UILabel()
    let textView = UITextView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)

        textView.font = .systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear

        let stack = UIStackView(arrangedSubviews: [titleLabel, textView])
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

    func configure(title: String, text: String) {
        titleLabel.text = title
        textView.text = text
    }
}
