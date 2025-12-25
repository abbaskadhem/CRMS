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
    
    @IBOutlet weak var addButton: UIButton!
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpacerCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)

    }

    private func loadSampleData() {

        // Parent category IDs
        let hardwareID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let licensedID = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!

        // Child category IDs
        let electricalID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let networkingID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let hvacID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

        categories = [
            // Parent Categories
            ItemCategoryModel(
                id: hardwareID,
                name: "Hardware",
                isParent: true,
                parentCategoryRef: nil,
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false,
                isExpanded: false
            ),
            ItemCategoryModel(
                id: licensedID,
                name: "Licensed",
                isParent: true,
                parentCategoryRef: nil,
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false,
                isExpanded: false
            ),

            // Child Categories
            ItemCategoryModel(
                id: electricalID,
                name: "Electrical",
                isParent: false,
                parentCategoryRef: hardwareID,
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false,
                isExpanded: false
            ),
            ItemCategoryModel(
                id: networkingID,
                name: "Networking",
                isParent: false,
                parentCategoryRef: hardwareID,
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false,
                isExpanded: false
            ),
            ItemCategoryModel(
                id: hvacID,
                name: "HVAC",
                isParent: false,
                parentCategoryRef: licensedID,
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false,
                isExpanded: false
            )
        ]




    }

    // Helpers
    var parentCategories: [ItemCategoryModel] {
        categories.filter { $0.isParent && !$0.inactive }
    }

    func children(for parent: ItemCategoryModel) -> [ItemCategoryModel] {
        categories.filter { !$0.isParent && $0.parentCategoryRef == parent.id && !$0.inactive }
    }
    
//    number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
            return parentCategories.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let parent = parentCategories[section]
            return parent.isExpanded ? children(for: parent).count * 2+1: 0
        }

//    For each cell
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row % 2 == 0 {
            
            // Empty spacer cell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath)
                    cell.backgroundColor = .clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CategoryCell.reuseID,
                for: indexPath
            ) as! CategoryCell
            
            let childIndex = (indexPath.row - 1) / 2
            let parent = parentCategories[indexPath.section]
            let child = children(for: parent)[childIndex]
            
            cell.textLabel?.text = child.name
            
            
            
            print(type(of: cell))
            return cell
        }

           
    }


        // Section header as blue bar
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        let parent = parentCategories[section]

        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "#8aa7bc")
        headerView.layer.cornerRadius = 8
        headerView.clipsToBounds = true
        headerView.tag = section

        // Title
        let titleLabel = UILabel()
        titleLabel.text = parent.name
        titleLabel.textColor = UIColor(hex: "#0f1929")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Arrow
        let arrowImageView = UIImageView(image: UIImage(named: "custom_arrow"))
        arrowImageView.contentMode = .scaleAspectFit

        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.tag = 999   // IMPORTANT: identify arrow later

        // Rotate arrow if expanded
        arrowImageView.transform = parent.isExpanded
            ? CGAffineTransform(rotationAngle: .pi / 2)
            : .identity

        headerView.addSubview(titleLabel)
        headerView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            arrowImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
        headerView.addGestureRecognizer(tap)

        return headerView
    }


//    height of header
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 44
        }
        
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row % 2 == 0 ? 10:UITableView.automaticDimension
    }

    
//    section toggle
    @objc private func toggleSection(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view else { return }
        let section = headerView.tag

        let isNowExpanded = !parentCategories[section].isExpanded

        categories = categories.map { cat in
            var c = cat
            if c.id == parentCategories[section].id {
                c.isExpanded = isNowExpanded
            }
            return c
        }

        if let arrow = headerView.viewWithTag(999) {
            UIView.animate(withDuration: 0.25) {
                arrow.transform = isNowExpanded
                    ? CGAffineTransform(rotationAngle: .pi / 2)
                    : .identity
            }
        }

        tableView.reloadSections([section], with: .automatic)
    }

    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    
    var selectedChild: ItemCategoryModel?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Ignore spacer rows
        guard indexPath.row % 2 != 0 else { return }

        let parent = parentCategories[indexPath.section]
        let childIndex = (indexPath.row - 1) / 2
        let child = children(for: parent)[childIndex]
        print(child.name)
        
        // Store the selected child temporarily
        selectedChild = child

            // Perform the segue
            performSegue(withIdentifier: "ShowItemSegue", sender: self)
        
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItemSegue",
           let itemVC = segue.destination as? ItemViewController {
            itemVC.child = selectedChild
            itemVC.title = selectedChild?.name
        }
    }

    
    @IBOutlet weak var addView: UIView!
    
    var overlayView: UIView!

    @IBAction func addCategoryTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let categoryVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController {

               // This enables the "slide up" animation and dimmed background automatically
               categoryVC.modalPresentationStyle = .pageSheet

               if let sheet = categoryVC.sheetPresentationController {
                   sheet.detents = [.medium()]               // roughly half-screen
                   sheet.prefersGrabberVisible = true        // optional drag handle
                   sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                   sheet.preferredCornerRadius = 16
               }

               self.present(categoryVC, animated: true)      // slide-up animation
           }
    }

    
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
