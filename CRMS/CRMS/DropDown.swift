//
//  DropDown.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//


import UIKit
struct DropDownItem {
    let title: String
}

final class DropDownView: UIView {

    // MARK: - UI

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let tableView = UITableView()
    private let headerView = UIView()

    // MARK: - Data

    private var items: [String] = []
    private var isOpen = false

    var onSelect: ((String) -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
//        setupTap()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupTableView()
//        setupTap()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .white

        titleLabel.text = "Select"
        titleLabel.textColor = .darkText

        arrowImageView.image = UIImage(systemName: "chevron.down")
        arrowImageView.tintColor = .gray

        let headerStack = UIStackView(arrangedSubviews: [
            titleLabel,
            arrowImageView
        ])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center

        headerView.addSubview(headerStack)
        addSubview(headerView)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            headerStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(toggleDropDown)
        )
        headerView.addGestureRecognizer(tap)
    }


    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.isHidden = true

        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 0)
        ])
    }


    // MARK: - Public

    func configure(
        title: String,
        items: [String]
    ) {
        titleLabel.text = title
        self.items = items
        tableView.reloadData()
    }

    // MARK: - Toggle

    @objc private func toggleDropDown() {
        isOpen.toggle()
        let height = CGFloat(items.count * 44)

        UIView.animate(withDuration: 0.25) {
            self.arrowImageView.transform =
                self.isOpen ? CGAffineTransform(rotationAngle: .pi) : .identity

            self.tableView.isHidden = false
            self.tableView.constraints
                .first { $0.firstAttribute == .height }?
                .constant = self.isOpen ? height : 0

            self.layoutIfNeeded()
        }

        if !isOpen {
            tableView.isHidden = true
        }
    }
}

// MARK: - TableView
extension DropDownView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = items[indexPath.row]
        titleLabel.text = selected
        onSelect?(selected)
        toggleDropDown()
    }
}
