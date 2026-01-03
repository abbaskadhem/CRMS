//
//  InventoryCategoryCell.swift
//  CRMS
//
//  Created by Reem Janahi on 02/01/2026.
//

import Foundation
import UIKit


final class InventoryParentCell: UITableViewCell {

    static let reuseID = "InventoryParentCell"

    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let arrowImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = AppColors.secondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textColor = AppColors.text
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)

        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = AppColors.primary
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 50),

            arrowImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func configure(title: String, expanded: Bool) {
        nameLabel.text = title
        arrowImageView.image = UIImage(
            systemName: expanded ? "chevron.down" : "chevron.right"
        )

        isAccessibilityElement = true
        accessibilityLabel = "Category: \(title)"
        accessibilityValue = expanded ? "Expanded" : "Collapsed"
        accessibilityTraits = .button
    }
}

final class InventoryChildCell: UITableViewCell {

    static let reuseID = "InventoryChildCell"

    private let containerView = UIView()
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = AppColors.background
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = AppColors.primary.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)

        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            containerView.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func configure(title: String) {
        nameLabel.text = title
    }
}
