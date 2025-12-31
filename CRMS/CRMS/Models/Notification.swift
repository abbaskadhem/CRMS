//
//  Notification.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation
import UIKit

enum NotiType: Int, Codable {
    case notification = 1000
    case announcement = 1001
}


// MARK: - Notification
struct NotificationModel: Codable, Identifiable {
var id: String // UUID
var title: String // Title
var description: String? // Description
var toWho: [String] // To who
var type: NotiType // Type
var requestRef: String? // Request Ref.

// Default Common Fields
var createdOn: Date // Created on
var createdBy: String // Created by
var modifiedOn: Date? // Modified on
var modifiedBy: String? // Modified by
var inactive: Bool // Inactive
}


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
        containerView.layer.borderColor = UIColor(hex: "#53697f").cgColor
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
        arrowImageView.tintColor = UIColor(hex: "#53697f")
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
        descriptionLabel.text = notification.description

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: notification.createdOn)

        switch notification.type {
        case .announcement:
            typeImageView.image = UIImage(systemName: "megaphone.fill")
            typeImageView.tintColor = UIColor(hex: "#53697f")

        case .notification:
            typeImageView.image = UIImage(systemName: "bell.fill")
            typeImageView.tintColor = UIColor(hex: "#53697f")
        }
    }

}
