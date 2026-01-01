//
//  SettingsViewController.swift
//  CRMS
//
//  Created by Maryam Abdulla on 18/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController,
                              UITableViewDelegate,
                              UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Switches
    private let notificationSwitch = UISwitch()
    private let appearanceSwitch = UISwitch()

    // MARK: - UserDefaults Keys
    private let notificationsKey = "notificationsEnabled"
    private let darkModeKey = "darkModeEnabled"

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - User Data
    private var fullName: String = ""
    private var email: String = ""
    private var roleText: String = ""

    // MARK: - Colors (code-based, no assets)
    private let primColorSec = UIColor(
        red: 83/255,
        green: 105/255,
        blue: 127/255,
        alpha: 0.15
    )

    private let toggleColor = UIColor(
        red: 138/255,
        green: 167/255,
        blue: 188/255,
        alpha: 1
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        setupSwitches()
        fetchUserProfile()
    }

    // MARK: - Switch Setup
    private func setupSwitches() {
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: notificationsKey)
        appearanceSwitch.isOn = UserDefaults.standard.bool(forKey: darkModeKey)

        notificationSwitch.onTintColor = toggleColor
        appearanceSwitch.onTintColor = toggleColor

        notificationSwitch.addTarget(self,
                                     action: #selector(notificationSwitchChanged(_:)),
                                     for: .valueChanged)

        appearanceSwitch.addTarget(self,
                                   action: #selector(appearanceSwitchChanged(_:)),
                                   for: .valueChanged)

        applyInterfaceStyle(dark: appearanceSwitch.isOn)
    }

    // MARK: - Firestore Fetch (WORKING)
    private func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }

        Task {
            do {
                let snapshot = try await db
                    .collection("users")
                    .document(uid)
                    .getDocument()

                guard let data = snapshot.data() else { return }

                self.fullName = data["fullName"] as? String ?? ""
                self.email = data["email"] as? String ?? ""

                let roleValue = data["type"] as? Int ?? -1
                self.roleText = mapRole(from: roleValue)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            } catch {
                print("Failed to fetch user profile")
            }
        }
    }

    private func mapRole(from role: Int) -> String {
        switch role {
        case 1000: return "Admin"
        case 1001: return "Requester"
        case 1002: return "Servicer"
        default: return "Unknown"
        }
    }

    // MARK: - Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

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

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }

    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    // MARK: - Cells
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell

        switch indexPath.section {

        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)
            cell.textLabel?.text = fullName
            cell.detailTextLabel?.text = "\(email)\n\(roleText)"
            cell.detailTextLabel?.numberOfLines = 0

        case 1:
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

        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo", for: indexPath)
            cell.textLabel?.text = indexPath.row == 0 ? "About App" : "FAQ"
            cell.imageView?.image = UIImage(systemName:
                indexPath.row == 0 ? "info.circle" : "questionmark.circle")
            cell.accessoryType = .disclosureIndicator

        case 3:
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

    // MARK: - Cell Styling (FIXED)
    private func styleCell(_ cell: UITableViewCell) {
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        let bgView = UIView()
        bgView.backgroundColor = primColorSec
        bgView.layer.masksToBounds = true

        cell.backgroundView = bgView
        cell.contentView.backgroundColor = .clear

        cell.textLabel?.textColor = .label
        cell.imageView?.tintColor = .label
    }

    // MARK: - Row Height
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 120 }
        if indexPath.section == 3 { return 50 }
        return 60
    }

    // MARK: - Section Headers
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

    // MARK: - Selection
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 2 && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "AboutApp", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "AboutAppViewController"
            )
            navigationController?.pushViewController(vc, animated: true)
        }
        print("About App tapped")

        if indexPath.section == 3 {
            showLogoutPopup()
        }
    }

    // MARK: - Toggles
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: notificationsKey)
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

    // MARK: - Logout
    private func showLogoutPopup() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, I am sure", style: .destructive) { _ in
            self.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Logout failed")
        }
    }

    // MARK: - Rounded Corners
    private func applyRoundedCorners(to cell: UITableViewCell,
                                     at indexPath: IndexPath) {

        let rows = tableView.numberOfRows(inSection: indexPath.section)
        let radius: CGFloat = 15

        cell.backgroundView?.layer.cornerRadius = 0
        cell.backgroundView?.layer.maskedCorners = []

        if rows == 1 {
            cell.backgroundView?.layer.cornerRadius = radius
            cell.backgroundView?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            cell.backgroundView?.layer.cornerRadius = radius
            cell.backgroundView?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
        } else if indexPath.row == rows - 1 {
            cell.backgroundView?.layer.cornerRadius = radius
            cell.backgroundView?.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
    }
}
