//
//  RequestCardCell.swift
//  CRMS
//
//  Custom table view cell for request cards
//

import UIKit

final class RequestCardCell: UITableViewCell {

    static let identifier = "RequestCardCell"

    // MARK: - UI Elements

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let requestNoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = AppColors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = AppColors.secondary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)

        cardView.addSubview(requestNoLabel)
        cardView.addSubview(statusDot)
        cardView.addSubview(statusLabel)
        cardView.addSubview(priorityLabel)
        cardView.addSubview(locationLabel)
        cardView.addSubview(categoryLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            // Card view
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Request No
            requestNoLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            requestNoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            // Status dot
            statusDot.centerYAnchor.constraint(equalTo: requestNoLabel.centerYAnchor),
            statusDot.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -6),
            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),

            // Status label
            statusLabel.centerYAnchor.constraint(equalTo: requestNoLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            // Priority
            priorityLabel.topAnchor.constraint(equalTo: requestNoLabel.bottomAnchor, constant: 8),
            priorityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            // Location
            locationLabel.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            // Category
            categoryLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            // Date
            dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            // Chevron
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    // MARK: - Configure

    func configure(with model: RequestDisplayModel) {
        requestNoLabel.text = model.requestNo
        statusLabel.text = model.statusString
        locationLabel.text = model.locationString
        categoryLabel.text = model.categoryString
        dateLabel.text = model.formattedDate

        // Priority with color
        let priorityText = NSMutableAttributedString(string: "Priority: ", attributes: [
            .foregroundColor: AppColors.text,
            .font: UIFont.systemFont(ofSize: 14)
        ])
        let priorityValue = NSAttributedString(string: model.priorityString, attributes: [
            .foregroundColor: priorityColor(for: model.priority),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        priorityText.append(priorityValue)
        priorityLabel.attributedText = priorityText

        // Status dot color
        statusDot.backgroundColor = statusColor(for: model.status)
    }

    private func priorityColor(for priority: Priority?) -> UIColor {
        guard let priority = priority else {
            return AppColors.secondary
        }
        switch priority {
        case .low:
            return UIColor.systemGreen
        case .moderate:
            return UIColor.systemOrange
        case .high:
            return UIColor.systemRed
        }
    }

    private func statusColor(for status: Status) -> UIColor {
        switch status {
        case .submitted:
            return AppColors.statusSubmitted
        case .assigned:
            return AppColors.statusAssigned
        case .inProgress:
            return AppColors.statusInProgress
        case .onHold:
            return AppColors.statusOnHold
        case .cancelled:
            return AppColors.statusCancelled
        case .delayed:
            return AppColors.statusDelayed
        case .completed:
            return AppColors.statusCompleted
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        requestNoLabel.text = nil
        statusLabel.text = nil
        priorityLabel.attributedText = nil
        locationLabel.text = nil
        categoryLabel.text = nil
        dateLabel.text = nil
    }
}
