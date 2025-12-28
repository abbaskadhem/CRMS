//
//  AboutAppViewController.swift
//  CRMS
//
//  Created by Maryam Abdulla on 18/12/2025.
//

import UIKit

// About App screen controller
// Displays app logo, description, and app-related information
class AboutAppViewController: UIViewController,
                              UITableViewDelegate,
                              UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!

    // MARK: - Static app information data
    // This data is only for display
    private let appInfo: [(icon: String, title: String, value: String)] = [
        ("text.document", "Developer", "CRMS TEAM"),
        ("globe", "Website", "www.CRMS.bh"),
        ("envelope", "Support", "support@CRMS.bh")
    ]

    // MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign table view delegate & data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Table view appearance setup
        tableView.rowHeight = 52
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 16,
                                              left: 16,
                                              bottom: 40,
                                              right: 16)
    }

    // MARK: - Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make the logo image perfectly circular
        logoImageView.layer.cornerRadius = logoImageView.bounds.width / 2
        logoImageView.clipsToBounds = true
    }

    // MARK: - Table view data source

    // Only one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows equals number of app info items
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return appInfo.count
    }

    // Configure each table view cell
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Get current app info item
        let info = appInfo[indexPath.row]

        // Dequeue reusable cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AppInfoCell",
            for: indexPath
        )

        // Use modern content configuration
        var config = UIListContentConfiguration.subtitleCell()
        config.text = info.title

        // Website & Support appear blue and underlined (visual only)
        if info.title == "Website" || info.title == "Support" {
            let attributedValue = NSAttributedString(
                string: info.value,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            )
            config.secondaryAttributedText = attributedValue
        } else {
            // Normal text for Developer
            config.secondaryText = info.value
        }

        // Configure SF Symbol icon
        if let image = UIImage(systemName: info.icon) {
            config.image = image
            config.imageProperties.tintColor = .label
            config.imageProperties.reservedLayoutSize = CGSize(width: 28,
                                                               height: 28)
        }

        // Apply configuration to cell
        cell.contentConfiguration = config

        // Card-style rounded background for each cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "primcolorsec")
            ?? UIColor.secondarySystemBackground
        backgroundView.layer.cornerRadius = 12
        backgroundView.clipsToBounds = true
        cell.backgroundView = backgroundView

        // Informational only (no navigation or actions)
        cell.selectionStyle = .none

        return cell
    }

    // MARK: - Table view delegate
    // Rows are informational only
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
