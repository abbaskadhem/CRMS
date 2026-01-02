//
//  AddItemViewController.swift
//  Inventory
//
//  Created by Reem Janahi on 28/12/2025.
//

import UIKit
import FirebaseFirestore

class AddItemViewController: UIViewController,
                             UITableViewDataSource,
                             UITableViewDelegate{
    
    

    @IBOutlet weak var tableView: UITableView!
    
   var existingItems: [ItemModel] = []
    
    var currentUserID = SessionManager.shared.currentUserId!
    
    var categoryID: String?
    var subcategoryID: String?
    
    private var listener: ListenerRegistration?
    
    override func viewWillAppear(_ animated: Bool) {
        listener = InventoryService.shared.listenToItems(
        ) { [weak self] items in
            self?.existingItems = items
            self?.tableView.reloadData()
        }
    }

     override func viewDidLoad() {
         super.viewDidLoad()
         tableView.allowsSelection = false

         let saveButton = UIBarButtonItem(
             image: UIImage(systemName: "checkmark"),
             style: .done,
             target: self,
             action: #selector(editItem)
         )

         let cancelButton = UIBarButtonItem(
             barButtonSystemItem: .cancel,
             target: self,
             action: #selector(cancelEdit)
         )

         navigationItem.rightBarButtonItems = [cancelButton, saveButton]
       
         
         title = "Create Item"
                tableView.delegate = self
                tableView.dataSource = self

         tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.reuseID)
         
         tableView.register(TextAreaCell.self, forCellReuseIdentifier: TextAreaCell.reuseID)


         
         tableView.estimatedRowHeight = 120

           
     }
    
    

    
     
    private var isEditingItem = false
    private var draftItem: ItemModel?
    private var confirmationOverlay: UIView?
    private var successOverlay: UIView?


    
    //MARK: Edit Button
    @objc private func editItem() {
        showConfirmationOverlay("Are you sure you want to save the edits?", "edit")
    }


    //MARK: cancel the edit
    @objc private func cancelEdit() {
        showConfirmationOverlay("Are you sure you want to cancel the edits?", "cancel")
    }
  

     //MARK: conformation overlay
    private func showConfirmationOverlay(_ givenMessage:String, _ type:String) {
         let overlay = UIView(frame: view.bounds)
         overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
         overlay.alpha = 0

         //background
         let card = UIView()
         card.backgroundColor = .white
         card.layer.cornerRadius = 14
         card.translatesAutoresizingMaskIntoConstraints = false

         //Title
         let title = UILabel()
         title.text = "Confirmation"
         title.font = .boldSystemFont(ofSize: 20)
         title.textAlignment = .center

         //message
         let message = UILabel()
         message.text = givenMessage
         message.font = .systemFont(ofSize: 15)
         message.textAlignment = .center
         message.numberOfLines = 0

         //cancel
         let noButton = UIButton(type: .system)
         noButton.setTitle("No", for: .normal)
         noButton.layer.cornerRadius = 8
         noButton.layer.borderWidth = 1
         noButton.layer.borderColor = UIColor.systemGray4.cgColor
         noButton.addTarget(self, action: #selector(cancelSaveTapped), for: .touchUpInside)

         //confirm
         let yesButton = UIButton(type: .system)
         yesButton.setTitle("Yes, I'm sure", for: .normal)
         yesButton.backgroundColor = AppColors.primary
         yesButton.setTitleColor(.white, for: .normal)
         yesButton.layer.cornerRadius = 8
        
        if type == "edit"{
            yesButton.addTarget(self, action: #selector(confirmSaveTapped), for: .touchUpInside)
        }else if type == "cancel"{
            self.navigationController?.popViewController(animated: true)
        }
        
         let buttons = UIStackView(arrangedSubviews: [noButton, yesButton])
         buttons.axis = .horizontal
         buttons.spacing = 12
         buttons.distribution = .fillEqually

         let stack = UIStackView(arrangedSubviews: [title, message, buttons])
         stack.axis = .vertical
         stack.spacing = 16
         stack.translatesAutoresizingMaskIntoConstraints = false

         card.addSubview(stack)
         overlay.addSubview(card)
         view.addSubview(overlay)

         NSLayoutConstraint.activate([
             card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
             card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
             card.widthAnchor.constraint(equalToConstant: 280),

             stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
             stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
             stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
             stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
         ])

         confirmationOverlay = overlay

         UIView.animate(withDuration: 0.25) {
             overlay.alpha = 1
         }
     }
     
     //MARK: succsess overlay
     private func showSuccessOverlay() {
         let overlay = UIView(frame: view.bounds)
         overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
         overlay.alpha = 0

         let container = UIView()
         container.backgroundColor = .white
         container.layer.cornerRadius = 16
         container.translatesAutoresizingMaskIntoConstraints = false

         let check = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
         check.tintColor = AppColors.primary
         check.contentMode = .scaleAspectFit
         check.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

         let label = UILabel()
         label.text = "Item Details Saved Successfully"
         label.font = .boldSystemFont(ofSize: 16)
         label.textAlignment = .center
         label.numberOfLines = 2

         let stack = UIStackView(arrangedSubviews: [check, label])
         stack.axis = .vertical
         stack.spacing = 12
         stack.translatesAutoresizingMaskIntoConstraints = false

         container.addSubview(stack)
         overlay.addSubview(container)
         view.addSubview(overlay)

         NSLayoutConstraint.activate([
             container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
             container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
             container.widthAnchor.constraint(equalToConstant: 260),

             check.heightAnchor.constraint(equalToConstant: 60),

             stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
             stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
             stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
             stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
         ])

         successOverlay = overlay

         UIView.animate(withDuration: 0.25) {
             overlay.alpha = 1
             check.transform = .identity
         }

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
             self.dismissSuccessOverlay()
         }
     }

     //MARK: remove overlay
     private func dismissSuccessOverlay() {
         UIView.animate(withDuration: 0.25, animations: {
             self.successOverlay?.alpha = 0
         }) { _ in
             self.successOverlay?.removeFromSuperview()
             self.successOverlay = nil
         }
     }

     //MARK: conformation cancel
     @objc private func cancelSaveTapped() {
         dismissConfirmationOverlay()
     }
     
 //MARK: conformation save
     @objc private func confirmSaveTapped() {
         dismissConfirmationOverlay()
         commitAndExitEditMode()
         showSuccessOverlay()
     }

     //MARK: overlay dissmissal
     private func dismissConfirmationOverlay() {
         UIView.animate(withDuration: 0.2, animations: {
             self.confirmationOverlay?.alpha = 0
         }) { _ in
             self.confirmationOverlay?.removeFromSuperview()
             self.confirmationOverlay = nil
         }
     }


     //MARK: saved
     private func commitAndExitEditMode() {
         commitChanges()
         isEditingItem = false
         draftItem = nil
     }

     //MARK: commit changes once saved
    private func commitChanges() {

        guard
            let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InfoCell,
            let partNoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InfoCell,
            let unitCostCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? InfoCell,
            let vendorCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? InfoCell,
            let quantityCell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? InfoCell,
            let descriptionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TextAreaCell,
            let usageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? TextAreaCell
        else {
            showErrorBanner(title: "Unexpected form error")
            return
        }

        let name = nameCell.currentValue()
        if name.isEmpty {
            showErrorBanner(title: "Name Cannot be empty")
            return
        }
        let partNo = partNoCell.currentValue()
        if partNo.isEmpty {
            showErrorBanner(title: "Part Number Cannot be empty")
            return
        }
        let unitCostString = unitCostCell.currentValue()
        guard let unitCost = Double(unitCostString) else {
            showErrorBanner(title: "Unit Cost Cannot be empty")
            return
        }
        let quantityString = quantityCell.currentValue()
        guard let quantity = Int(quantityString) else {
            showErrorBanner(title: "Quantity Cannot be empty")
            return
        }
        let vendor = vendorCell.currentValue()
        if vendor.isEmpty {
            showErrorBanner(title: "Vendor Cannot be empty")
            return
        }
        let description = descriptionCell.textView.text!
        if description.isEmpty {
            showErrorBanner(title: "Description Cannot be empty")
            return
        }
        let usage = usageCell.textView.text!
        if usage.isEmpty {
            showErrorBanner(title: "Usage Cannot be empty")
            return
        }

        if existingItems.filter({$0.partNo == partNoCell.currentValue()}).count > 0 {
            showErrorBanner(title: "Part already exists")
            return
        }

        let itemID = UUID().uuidString

        let payload: [String: Any?] = [
            "id": itemID,
            "name": name,
            "partNo": partNo,
            "unitCost": unitCost,
            "vendor": vendor,
            "itemCategoryRef": categoryID ,
            "itemSubcategoryRef": subcategoryID ,
            "quantity": quantity,
            "description": description,
            "usage": usage,
            "createdOn": Timestamp(),
            "createdBy": currentUserID,
            "modifiedOn": nil,
            "modifiedBy": nil,
            "inactive": false
        ]

        Task {
            do {
                let ref = Firestore.firestore().collection("Item")
                
                
                
                try await ref.document(itemID).setData(payload as [String : Any])
                
                
              
                    
                    self.navigationController?.popViewController(animated: true)
                
                
            } catch {
                await MainActor.run {
                    showErrorBanner(title: "Failed to save item")
                }
                print("❌ Firestore error:", error)
            }
            
        }
        
        //MARK: Error Banner
        func showErrorBanner(title: String) {
            let banner = UIView()
            banner.backgroundColor = AppColors.secondary
            banner.layer.cornerRadius = 12
            banner.alpha = 0

            let label = UILabel()
            label.text = "\(title)"
            label.numberOfLines = 1
            label.textColor = .white

            banner.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            banner.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12),
                label.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -12),
            ])

            guard
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first(where: { $0.isKeyWindow })
            else { return }
            window.addSubview(banner)

            NSLayoutConstraint.activate([
                banner.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 12),
                banner.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 12),
                banner.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -12)
            ])

            UIView.animate(withDuration: 0.2) {
                banner.alpha = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                UIView.animate(withDuration: 0.2, animations: {
                    banner.alpha = 0
                }) { _ in
                    banner.removeFromSuperview()
                }
            }
        }

}

            
            //MARK: Sections: num of sec
            func numberOfSections(in tableView: UITableView) -> Int {
                return 3
            }
            
            //MARK:    headers
            func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                switch section {
                case 1: return "Details"
                default: return nil
                }
            }
            
        //MARK: heightForHeaderInSection
            func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 40 // or whatever height you want
            }
    //MARK: viewForHeaderInSection
            func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                // Create container view
                let headerView = UIView()
                headerView.backgroundColor = .clear // your header background
                
                // Create label
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = .boldSystemFont(ofSize: 16)
                headerView.tintColor = AppColors.secondary
                label.textColor = AppColors.primary // your text color
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
                bottomBorder.backgroundColor = AppColors.primary// border color
                headerView.addSubview(bottomBorder)
                
                NSLayoutConstraint.activate([
                    bottomBorder.heightAnchor.constraint(equalToConstant: 0.5),
                    bottomBorder.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                    bottomBorder.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                    bottomBorder.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
                ])
                
                return headerView
            }
            
            //MARK: Table functions: num of rows in section
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                switch section {
                case 0: return 5  // Info cells
                case 1: return 1  // Description
                case 2: return 1  // Usage
                default: return 0
                }
            }
            
    //MARK: Table functions: cell for row at
            func tableView(_ tableView: UITableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
                switch indexPath.section {
                    
                    
                    
                    
                case 0:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: InfoCell.reuseID,
                        for: indexPath
                    ) as! InfoCell
                    
                    let value = ""
                    
                    switch indexPath.row {
                    case 0:
                        cell.configure(title: "Name", value: value)
                        cell.textField.placeholder = "Enter item name"

                    case 1:
                        cell.configure(title: "Part Number", value: value)
                        cell.textField.placeholder = "Enter part number"

                    case 2:
                        cell.configure(title: "Unit Cost", value: value)
                        cell.textField.keyboardType = .decimalPad
                        cell.textField.placeholder = "0.00"

                    case 3:
                        cell.configure(title: "Vendor", value: value)
                        cell.textField.placeholder = "Vendor name"

                    case 4:
                        cell.configure(title: "Quantity in Stock", value: value)
                        cell.textField.keyboardType = .numberPad
                        cell.textField.placeholder = "0"

                    default:
                        break
                    }
                    
                    cell.titleLabel.textColor = AppColors.primary
                    cell.layer.borderWidth = 0.5
                    cell.layer.borderColor = UIColor.black.cgColor
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    cell.setEditable(true)
                    
                    
                    return cell
                    
                    
                    
                case 1:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: TextAreaCell.reuseID,
                        for: indexPath
                    ) as! TextAreaCell
                    
                    cell.configure(title: "Description", text: "", placeholder: "Add description here...")
                    cell.titleLabel.textColor = AppColors.primary
                    cell.layer.borderWidth = 0.5
                    cell.layer.borderColor = UIColor.black.cgColor
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    cell.setEditable(true)
                    return cell
                    
                    
                case 2:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: TextAreaCell.reuseID,
                        for: indexPath
                    ) as! TextAreaCell
                    
                    cell.configure(title: "Usage", text: "", placeholder: "Add usage here...")
                    cell.titleLabel.textColor = AppColors.primary
                    cell.layer.borderWidth = 0.5
                    cell.layer.borderColor = UIColor.black.cgColor
                    cell.selectionStyle = .none
                    cell.backgroundColor = .clear
                    cell.setEditable(true)
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
