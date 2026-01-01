//
//  RequestDetailViewController.swift
//  CRMS
//
//  Detail view for a single request (Admin view)
//

import UIKit

final class RequestDetailViewController: UIViewController {

    // MARK: - Properties
    var requestId: UUID?
    private var requestModel: RequestDisplayModel?

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    // Request Info
    @IBOutlet weak var requestNoLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusDot: UIView!
    @IBOutlet weak var priorityLabel: UILabel!

    // Problem Section
    @IBOutlet weak var mainCategoryLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    // Images Section
    @IBOutlet weak var imagesStackView: UIStackView!

    // Location Section
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!

    // Dates Section
    @IBOutlet weak var submittedDateLabel: UILabel!

    // Action Buttons Container
    @IBOutlet weak var actionButtonsStackView: UIStackView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRequestDetails()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppColors.background
        scrollView?.backgroundColor = AppColors.background

        // Title styling
        titleLabel?.textColor = AppColors.text
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        // Back button
        backButton?.tintColor = AppColors.text

        // Status dot
        statusDot?.layer.cornerRadius = 5

        // Description text view
        descriptionTextView?.backgroundColor = AppColors.inputBackground
        descriptionTextView?.layer.cornerRadius = 8
        descriptionTextView?.layer.borderWidth = 1
        descriptionTextView?.layer.borderColor = AppColors.inputBorder.cgColor
        descriptionTextView?.textColor = AppColors.text
        descriptionTextView?.isEditable = false

        // Activity indicator
        activityIndicator?.hidesWhenStopped = true
    }

    // MARK: - Data Fetching

    private func fetchRequestDetails() {
        guard let requestId = requestId else {
            showAlert(title: "Error", message: "No request ID provided")
            return
        }

        activityIndicator?.startAnimating()

        Task {
            do {
                let model = try await RequestController.shared.getRequestForDisplay(requestId: requestId)
                await MainActor.run {
                    self.activityIndicator?.stopAnimating()
                    if let model = model {
                        self.requestModel = model
                        self.populateData()
                    } else {
                        self.showAlert(title: "Error", message: "Request not found")
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator?.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func populateData() {
        guard let model = requestModel else { return }

        // Request Info
        requestNoLabel?.text = model.requestNo
        statusLabel?.text = model.statusString
        statusDot?.backgroundColor = statusColor(for: model.status)

        // Priority
        let priorityText = NSMutableAttributedString(string: "Priority: ", attributes: [
            .foregroundColor: AppColors.text,
            .font: UIFont.systemFont(ofSize: 14)
        ])
        let priorityValue = NSAttributedString(string: model.priorityString, attributes: [
            .foregroundColor: priorityColor(for: model.priority),
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        priorityText.append(priorityValue)
        priorityLabel?.attributedText = priorityText

        // Problem Section
        mainCategoryLabel?.text = model.categoryName
        subCategoryLabel?.text = model.subcategoryName
        descriptionTextView?.text = model.description

        // Location
        buildingLabel?.text = "Building \(model.buildingNo)"
        roomLabel?.text = "Room \(model.roomNo)"

        // Dates
        submittedDateLabel?.text = model.formattedDate

        // Load images if any
        loadImages()

        // Setup action buttons based on status
        setupActionButtons()
    }

    private func loadImages() {
        guard let images = requestModel?.images, !images.isEmpty else {
            imagesStackView?.isHidden = true
            return
        }

        imagesStackView?.isHidden = false
        // Clear existing image views
        imagesStackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for imageUrl in images {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.backgroundColor = AppColors.inputBorder
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

            // Load image from URL
            if let url = URL(string: imageUrl) {
                loadImage(from: url, into: imageView)
            }

            imagesStackView?.addArrangedSubview(imageView)
        }
    }

    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }

    private func setupActionButtons() {
        // Clear existing buttons
        actionButtonsStackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let model = requestModel else { return }

        // Action buttons will be configured based on status
        // This will be implemented later based on admin actions
        // For now, just show a placeholder message

        let placeholderLabel = UILabel()
        placeholderLabel.text = "Actions will be available based on request status"
        placeholderLabel.textColor = AppColors.secondary
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.textAlignment = .center
        actionButtonsStackView?.addArrangedSubview(placeholderLabel)
    }

    // MARK: - Actions

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Helpers

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
            return UIColor.systemYellow
        case .assigned:
            return UIColor.systemBlue
        case .inProgress:
            return UIColor.systemBlue
        case .onHold:
            return UIColor.systemGray
        case .cancelled:
            return UIColor.systemRed
        case .delayed:
            return UIColor.systemOrange
        case .completed:
            return UIColor.systemGreen
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if title == "Error" {
                self?.dismiss(animated: true)
            }
        })
        present(alert, animated: true)
    }
}
