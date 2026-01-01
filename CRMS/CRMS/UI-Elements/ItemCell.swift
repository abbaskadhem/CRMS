//
//  ItemCell.swift
//  CRMS
//
//  Created by Reem Janahi on 01/01/2026.
//

import Foundation
import UIKit


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
        
        let chevronImageView = UIImageView();

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = AppColors.primary
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
}

class InfoCell: UITableViewCell {

    static let reuseID = "InfoCell"

    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let textField = UITextField()

    private var isEditingValue = false

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
        titleLabel.tintColor = AppColors.secondary

        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .darkGray
        valueLabel.textAlignment = .right

        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = AppColors.secondary
        textField.textAlignment = .right
        textField.isHidden = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, textField])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        

    }
    
   

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        textField.text = value
    }

    func setEditable(_ editable: Bool) {
        valueLabel.isHidden = editable
        textField.isHidden = !editable
        isEditingValue = editable
    }

    
    func currentValue() -> String {
        return isEditingValue ? textField.text ?? "" : valueLabel.text ?? ""
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
    
    func setEditable(_ editable: Bool) {
        textView.isEditable = editable
        textView.backgroundColor = editable ? UIColor.systemGray6 : .clear
    }

}

