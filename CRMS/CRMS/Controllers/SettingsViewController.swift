//
//  SettingsViewController.swift
//  CRMS
//
//  Created by BP-36-201-04 on 18/12/2025.
//

import Foundation
//Apple's UI tools
import UIKit


//Class declaration
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    //Load the screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        //Table view layout settings
        tableView.contentInset = UIEdgeInsets(top:16, left: 0, bottom: 40, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        


    }
    
    
     //Number of sections
     func numberOfSections(in tableView: UITableView) -> Int {
        return 4 //Profile, Pereferences,Support & Info, Logout
    }
    
     //Number of rows per section
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
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //Cell configuration
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        //Profile cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "primcolorsec")
            cell.layer.cornerRadius = 15
            cell.clipsToBounds = true

            return cell
        //Preferences cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Preferences", for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "primcolorsec")

            
            //Row titles, icons and colors
            if indexPath.row == 0{
                cell.textLabel?.text = "Notifications"
                cell.imageView?.image = UIImage(systemName: "bell")
                cell.imageView?.tintColor = UIColor.label
            }else{
                cell.textLabel?.text = "Dark/Light Mode"
                cell.imageView?.image = UIImage(systemName: "moon")
                cell.imageView?.tintColor = UIColor.label
                
            }

            //Add Switch
            let toggle = UISwitch()
            toggle.onTintColor = UIColor(named: "seccolor")
            cell.accessoryView = toggle
            return cell
        //Support & Info cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo", for: indexPath)
            //Rows titles, icons and colors
            if indexPath.row == 0{
                cell.textLabel?.text = "About App"
                cell.imageView?.image = UIImage(systemName: "info.circle")
                cell.imageView?.tintColor = UIColor.label
            }else{
                cell.textLabel?.text = "FAQ"
                cell.imageView?.image = UIImage(systemName: "questionmark.circle")
                cell.imageView?.tintColor = UIColor.label
            }
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "primcolorsec")
            cell.accessoryType = .disclosureIndicator
            
            return cell
        //Logout cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            cell.textLabel?.text = "Logout"
            cell.imageView?.image = UIImage(systemName: "arrow.backward.square")
            cell.imageView?.tintColor = UIColor.label
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "primcolorsec")
            cell.layer.cornerRadius = 15
            cell.clipsToBounds = true
            return cell
        default :
            return UITableViewCell()
        }
         

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
            case 0: return
         120
            default : return 52
        }
    }
    //sections headers
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0: return "Profile"
        case 1: return "Preferences"
        case 2: return "Support & Information"
        case 3: return "Logout"
        default : return nil
        }
    }
    
    //selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if About App is selected
        if indexPath.section == 2 && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "AboutApp", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AboutAppViewController")
            navigationController?.pushViewController(vc, animated: true)
        }
        
        //If Logout is selected
        if indexPath.section == 3 {
            showLogoutPopup()
        }
    }
    func showLogoutPopup() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        //alert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .destructive))
        //logout logic :
        present(alert,animated: true,completion: nil)
            
        }
            
        
    }
        
    

