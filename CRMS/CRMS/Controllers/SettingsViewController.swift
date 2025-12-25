//
//  SettingsViewController.swift
//  CRMS
//
//  Created by BP-36-201-04 on 18/12/2025.
<<<<<<< HEAD
//


=======
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
import UIKit
import FirebaseAuth

<<<<<<< HEAD
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Table view layout
=======
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

    // Load the view
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign delegate & data source
        tableView.delegate = self
        tableView.dataSource = self

        // Table view appearance setup
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
<<<<<<< HEAD
    }
    
    // MARK: - Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Profile, Preferences, Support & Info, Logout
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
=======

        // Configure switches
        setupSwitches()
    }

    // Switch setup
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

    // Number of sections in Settings
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Profile, Preferences, Support & Info, Logout
    }

    // Number of rows per section
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
        switch section {
        case 0: return 1 // Profile
        case 1: return 2 // Notifications, Dark/Light Mode
        case 2: return 2 // About App, FAQ
        case 3: return 1 // Logout
        default: return 0
        }
    }
<<<<<<< HEAD
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
=======

    // Spacing setup
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
        return 24
    }

    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
<<<<<<< HEAD
    
    // MARK: - Cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell
        
        switch indexPath.section {
        // Profile
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)
 
        
        // Preferences
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Preferences", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Notifications"
                cell.imageView?.image = UIImage(systemName: "bell")
            } else {
                cell.textLabel?.text = "Dark/Light Mode"
                cell.imageView?.image = UIImage(systemName: "moon")
            }
            
            let toggle = UISwitch()
            toggle.onTintColor = UIColor(named: "seccolor")
            cell.accessoryView = toggle
            
        // Support & Info
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo", for: indexPath)
=======

    // Cell configuration
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell

        switch indexPath.section {

        // Profile cell
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile",
                                                 for: indexPath)

        // Preferences cells
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Preferences",
                                                 for: indexPath)

            if indexPath.row == 0 {
                cell.textLabel?.text = "Notifications"
                cell.imageView?.image = UIImage(systemName: "bell")
                cell.accessoryView = notificationSwitch
            } else {
                cell.textLabel?.text = "Dark / Light Mode"
                cell.imageView?.image = UIImage(systemName: "moon")
                cell.accessoryView = appearanceSwitch
            }

        // Support & Info cells
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo",
                                                 for: indexPath)

>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
            if indexPath.row == 0 {
                cell.textLabel?.text = "About App"
                cell.imageView?.image = UIImage(systemName: "info.circle")
            } else {
                cell.textLabel?.text = "FAQ"
                cell.imageView?.image = UIImage(systemName: "questionmark.circle")
            }
<<<<<<< HEAD
            cell.accessoryType = .disclosureIndicator
            
        // Logout
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
    
    private func styleCell(_ cell: UITableViewCell) {
        cell.backgroundColor = UIColor(named: "primcolorsec")
        cell.selectionStyle = .none
        cell.imageView?.tintColor = UIColor.label
        cell.textLabel?.textColor = UIColor.label
    }
    
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 120 : 52
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
=======

            // Indicates navigation to another screen
            cell.accessoryType = .disclosureIndicator

        // Logout cell
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "Logout",
                                                 for: indexPath)
            cell.textLabel?.text = "Logout"
            cell.imageView?.image = UIImage(systemName: "arrow.backward.square")

        default:
            cell = UITableViewCell()
        }

        // Apply shared styling
        styleCell(cell)

        // Apply rounded corners per section
        applyRoundedCorners(to: cell, at: indexPath)

        return cell
    }

    // Toggle actions
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: notificationsKey)
        // enable/disable notifications here
    }

    @objc private func appearanceSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: darkModeKey)
        applyInterfaceStyle(dark: sender.isOn)
    }

    private func applyInterfaceStyle(dark: Bool) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.overrideUserInterfaceStyle = dark ? .dark : .light
        }
    }

    // Cell styling
    private func styleCell(_ cell: UITableViewCell) {
        cell.backgroundColor = UIColor(named: "primcolorsec")
        cell.selectionStyle = .none
        cell.imageView?.tintColor = UIColor.label
        cell.textLabel?.textColor = UIColor.label
    }

    // Row heights
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 120 //profile
        }else if indexPath.section == 3{
            return 50 //logout
        }else{
            return 60 //other
        }
    }

    // Section headers
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
        switch section {
        case 0: return "Profile"
        case 1: return "Preferences"
        case 2: return "Support & Information"
        case 3: return "Logout"
        default: return nil
        }
    }
<<<<<<< HEAD
    
    // MARK: - Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // About App
=======

    // Cell selection handling
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        // Navigate to About App screen
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
        if indexPath.section == 2 && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "About App", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "AboutAppViewController"
            )
            navigationController?.pushViewController(vc, animated: true)
        }
<<<<<<< HEAD
        
        // Logout
=======

        /*
        // Navigate to FAQ screen
        if indexPath.section == 2 && indexPath.row == 1 {
            let faqVC = FAQViewController()
            navigationController?.pushViewController(faqVC, animated: true)
        }
        */

        /*
        // Show logout confirmation
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
        if indexPath.section == 3 {
            showLogoutPopup()
        }
        */
    }
<<<<<<< HEAD
=======

    /*
    // Logout confirmation
    func showLogoutPopup() {
        let alert = UIAlertController(title: "Logout",
                                      message: "Are you sure you want to logout?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, I am sure", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        present(alert, animated: true)
    }

    // Logout Logiuc
    private func performLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Logout failed")
        }
    }
    */

    // Rounded corners setup
    private func applyRoundedCorners(to cell: UITableViewCell,
                                     at indexPath: IndexPath) {

        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let radius: CGFloat = 15

        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.clipsToBounds = true

        if numberOfRows == 1 {
            // Single row section
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            // First row, round the top corners
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
        } else if indexPath.row == numberOfRows - 1 {
            // Last row, round the bottom corners
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
    }
}



        
>>>>>>> c3de36e (UI design done + about app done, fetching logic and subpages navigation left)
    
    //Logout popup
    func showLogoutPopup() {
        let alert = UIAlertController(title: "Logout",
                                      message: "Are you sure you want to logout?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // Add actual logout action when needed
        present(alert, animated: true, completion: nil)
    }
    
    //Rounded corners helper
    private func applyRoundedCorners(to cell: UITableViewCell, at indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let radius: CGFloat = 15
        
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.clipsToBounds = true
        
        if numberOfRows == 1 {
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == numberOfRows - 1 {
            cell.layer.cornerRadius = radius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}
