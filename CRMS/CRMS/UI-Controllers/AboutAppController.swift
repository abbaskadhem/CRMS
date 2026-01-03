//
//  AboutAppViewController.swift
//  CRMS
//
//  Created by Maryam Abdulla
//  Display App's information
//

import UIKit

final class AboutAppViewController: UIViewController,
                                   UITableViewDelegate,
                                   UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!

    // MARK: - Data Source
    //Displayed in a table view form
    private let appInfo: [(icon: String, title: String, value: String, action: (() -> Void)?)] = [
        ("doc.text", "Developer", "CRMS Team", nil),
        ("globe", "Website", "www.crms.bh", {
            if let url = URL(string: "https://www.crms.bh") {
                UIApplication.shared.open(url)
            }
        }),
        ("envelope", "Support", "support@crms.bh", {
            if let url = URL(string: "mailto:support@crms.bh") {
                UIApplication.shared.open(url)
            }
        })
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About App"
        view.backgroundColor = AppColors.background
        setupLogo()
        setupTableView()
    }

    // MARK: - UI Setup
    //Configure the appearance of the app logo
    private func setupLogo() {
        logoImageView.tintColor = AppColors.text
        logoImageView.clipsToBounds = true
    }
    //Configure table view appearance and behavior
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false

        // spacing around the card
        tableView.contentInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 32,
            right: 16
        )
    }

    // MARK: - Table Data
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return appInfo.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = appInfo[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AppInfoCell",
            for: indexPath
        )
        //Configure cell content
        var config = UIListContentConfiguration.subtitleCell()
        config.text = item.title
        config.textProperties.color = AppColors.text
        
        //If row has an action, style it as a link
        if item.action != nil {
            config.secondaryAttributedText = NSAttributedString(
                string: item.value,
                attributes: [
                    .foregroundColor: AppColors.secondary,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            )
        } else {
            config.secondaryText = item.value
            config.secondaryTextProperties.color = AppColors.text.withAlphaComponent(0.7)
        }

        config.image = UIImage(systemName: item.icon)
        config.imageProperties.tintColor = AppColors.text

        cell.contentConfiguration = config
        cell.selectionStyle = item.action == nil ? .none : .default

    
        return cell
    }

    // MARK: - Row Height
    ///Fixed height for each info row
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    // MARK: - Selection
    ///Handles row selection and triggers optional actions
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        appInfo[indexPath.row].action?()
    }
}
