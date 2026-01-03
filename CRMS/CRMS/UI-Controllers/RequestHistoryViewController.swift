//
//  RequestHistoryViewController.swift
//  CRMS
//
//  Displays the history of actions performed on a request
//

import UIKit
import Foundation

final class RequestHistoryViewController: UIViewController {

    // MARK: - Properties
    private let requestId: UUID
    private var historyRecords: [RequestHistoryDisplayModel] = []

    // MARK: - UI Components
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateView = EmptyStateView()

    // MARK: - Initializer
    init(requestId: UUID) {
        self.requestId = requestId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchHistory()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        title = "Request History"

        // Setup table view
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .singleLine
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        // Setup activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        // Setup empty state view
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppSpacing.xl),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppSpacing.xl)
        ])

        // Configure empty state view
        emptyStateView.configure(
            icon: "clock",
            title: "No History",
            message: "No history records found for this request"
        )
    }

    // MARK: - Data Fetching
    private func fetchHistory() {
        activityIndicator.startAnimating()
        tableView.isHidden = true

        Task {
            do {
                let records = try await RequestController.shared.getRequestHistory(requestId: requestId)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.historyRecords = records

                    if records.isEmpty {
                        self.emptyStateView.isHidden = false
                        self.tableView.isHidden = true
                    } else {
                        self.emptyStateView.isHidden = true
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension RequestHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }

        let record = historyRecords[indexPath.row]
        cell.configure(with: record)
        return cell
    }
}

// MARK: - HistoryTableViewCell
final class HistoryTableViewCell: UITableViewCell {
    static let identifier = "HistoryTableViewCell"

    private let actionLabel = UILabel()
    private let dateLabel = UILabel()
    private let userLabel = UILabel()
    private let reasonLabel = UILabel()
    private let reasonContainer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = AppColors.background
        selectionStyle = .none

        // Action label
        actionLabel.font = AppTypography.headline
        actionLabel.textColor = AppColors.text
        contentView.addSubview(actionLabel)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Date label
        dateLabel.font = AppTypography.footnote
        dateLabel.textColor = AppColors.placeholder
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        // User label
        userLabel.font = AppTypography.callout
        userLabel.textColor = AppColors.text
        contentView.addSubview(userLabel)
        userLabel.translatesAutoresizingMaskIntoConstraints = false

        // Reason container
        reasonContainer.backgroundColor = AppColors.inputBackground
        reasonContainer.layer.cornerRadius = AppSize.cornerRadiusMedium
        reasonContainer.layer.borderWidth = 1
        reasonContainer.layer.borderColor = AppColors.inputBorder.cgColor
        contentView.addSubview(reasonContainer)
        reasonContainer.translatesAutoresizingMaskIntoConstraints = false

        // Reason label
        reasonLabel.font = AppTypography.callout
        reasonLabel.textColor = AppColors.text
        reasonLabel.numberOfLines = 0
        reasonContainer.addSubview(reasonLabel)
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppSpacing.md),
            actionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.md),
            actionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.md),

            dateLabel.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: AppSpacing.xs),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.md),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.md),

            userLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: AppSpacing.xs),
            userLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.md),
            userLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.md),

            reasonContainer.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: AppSpacing.sm),
            reasonContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.md),
            reasonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.md),
            reasonContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppSpacing.md),

            reasonLabel.topAnchor.constraint(equalTo: reasonContainer.topAnchor, constant: AppSpacing.sm),
            reasonLabel.leadingAnchor.constraint(equalTo: reasonContainer.leadingAnchor, constant: AppSpacing.sm),
            reasonLabel.trailingAnchor.constraint(equalTo: reasonContainer.trailingAnchor, constant: -AppSpacing.sm),
            reasonLabel.bottomAnchor.constraint(equalTo: reasonContainer.bottomAnchor, constant: -AppSpacing.sm)
        ])
    }

    func configure(with model: RequestHistoryDisplayModel) {
        actionLabel.text = model.actionString
        dateLabel.text = model.dateString
        userLabel.text = "By: \(model.createdByName)"

        if model.hasReason, let reason = model.reasonText {
            reasonContainer.isHidden = false
            reasonLabel.text = "Reason: \(reason)"
        } else {
            reasonContainer.isHidden = true
        }
    }
}
