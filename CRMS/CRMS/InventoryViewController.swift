//
//  InventoryViewController.swift
//  CRMS
//
//  Created by BP-36-201-11 on 22/12/2025.
//

import UIKit

class InventoryViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!

    var categories: [ItemCategoryModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        loadSampleData()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // remove empty cells
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    private func loadSampleData() {
        let hardwareID = UUID()
        let licensedID = UUID()

        categories = [
            // Parents
            ItemCategoryModel(id: hardwareID, name: "Hardware", isParent: true, parentCategoryRef: nil, createdOn: Date(), createdBy: UUID(), modifiedOn: nil, modifiedBy: nil, inactive: false, isExpanded: false),
            ItemCategoryModel(id: licensedID, name: "Licensed", isParent: true, parentCategoryRef: nil, createdOn: Date(), createdBy: UUID(), modifiedOn: nil, modifiedBy: nil, inactive: false, isExpanded: false),

            // Children
            ItemCategoryModel(id: UUID(), name: "Electrical", isParent: false, parentCategoryRef: hardwareID, createdOn: Date(), createdBy: UUID(), modifiedOn: nil, modifiedBy: nil, inactive: false),
            ItemCategoryModel(id: UUID(), name: "Networking", isParent: false, parentCategoryRef: hardwareID, createdOn: Date(), createdBy: UUID(), modifiedOn: nil, modifiedBy: nil, inactive: false),
            ItemCategoryModel(id: UUID(), name: "HVAC", isParent: false, parentCategoryRef: licensedID, createdOn: Date(), createdBy: UUID(), modifiedOn: nil, modifiedBy: nil, inactive: false)
        ]
    }

    // Helpers
    var parentCategories: [ItemCategoryModel] {
        categories.filter { $0.isParent && !$0.inactive }
    }

    func children(for parent: ItemCategoryModel) -> [ItemCategoryModel] {
        categories.filter { !$0.isParent && $0.parentCategoryRef == parent.id && !$0.inactive }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
            return parentCategories.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let parent = parentCategories[section]
            return parent.isExpanded ? children(for: parent).count : 0
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let parent = parentCategories[indexPath.section]
        let child = children(for: parent)[indexPath.row]

        cell.textLabel?.text = child.name
        cell.selectionStyle = .none
        cell.backgroundColor = .clear  // No background color
        cell.layer.borderColor = UIColor.black.cgColor  // Border color
        cell.layer.borderWidth = 1  // Thin border
        cell.layer.cornerRadius = 8
        cell.preservesSuperviewLayoutMargins = false
        
        // Adjust margins for spacing
        cell.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 5, right: 10)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        // Adding tap gesture to entire cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(childTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        cell.isUserInteractionEnabled = true
        cell.tag = indexPath.row // You can set tag to identify which child is tapped

        return cell
    }

        // Section header as blue bar
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let parent = parentCategories[section]

            let headerView = UIView()
            headerView.backgroundColor = UIColor(hex: "#8aa7bc")
            headerView.layer.cornerRadius = 8
            headerView.clipsToBounds = true

            let titleLabel = UILabel()
            titleLabel.text = parent.name
            titleLabel.textColor = UIColor(hex: "#0f1929")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            
            headerView.addSubview(titleLabel)
           


            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])

            // Add tap gesture
            headerView.tag = section
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
            headerView.addGestureRecognizer(tap)

            return headerView
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 44
        }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40 // Example height; adjust based on your desired spacing.
    }
    
        @objc private func toggleSection(_ sender: UITapGestureRecognizer) {
            guard let section = sender.view?.tag else { return }

            // Toggle isExpanded
            categories = categories.map { cat in
                var c = cat
                if c.id == parentCategories[section].id {
                    c.isExpanded.toggle()
                }
                return c
            }

            tableView.reloadSections([section], with: .automatic)
        }

    @objc private func childTapped(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell else { return }
        
        let point = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }
        
        let parent = parentCategories[indexPath.section]
        let child = children(for: parent)[indexPath.row]
        
        // Perform the desired action
        print("Tapped on child: \(child.name)")
        
        // Optionally navigate to a detail view
        // navigateToDetailView(for: child)
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

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
