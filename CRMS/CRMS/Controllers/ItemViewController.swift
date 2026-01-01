//
//  ItemViewController.swift
//  Inventory
//
//  Created by BP-36-201-11 on 24/12/2025.
//

import UIKit

class ItemViewController: UIViewController,
                          UITableViewDelegate,
                          UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allItems: [ItemModel] = []       // full items list
        var items: [ItemModel] = []          // filtered for this child
        var child: ItemCategoryModel?        // assigned from previous VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        title = child?.name
        
        print(child!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,   // + icon
                target: self,
                action: #selector(addButtonTapped)
            )
        
        navigationItem.rightBarButtonItem?.tintColor = AppColors.primary
        navigationController?.navigationBar.tintColor = AppColors.primary

        setupTableView()
        
//        allItems = loadSampleItems()
        
//            // Filter items
//            if let childID = child?.id {
//                items = allItems.filter { $0.itemSubcategoryRef == childID }
//                print(items)
//            }else{
//                print("no items found!")
//            }
        }
    
    @objc private func addButtonTapped() {
        performSegue(withIdentifier: "ShowAddSegue", sender: self)
    }
    
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpacerCell")
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count * 2 + 1 // first spacer row
    }
    
    // cell
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row % 2 == 0 ? 10 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row % 2 != 0 else { return }
        let itemIndex = (indexPath.row - 1) / 2
        let item = items[itemIndex]
        print("Selected item: \(item.name)")
        performSegue(withIdentifier: "ShowDetailSegue", sender: item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue",
               let detailVC = segue.destination as? DetailViewController,
               let item = sender as? ItemModel {

                detailVC.item = item
                detailVC.delegate = self
            }
        if segue.identifier == "ShowAddSegue",
           let addVC = segue.destination as? AddItemViewController {
            addVC.delegate = self
//            addVC.categoryID = child?.parentCategoryRef
//            addVC.subcategoryID = child?.id
        }

        
        
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

extension ItemViewController: AddItemDelegate {
    func didCreateItem(_ item: ItemModel) {
        items.append(item)
        tableView.reloadData()
    }
}

extension ItemViewController: EditItemDelegate {
    func didEditItem(_ item: ItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            tableView.reloadData()
        }
    }
}
