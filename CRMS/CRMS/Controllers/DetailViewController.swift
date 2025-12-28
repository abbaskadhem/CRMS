//
//  DetailViewController.swift
//  CRMS
//
//  Created by BP-36-201-11 on 25/12/2025.
//

import UIKit

class DetailViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate{
    var item: ItemModel!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(editItem)
        )

        let deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteItem)
        )

        navigationItem.rightBarButtonItems = [deleteButton, editButton]
        
        title = item.name

               tableView.delegate = self
               tableView.dataSource = self

        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.reuseID)
        tableView.register(TextAreaCell.self, forCellReuseIdentifier: TextAreaCell.reuseID)


        
        tableView.estimatedRowHeight = 120

          
    }

    @objc private func editItem() {
        print("Edit \(item.name)")
    }

    @objc private func deleteItem() {
        print("Delete \(item.name)")
    }


    func numberOfSections(in tableView: UITableView) -> Int {
          return 3
      }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Details"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // or whatever height you want
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create container view
        let headerView = UIView()
        headerView.backgroundColor = .clear // your header background

        // Create label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#53697f") // your text color
        label.text = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section) ?? ""

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8)
        ])

        // Add bottom border
        let bottomBorder = UIView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = UIColor(hex: "#53697f") // border color
        headerView.addSubview(bottomBorder)

        NSLayoutConstraint.activate([
            bottomBorder.heightAnchor.constraint(equalToConstant: 0.5),
            bottomBorder.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        return headerView
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 5  // Info cells
        case 1: return 1  // Description
        case 2: return 1  // Usage
        default: return 0
        }
    }


      func tableView(_ tableView: UITableView,
                     cellForRowAt indexPath: IndexPath) -> UITableViewCell {

          switch indexPath.section {

          case 0:
              let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.reuseID, for: indexPath) as! InfoCell


              switch indexPath.row {
              case 0: cell.configure(title: "Name", value: item.name)
              case 1: cell.configure(title: "Part Number", value: item.partNo ?? "empty")
              case 2: cell.configure(title: "Unit Cost", value: "\(item.unitCost ?? 0) BHD")
              case 3: cell.configure(title: "Vendor", value: item.vendor ?? "empty")
              case 4: cell.configure(title: "Quantity in Stock", value: "\(item.quantity ?? 0)")
              default: break
              }
              //add bottom borders only
              cell.titleLabel.textColor = UIColor(hex: "#53697f")



              cell.backgroundColor = .clear
              cell.selectionStyle = .none

              return cell

          case 1:
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: "TextAreaCell",
                  for: indexPath
              ) as! TextAreaCell

              cell.configure(title: "Description", text: item.description ?? "empty")
              cell.titleLabel.textColor = UIColor(hex: "#53697f")
              cell.layer.borderWidth = 0.5
              cell.layer.borderColor = UIColor.black.cgColor
              cell.selectionStyle = .none
              cell.backgroundColor = .clear
              return cell

          case 2:
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: "TextAreaCell",
                  for: indexPath
              ) as! TextAreaCell

              cell.configure(title: "Usage", text: item.usage ?? "empty")
              cell.titleLabel.textColor = UIColor(hex: "#53697f")
              cell.layer.borderWidth = 0.5
              cell.layer.borderColor = UIColor.black.cgColor
              cell.selectionStyle = .none
              cell.backgroundColor = .clear
              return cell

          default:
              return UITableViewCell()
          }
      }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
