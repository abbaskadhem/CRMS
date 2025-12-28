//
//  SettingsViewController.swift
//  CRMS
//
//  Created by Maryam Abdulla on 18/12/2025.
//

import UIKit
import FirebaseAuth

// Settings screen controller
// Handles UI for Profile, Preferences, Support & Info, and Logout
class SettingsViewController: UIViewController,
                              UITableViewDelegate,
                              UITableViewDataSource {
    
    // Table view outlet connected from storyboard
    @IBOutlet weak var tableView: UITableView!

    // Switches
    private let notificationSwitch = UISwitch()
    private let appearanceSwitch = UISwitch()

    // UserDefaults keys
    private let notificationsKey = "notificationsEnabled"
    private let darkModeKey = "darkModeEnabled"

    // MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegate & data source
        tableView.delegate = self
        tableView.dataSource = self

        // Table view appearance layout
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        setupSwitches()

        // Later DB
        // fetchUserProfile()
    }

    // MARK: - Switch setup
    private func setupSwitches() {
        // Load saved states
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: notificationsKey)
        appearanceSwitch.isOn = UserDefaults.standard.bool(forKey: darkModeKey)

        // Colors
        notificationSwitch.onTintColor = UIColor(named: "seccolor")
        appearanceSwitch.onTintColor = UIColor(named: "seccolor")

        // Actions
        notificationSwitch.addTarget(self,
                                     action: #selector(notificationSwitchChanged(_:)),
                                     for: .valueChanged)

        appearanceSwitch.addTarget(self,
                                   action: #selector(appearanceSwitchChanged(_:)),
                                   for: .valueChanged)

        // Apply saved appearance on launch
        applyInterfaceStyle(dark: appearanceSwitch.isOn)
    }

    // MARK: - Sections
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Profile, Preferences, Support & Info, Logout
    }

    // Rows per section
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        case 3: return 1
        default: return 0
        }
    }

    // Section spacing
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }

    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    // MARK: - Cell configuration
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell

        switch indexPath.section {

        case 0: // Profile
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)

        case 1: // Preferences
            cell = tableView.dequeueReusableCell(withIdentifier: "Preferences", for: indexPath)

            if indexPath.row == 0 {
                cell.textLabel?.text = "Notifications"
                cell.imageView?.image = UIImage(systemName: "bell")
                cell.accessoryView = notificationSwitch
            } else {
                cell.textLabel?.text = "Dark / Light Mode"
                cell.imageView?.image = UIImage(systemName: "moon")
                cell.accessoryView = appearanceSwitch
            }

        case 2: // Support & Info
            cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo", for: indexPath)

            if indexPath.row == 0 {
                cell.textLabel?.text = "About App"
                cell.imageView?.image = UIImage(systemName: "info.circle")
            } else {
                cell.textLabel?.text = "FAQ"
                cell.imageView?.image = UIImage(systemName: "questionmark.circle")
            }

            cell.accessoryType = .disclosureIndicator

        case 3: // Logout
            cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            cell.textLabel?.text = "Logout"
            cell.imageView?.image = UIImage(systemName: "arrow.backward.square")

        default:
            cell = UITableViewCell()
        }

        styleCell(cell)
        applyRoundedCorners(to: cell, at: indexPath)

        return cell
    }

    // MARK: - Toggle actions
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        // Save preference locally
        UserDefaults.standard.set(sender.isOn, forKey: notificationsKey)

        // TODO: Enable / disable push notifications later
    }

    @objc private func appearanceSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: darkModeKey)
        applyInterfaceStyle(dark: sender.isOn)
    }

    private func applyInterfaceStyle(dark: Bool) {
        let style: UIUserInterfaceStyle = dark ? .dark : .light
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }

    // MARK: - Cell styling
    private func styleCell(_ cell: UITableViewCell) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = UIColor(named: "primcolorsec")
        cell.imageView?.tintColor = UIColor.label
        cell.textLabel?.textColor = UIColor.label
    }

    // Row heights
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 120 }   // Profile
        if indexPath.section == 3 { return 50 }    // Logout
        return 60
    }

    // Section headers
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Profile"
        case 1: return "Preferences"
        case 2: return "Support & Information"
        case 3: return "Logout"
        default: return nil
        }
    }

    // MARK: - Cell selection
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        // About App
        if indexPath.section == 2 && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "AboutApp", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "AboutAppViewController"
            )
            navigationController?.pushViewController(vc, animated: true)
            return
        }

        // Logout
        if indexPath.section == 3 {
            showLogoutPopup()
        }
    }

    // MARK: - Logout popup
    func showLogoutPopup() {
        let alertController = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alertController.addAction(UIAlertAction(
            title: "Yes, I am sure",
            style: .destructive) { _ in
                self.performLogout()
            })

        present(alertController, animated: true)
    }

    // Logout logic
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Rounded corners per section setup
    private func applyRoundedCorners(to cell: UITableViewCell,
                                     at indexPath: IndexPath) {

        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let radius: CGFloat = 15

        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.contentView.clipsToBounds = true

        if numberOfRows == 1 {
            cell.contentView.layer.cornerRadius = radius
            cell.contentView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            cell.contentView.layer.cornerRadius = radius
            cell.contentView.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
        } else if indexPath.row == numberOfRows - 1 {
            cell.contentView.layer.cornerRadius = radius
            cell.contentView.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
    }

    // MARK: - Database fetching logic (to be added later)
    /*
    private func fetchUserProfile() {
        guard Reachability.isConnectedToNetwork() else { return }
        do {
            // Firebase fetch here
        } catch {
            print(error)
        }
    }
    */
}
