//
//  SettingsViewController.swift
//  CRMS
//
//  Created by BP-36-201-04 on 18/12/2025.
//

import Foundation
import UIKit


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .none
        tableView.separatorColor = .none
        



    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 4 //Profile, Pereferences,Support & Info, Logout
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0: return 1
        case 1: return 2 //Notifications,Dark/Light Mode
        case 2: return 2 // About App, FAQ
        case 3: return 1
            default :
            return 0
    }
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = .clear
            cell.contentView.layer.cornerRadius = 12

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Preferences", for: indexPath)
            if indexPath.row == 0{
                cell.textLabel?.text = "Notifications"
            }else{
                cell.textLabel?.text = "Dark/Light Mode"
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo", for: indexPath)
            if indexPath.row == 0{
                cell.textLabel?.text = "About App"
            }else{
                cell.textLabel?.text = "FAQ"
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            return cell
        default :
            return UITableViewCell()
        }
         

    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0: return "Profile"
        case 1: return "Preferences"
        case 2: return "Support & Information"
        case 3: return "Logout"
        default : return nil
        }
    }
    
}
