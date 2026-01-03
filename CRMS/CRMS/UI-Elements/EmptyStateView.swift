//
//  EmptyStateView.swift
//  CRMS
//
//  Reusable empty state view for table views with no data
//

import UIKit

/// A reusable view displayed when a table/collection has no data
final class EmptyStateView: UIView {

    // MARK: - UI Elements

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.secondary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.title2
        label.textColor = AppColors.text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.body
        label.textColor = AppColors.placeholder
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppTypography.headline
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.primary
        button.layer.cornerRadius = AppSize.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private var actionHandler: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            // Icon
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),

            // Title
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: AppSpacing.lg),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpacing.xxl),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpacing.xxl),

            // Message
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AppSpacing.sm),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpacing.xxl),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpacing.xxl),

            // Action Button
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: AppSpacing.xl),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            actionButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight)
        ])

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    // MARK: - Configuration

    /// Configures the empty state view with content
    /// - Parameters:
    ///   - icon: SF Symbol name for the icon
    ///   - title: The title text
    ///   - message: The descriptive message
    ///   - buttonTitle: Optional button title (if nil, button is hidden)
    ///   - action: Optional action handler for the button
    func configure(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        messageLabel.text = message

        if let buttonTitle = buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.isHidden = false
            actionHandler = action
        } else {
            actionButton.isHidden = true
            actionHandler = nil
        }
    }

    @objc private func actionButtonTapped() {
        actionHandler?()
    }
}

// MARK: - Common Empty States

extension EmptyStateView {

    /// Creates an empty state for no requests
    static func noRequests() -> EmptyStateView {
        let view = EmptyStateView()
        view.configure(
            icon: "doc.text.magnifyingglass",
            title: "No Requests",
            message: "There are no requests to display at this time."
        )
        return view
    }

    /// Creates an empty state for no notifications
    static func noNotifications() -> EmptyStateView {
        let view = EmptyStateView()
        view.configure(
            icon: "bell.slash",
            title: "No Notifications",
            message: "You don't have any notifications yet."
        )
        return view
    }

    /// Creates an empty state for no search results
    static func noSearchResults() -> EmptyStateView {
        let view = EmptyStateView()
        view.configure(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No items match your search. Try a different search term."
        )
        return view
    }

    /// Creates an empty state for no categories
    static func noCategories() -> EmptyStateView {
        let view = EmptyStateView()
        view.configure(
            icon: "folder",
            title: "No Categories",
            message: "No categories have been created yet."
        )
        return view
    }
}
