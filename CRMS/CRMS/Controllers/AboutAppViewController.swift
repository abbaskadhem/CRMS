//
//  AboutAppViewController.swift
//  CRMS
//
//  Created by BP-36-201-04 on 18/12/2025.
//

import UIKit

class AboutAppViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!

    //info items
    private let appInfo: [(icon: String, title: String, value: String)] = [
        ("text.document", "Developer", "CRMS TEAM"),
        ("globe", "Website", "www.CRMS.bh"),
        ("envelope", "Support", "support@CRMS.bh")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the logo image
        logoImageView.layer.cornerRadius = logoImageView.frame.width / 2
        logoImageView.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 52
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 40, right: 16)
    }

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return appInfo.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AppInfoCell", for: indexPath)
        let info = appInfo[indexPath.row]

        cell.textLabel?.text = info.title
        cell.detailTextLabel?.text = info.value
        cell.imageView?.image = UIImage(systemName: info.icon)
        cell.imageView?.tintColor = .label
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "primcolorsec")

        //rounded cell
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true

        return cell
    }
}
