//
//  ItemViewController.swift
//  CRMS
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
        
        print(child)
        setupTableView()
        
        allItems = loadSampleItems()
        
            // Filter items
            if let childID = child?.id {
                items = allItems.filter { $0.itemSubcategoryRef == childID }
                print(items)
            }else{
                print("no items found!")
            }
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
    
    
    private func loadSampleItems() -> [ItemModel] {
        // IDs must match your category IDs
        let hardwareID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let licensedID = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!

        let electricalID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let networkingID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let hvacID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

        let items: [ItemModel] = [
            // Hardware Items
            ItemModel(
                id: UUID(),
                name: "Resistor Pack",
                partNo: "R-100",
                unitCost: 0.25,
                vendor: "ElectroGoods",
                itemCategoryRef: hardwareID,
                itemSubcategoryRef: electricalID,
                quantity: 100,
                description: "Assorted resistor pack",
                usage: "Circuit prototyping",
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false
            ),
            ItemModel(
                id: UUID(),
                name: "Ethernet Cable",
                partNo: "NET-50",
                unitCost: 5.0,
                vendor: "NetSupplies",
                itemCategoryRef: hardwareID,
                itemSubcategoryRef: networkingID,
                quantity: 50,
                description: "Cat6 Ethernet cable, 5m",
                usage: "Networking setups",
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false
            ),
            
            // Licensed Items
            ItemModel(
                id: UUID(),
                name: "HVAC Control Software",
                partNo: "HVAC-SW1",
                unitCost: 299.0,
                vendor: "HVAC Corp",
                itemCategoryRef: licensedID,
                itemSubcategoryRef: hvacID,
                quantity: 10,
                description: "Software license for HVAC system control",
                usage: "HVAC system management",
                createdOn: Date(),
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false
            )
        ]
        return items
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count * 2 + 1 // first spacer row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseID, for: indexPath) as! ItemCell
            let itemIndex = (indexPath.row - 1) / 2
            let item = items[itemIndex]
            cell.nameLabel.text = item.name
            cell.descriptionLabel.text = item.description
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
