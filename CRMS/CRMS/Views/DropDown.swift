//
//  DropDown.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class DropDownView: UIView {

    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let tableView = UITableView()
    private let headerView = UIView()

    private var tableHeightConstraint: NSLayoutConstraint! 

    private var items: [String] = []
    private var isOpen = false

    var onSelect: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupTableView()
    }

    private func setupView() {
        backgroundColor = .white

        titleLabel.text = "Select"
        titleLabel.textColor = .darkText

        arrowImageView.image = UIImage(systemName: "chevron.down")
        arrowImageView.tintColor = .gray

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
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

        headerView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleDropDown))
        headerView.addGestureRecognizer(tap)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.isHidden = true
        tableView.allowsSelection = true

        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0) // ✅ stable reference

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableHeightConstraint
        ])
    }

    func configure(title: String, items: [String]) {
        titleLabel.text = title
        self.items = items
        tableView.reloadData()
    }

    @objc private func toggleDropDown() {
        isOpen.toggle()

        let height = CGFloat(items.count) * tableView.rowHeight

        if isOpen {
            tableView.isHidden = false
            self.superview?.bringSubviewToFront(self)
            self.bringSubviewToFront(tableView)
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.arrowImageView.transform = self.isOpen ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.tableHeightConstraint.constant = self.isOpen ? height : 0
            self.layoutIfNeeded()
        }, completion: { _ in
            if !self.isOpen {
                self.tableView.isHidden = true
            }
        })
    }
}

extension DropDownView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = items[indexPath.row]
        titleLabel.text = selected
        print("✅ DropDownView selected:", selected)
        onSelect?(selected)
        toggleDropDown()
    }
}

