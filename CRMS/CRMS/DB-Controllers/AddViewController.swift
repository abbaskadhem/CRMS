//
//  AddViewController.swift
//  CRMS
//
//  Created by BP-36-201-11 on 25/12/2025.
//

import UIKit

class AddViewController: UIViewController {
    
    var parentCategories: [ItemCategoryModel] = []
    var subCategories: [ItemCategoryModel] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

                view.layer.cornerRadius = 16
                view.clipsToBounds = true

                // Example content
                let label = UILabel()
                label.text = "Add"
                label.font = .boldSystemFont(ofSize: 18)
                label.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(label)

                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
                ])
        print("Popover AddViewController!!")
    }
    
    
    @IBAction func addCatTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Inventory", bundle: nil)
            if let categoryVC = storyboard.instantiateViewController(withIdentifier: "AddInventoryCatViewController") as? AddInventoryCatViewController {
                categoryVC.modalPresentationStyle = .pageSheet // or .popover
                categoryVC.sheetPresentationController?.detents = [.medium()] // adjust height
                categoryVC.sheetPresentationController?.prefersGrabberVisible = true
                
                self.present(categoryVC, animated: true)
            }
    }
    
    
    
    @IBAction func addSubCatTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Inventory", bundle: nil)
            if let categoryVC = storyboard.instantiateViewController(withIdentifier: "AddInventorySubCatViewController") as? AddInventorySubCatViewController {
                categoryVC.modalPresentationStyle = .pageSheet // or .popover
                categoryVC.sheetPresentationController?.detents = [.medium()] // adjust height
                categoryVC.sheetPresentationController?.prefersGrabberVisible = true
                if parentCategories.isEmpty {
                    //refetch parents category
                    Task{
                        do{
                            parentCategories = try await InventoryService.shared.getParentCategories()
                            
                            categoryVC.categoriesArray = self.parentCategories

                        }catch{}
                    }
                    
                }else{
                    categoryVC.categoriesArray = self.parentCategories

                }
               

                self.present(categoryVC, animated: true)
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
