//
//  NotificationCell.swift
//  CRMS
//
//  Created by Reem Janahi on 01/01/2026.
//

import Foundation
import UIKit


class NotificationCell: UITableViewCell {

    static let reuseID = "NotificationCell"

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let typeImageView = UIImageView()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = .clear
        containerView.layer.borderColor = AppColors.primary.cgColor
        containerView.layer.borderWidth = 2

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .black
        
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = AppColors.primary
        arrowImageView.contentMode = .scaleAspectFit

        typeImageView.translatesAutoresizingMaskIntoConstraints = false
        typeImageView.contentMode = .scaleAspectFit
        typeImageView.tintColor = .secondaryLabel


        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(typeImageView)

    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -44),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -44),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            arrowImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 14),

            typeImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            typeImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            typeImageView.widthAnchor.constraint(equalToConstant: 28),
            typeImageView.heightAnchor.constraint(equalToConstant: 28),

        ])
    }

    func configure(with notification: NotificationModel) {
        titleLabel.text = notification.title
        descriptionLabel.text = notification.description?.limitedToWords(15)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: notification.createdOn)

        switch notification.type {
        case .announcement:
            typeImageView.image = UIImage(systemName: "megaphone.fill")
            typeImageView.tintColor = AppColors.primary

        case .notification:
            typeImageView.image = UIImage(systemName: "bell.fill")
            typeImageView.tintColor = AppColors.primary
        }
    }

}

extension String {
    func limitedToWords(_ limit: Int) -> String {
        let normalized = self
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")

        let words = normalized.split(whereSeparator: \.isWhitespace)
        if words.count <= limit { return normalized }
        return words.prefix(limit).joined(separator: " ") + "…"
    }
}
