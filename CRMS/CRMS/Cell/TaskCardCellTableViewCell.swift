import UIKit

class TaskCardCell: UITableViewCell {

    static let identifier = "TaskCardCell"

    private let cardView = UIView()

    private let requestIdLabel = UILabel()
    private let priorityLabel = UILabel()
    private let locationLabel = UILabel()
    private let problemLabel = UILabel()
    private let dateLabel = UILabel()

    private let statusDot = UIView()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // Card
        cardView.backgroundColor = .white  
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray4.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Labels
        requestIdLabel.font = .systemFont(ofSize: 18, weight: .bold)

        priorityLabel.font = .systemFont(ofSize: 14, weight: .medium)
        priorityLabel.textColor = .systemRed

        locationLabel.font = .systemFont(ofSize: 14)
        problemLabel.font = .systemFont(ofSize: 14)

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel

        // Status
        statusDot.layer.cornerRadius = 5
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10)
        ])

        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)

        let statusStack = UIStackView(arrangedSubviews: [statusDot, statusLabel])
        statusStack.axis = .horizontal
        statusStack.spacing = 6
        statusStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [
            requestIdLabel,
            priorityLabel,
            locationLabel,
            problemLabel,
            dateLabel,
            statusStack
        ])

        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Configure with Request
    func configure(with request: Request) {

        requestIdLabel.text = request.requestNo
        priorityLabel.text = "Priority: \(priorityText(request.priority))"
        locationLabel.text = "Room: \(request.roomRef.uuidString.prefix(6))"
        problemLabel.text = request.description

        // ✅ FIX: createdOn is already Date
        let df = DateFormatter()
        df.dateFormat = "d/MM/yyyy"
        dateLabel.text = df.string(from: request.createdOn)

        statusLabel.text = statusText(request.status)
        statusDot.backgroundColor = statusColor(request.status)
    }

    // MARK: - Helpers (ADDED)
    private func priorityText(_ priority: Priority?) -> String {
        switch priority {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        default: return "-"
        }
    }

    private func statusText(_ status: Status) -> String {
        switch status {
        case .submitted: return "Submitted"
        case .assigned: return "Assigned"
        case .inProgress: return "In Progress"
        case .onHold: return "On Hold"
        case .cancelled: return "Cancelled"
        case .delayed: return "Delayed"
        case .completed: return "Completed"
        }
    }

    private func statusColor(_ status: Status) -> UIColor {
        switch status {
        case .completed: return .systemGreen
        case .inProgress: return .systemOrange
        case .delayed: return .systemRed
        default: return .systemGray
        }
    }

    // MARK: - Reuse (ADDED)
    override func prepareForReuse() {
        super.prepareForReuse()
        requestIdLabel.text = nil
        priorityLabel.text = nil
        locationLabel.text = nil
        problemLabel.text = nil
        dateLabel.text = nil
        statusLabel.text = nil
        statusDot.backgroundColor = .clear
    }
}
