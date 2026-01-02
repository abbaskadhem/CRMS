//
//  ItemViewController.swift
//  Inventory
//
//  Created by BP-36-201-11 on 24/12/2025.
//

import UIKit
import FirebaseFirestore

class ItemViewController: UIViewController,
                          UITableViewDelegate,
                          UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    

    var items: [ItemModel] =     []    // filtered for this child
    var child: ItemCategoryModel?        // assigned from previous VC
    var parentID: String = ""
    
    private var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let child else {
            assertionFailure("ItemViewController opened without child")
            return
        }

        title = child.name
        parentID = child.parentCategoryRef ?? ""

        print(child.id)
        
        Task{
            listener = InventoryService.shared.listenToItems() { [weak self]
                items in
                self?.items = items
                print(items)
                self?.tableView.reloadData()
            }
        }
        
        setupTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        listener = nil
    }

    
    //MARK: Add Button
    @IBAction func addButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ShowAddSegue", sender: self)

    }
    
    //MARK: Table UI
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpacerCell")
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

    }
    
    
    //MARK: Table functions: num of sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count * 2 + 1 // first spacer row
    }
    
    //MARK: Table functions: cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseID, for: indexPath) as! ItemCell
            let itemIndex = (indexPath.row - 1) / 2
            let item = items[itemIndex]
            cell.nameLabel.text = item.name
            cell.descriptionLabel.text = item.description
            cell.backgroundColor = .clear
            
            
            return cell
        }
    }
    
    //MARK: Table functions: height for row at
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row % 2 == 0 ? 10 : UITableView.automaticDimension
    }
    
    //MARK: Table functions: did select row at
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row % 2 != 0 else { return }
        let itemIndex = (indexPath.row - 1) / 2
        let item = items[itemIndex]
        print("Selected item: \(item.name)")
        performSegue(withIdentifier: "ShowDetailSegue", sender: item)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue",
               let detailVC = segue.destination as? DetailViewController,
               let item = sender as? ItemModel {
                detailVC.item = item
            }
        
        if segue.identifier == "ShowAddSegue",
           let addVC = segue.destination as? AddItemViewController {
            addVC.categoryID = parentID
            addVC.subcategoryID = child?.id
        }


        
    }

    
}


