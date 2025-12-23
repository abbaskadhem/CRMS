//
//  SettingsViewController.swift
//  CRMS
//
//  Created by BP-36-201-04 on 18/12/2025.
//


import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Table view layout
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 40, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    // MARK: - Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Profile, Preferences, Support & Info, Logout
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Profile
        case 1: return 2 // Notifications, Dark/Light Mode
        case 2: return 2 // About App, FAQ
        case 3: return 1 // Logout
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
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
            if indexPath.row == 0 {
                cell.textLabel?.text = "About App"
                cell.imageView?.image = UIImage(systemName: "info.circle")
            } else {
                cell.textLabel?.text = "FAQ"
                cell.imageView?.image = UIImage(systemName: "questionmark.circle")
            }
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
        switch section {
        case 0: return "Profile"
        case 1: return "Preferences"
        case 2: return "Support & Information"
        case 3: return "Logout"
        default: return nil
        }
    }
    
    // MARK: - Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // About App
        if indexPath.section == 2 && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "AboutApp", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AboutAppViewController")
            navigationController?.pushViewController(vc, animated: true)
        }
        
        // Logout
        if indexPath.section == 3 {
            showLogoutPopup()
        }
    }
    
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
