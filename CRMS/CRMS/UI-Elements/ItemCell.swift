//
//  ItemCell.swift
//  CRMS
//
//  Created by Reem Janahi on 01/01/2026.
//

import Foundation
import UIKit


//MARK: Item Cell

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


//MARK: Item First detail part
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
        titleLabel.backgroundColor = .clear

        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .darkGray
        valueLabel.textAlignment = .right
        valueLabel.backgroundColor = .clear

        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = AppColors.secondary
        textField.backgroundColor = .clear
        textField.textAlignment = .right
        textField.isHidden = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, textField])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear

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
        textField.backgroundColor = .clear
        textField.textColor = AppColors.text
        valueLabel.textColor = AppColors.text
        valueLabel.backgroundColor = .clear
        isEditingValue = editable
    }

    
    func currentValue() -> String {
        return isEditingValue ? textField.text ?? "" : valueLabel.text ?? ""
    }
}

//MARK: Item Second detail part
class TextAreaCell: UITableViewCell, UITextViewDelegate {

    static let reuseID = "TextAreaCell"

    let titleLabel = UILabel()
    let textView = UITextView()
    private let placeholderLabel = UILabel()

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
        
        setupPlaceholder()
    }
    private func setupPlaceholder() {
           placeholderLabel.textColor = .systemGray3
           placeholderLabel.font = textView.font
           placeholderLabel.numberOfLines = 0
           placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

           textView.addSubview(placeholderLabel)
           textView.delegate = self

           NSLayoutConstraint.activate([
               placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
               placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
               placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -5)
           ])
       }

    func configure(title: String, text: String?, placeholder: String? = nil) {
           titleLabel.text = title
           textView.text = text
           placeholderLabel.text = placeholder
           placeholderLabel.isHidden = !(text?.isEmpty ?? true)
       }
    
    func setEditable(_ editable: Bool) {
        textView.isEditable = editable
        textView.backgroundColor = .clear
    }
    
    func textViewDidChange(_ textView: UITextView) {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }

}

