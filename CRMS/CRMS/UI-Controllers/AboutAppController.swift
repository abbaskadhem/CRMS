//
//  AboutAppViewController.swift
//  CRMS
//
//  Created by Maryam Abdulla on 18/12/2025.
//

import UIKit

// About App screen controller
// Displays app logo and static app information
class AboutAppViewController: UIViewController,
                              UITableViewDelegate,
                              UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!

    // MARK: - Static App Information
    private let appInfo: [(icon: String, title: String, value: String)] = [
        ("text.document", "Developer", "CRMS Team"),
        ("globe", "Website", "www.crms.bh"),
        ("envelope", "Support", "support@crms.bh")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Round logo
        logoImageView.layer.cornerRadius = logoImageView.frame.width / 2
        logoImageView.clipsToBounds = true

        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 64
        tableView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 40, right: 16)
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return appInfo.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let info = appInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AppInfoCell",
            for: indexPath
        )

        // Modern cell configuration
        var config = UIListContentConfiguration.subtitleCell()
        config.text = info.title

        // Website & Support styled as blue underlined text
        if info.title == "Website" || info.title == "Support" {
            config.secondaryAttributedText = NSAttributedString(
                string: info.value,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            )
        } else {
            config.secondaryText = info.value
        }

        // Icon
        if let image = UIImage(systemName: info.icon) {
            config.image = image
            config.imageProperties.tintColor = .label
        }

        cell.contentConfiguration = config

        // Card-style background
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "primcolorsec")
            ?? UIColor.secondarySystemBackground
        backgroundView.layer.cornerRadius = 14
        backgroundView.clipsToBounds = true
        cell.backgroundView = backgroundView

        cell.selectionStyle = .none
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Informational only
    }
}
