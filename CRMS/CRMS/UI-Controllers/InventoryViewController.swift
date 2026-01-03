//
//  InventoryViewController.swift
//  CRMS
//
//  Created by BP-36-201-11 on 22/12/2025.
//

import UIKit
import FirebaseFirestore

class InventoryViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource,
                               UISearchBarDelegate {


    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: Variables
    var categories: [ItemCategoryModel] = []
    var selectedChild: ItemCategoryModel?
    var parentCategories: [ItemCategoryModel] {
        if !isSearching {
            return categories.filter { $0.isParent && !$0.inactive }
        }

        let parentIDs = Set(
            filteredCategories.compactMap { $0.parentCategoryRef }
        )

        return categories.filter {
            $0.isParent &&
            parentIDs.contains($0.id) &&
            !$0.inactive
        }
    }

    
    var overlayView: UIView!
    
    //Search
    private var isSearching = false
    private var searchText = ""
    private var filteredCategories: [ItemCategoryModel] = []


    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        listener = InventoryService.shared.listenToInventoryCategories { [weak self] categories in
            guard let self else { return }

            self.categories = categories.map {
                var c = $0
                c.isExpanded = false
                return c
            }

            self.tableView.reloadData()
        }
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.autocapitalizationType = .none


        setupTableView()
    }

    deinit {
        listener?.remove()
    }

    
//MARK: Table UI
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

    //MARK: Get all SubCategories
    func children(for parent: ItemCategoryModel) -> [ItemCategoryModel] {
        if !isSearching {
            return categories.filter {
                !$0.isParent &&
                $0.parentCategoryRef == parent.id &&
                !$0.inactive
            }
        }

        return filteredCategories.filter {
            $0.parentCategoryRef == parent.id
        }
    }
    
    //MARK: Table: number Of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
            return parentCategories.count
        }
    
    //MARK: Table: number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let parent = parentCategories[section]

        let expanded = isSearching ? true : parent.isExpanded

        return expanded ? children(for: parent).count * 2 + 1 : 0
    }


    //MARK: Table: cell For Row At
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row % 2 == 0 {
            
            // Empty spacer cell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath)
                    cell.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "InventoryCategoryCell",
                for: indexPath
            ) as! InventoryCategoryCell
            
            let childIndex = (indexPath.row - 1) / 2
            let parent = parentCategories[indexPath.section]
            let child = children(for: parent)[childIndex]
            
            cell.textLabel?.text = child.name
            
            return cell
        }
    }

    //MARK: Table: view For Header In Section
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        let parent = parentCategories[section]

        let headerView = UIView()
        headerView.backgroundColor = AppColors.secondary
        headerView.layer.cornerRadius = 8
        headerView.clipsToBounds = true
        headerView.tag = section

        // Title
        let titleLabel = UILabel()
        titleLabel.text = parent.name
        titleLabel.textColor = AppColors.text
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


    //MARK: Table: height For Header In Section
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 44
        }
        
    //MARK: Table: height For Row At
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row % 2 == 0 ? 10:UITableView.automaticDimension
    }
    
    //MARK: Table: height For Footer In Section
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    //MARK: Table: view For Footer In Section
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //MARK: Table: did Select Row At
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
    
    //MARK: toggle section
    @objc private func toggleSection(_ sender: UITapGestureRecognizer) {
        guard !isSearching else { return }

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

        tableView.reloadSections([section], with: .automatic)
    }

    
    //MARK: Apply Search
    func applySearch(_ text: String) {
        searchText = text.lowercased()
        isSearching = !searchText.isEmpty

        if isSearching {
            filteredCategories = categories.filter {
                !$0.isParent &&
                !$0.inactive &&
                $0.name.lowercased().contains(searchText)
            }
        } else {
            filteredCategories.removeAll()
        }

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        applySearch("")
    }

    
   


//MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItemSegue",
           let itemVC = segue.destination as? ItemViewController {
            itemVC.child = selectedChild
            itemVC.title = selectedChild?.name
        }
    }

    
    
    @IBOutlet weak var addView: UIView!
    

    //MARK: Plus Button Clicked
    @IBAction func addCategoryTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Inventory", bundle: nil)
           if let categoryVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController {

               // This enables the "slide up" animation and dimmed background automatically
               categoryVC.modalPresentationStyle = .pageSheet
               categoryVC.parentCategories = self.parentCategories

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
