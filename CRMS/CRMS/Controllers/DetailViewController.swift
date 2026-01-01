//
//  DetailViewController.swift
//  Inventory
//
//  Created by BP-36-201-11 on 25/12/2025.
//

import UIKit

class DetailViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate{
    var item: ItemModel!

    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: EditItemDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

       
        let editButton = UIBarButtonItem(
            image:   UIImage(named: "Edit"),
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
    
    private var isEditingItem = false
    private var draftItem: ItemModel?
    private var confirmationOverlay: UIView?
    private var successOverlay: UIView?



    
// make everything editable
    @objc private func editItem() {
        if isEditingItem {
            showConfirmationOverlay()
        } else {
            isEditingItem = true
            draftItem = item
            showEditButtons()
            tableView.reloadData()
        }
    }

    //cancel the edit
    @objc private func cancelEdit() {
        isEditingItem = false
        draftItem = nil
        hideEditButtons()
        tableView.reloadData()
    }

    // conformation overlay
    private func showConfirmationOverlay() {
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
        message.text = "Are you sure you want to save the edits?"
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
        yesButton.addTarget(self, action: #selector(confirmSaveTapped), for: .touchUpInside)

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
    
    //succsess overlay
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

    //remove overlay
    private func dismissSuccessOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.successOverlay?.alpha = 0
        }) { _ in
            self.successOverlay?.removeFromSuperview()
            self.successOverlay = nil
        }
    }

// In edit mode : save / cancel buttons
    private func showEditButtons() {
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
    }
    
    
    // to hide edit and delete once inside edit mode
    private func hideEditButtons() {
        let editButton = UIBarButtonItem(
            image: UIImage(named: "Edit"),
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
    }

    // conformation cancel
    @objc private func cancelSaveTapped() {
        dismissConfirmationOverlay()
    }
    
//conformation save
    @objc private func confirmSaveTapped() {
        dismissConfirmationOverlay()
        commitAndExitEditMode()
        showSuccessOverlay()
    }

    //overlay dissmissal
    private func dismissConfirmationOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.confirmationOverlay?.alpha = 0
        }) { _ in
            self.confirmationOverlay?.removeFromSuperview()
            self.confirmationOverlay = nil
        }
    }


    //saved
    private func commitAndExitEditMode() {
        commitChanges()
        delegate?.didEditItem(item)
        isEditingItem = false
        draftItem = nil
        hideEditButtons()
        tableView.reloadData()
    }

    //commit changes once saved
    private func commitChanges() {
        guard var draft = draftItem else { return }

        for cell in tableView.visibleCells {
            if let infoCell = cell as? InfoCell {
                switch infoCell.titleLabel.text {
                case "Name":
                    draft.name = infoCell.currentValue()
                case "Part Number":
                    draft.partNo = infoCell.currentValue()
                case "Unit Cost":
                    let raw = infoCell.currentValue()
                        .replacingOccurrences(of: " BHD", with: "")
                    draft.unitCost = Double(raw)

                case "Vendor":
                    draft.vendor = infoCell.currentValue()
                case "Quantity in Stock":
                    draft.quantity = Int(infoCell.currentValue())
                default:
                    break
                }
            }

            if let textCell = cell as? TextAreaCell {
                switch textCell.titleLabel.text {
                case "Description":
                    draft.description = textCell.textView.text
                case "Usage":
                    draft.usage = textCell.textView.text
                default:
                    break
                }
            }
        }

        item = draft
    }

    //delete the whole item
    @objc private func deleteItem() {
        print("Delete \(item.name)")
    }


    func numberOfSections(in tableView: UITableView) -> Int {
          return 3
      }
    
//    headers
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
        headerView.tintColor = AppColors.secondary
        label.textColor = AppColors.text // your text color
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
        bottomBorder.backgroundColor = AppColors.primary // border color
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

          let source = isEditingItem ? draftItem! : item


          switch indexPath.section {


          
              
          case 0:
              let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.reuseID, for: indexPath) as! InfoCell

              switch indexPath.row {
              case 0: cell.configure(title: "Name", value: source?.name ?? "empty")
              case 1: cell.configure(title: "Part Number", value: source?.partNo ?? "empty")
              case 2: cell.configure(title: "Unit Cost", value: "\(source?.unitCost ?? 0) BHD")
              case 3: cell.configure(title: "Vendor", value: source?.vendor ?? "empty")
              case 4: cell.configure(title: "Quantity in Stock", value: "\(source?.quantity ?? 0)")
              default: break
              }

              cell.backgroundColor = .clear
              cell.selectionStyle = .none
              cell.titleLabel.textColor = AppColors.primary
              cell.setEditable(isEditingItem)
              return cell


          case 1:
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: "TextAreaCell",
                  for: indexPath
              ) as! TextAreaCell

              cell.configure(title: "Description", text: source?.description ?? "empty")

              cell.setEditable(isEditingItem)
              cell.titleLabel.textColor = AppColors.primary
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

              cell.configure(title: "Usage", text: source?.usage ?? "empty")
              cell.setEditable(isEditingItem)
              cell.titleLabel.textColor = AppColors.primary
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

protocol EditItemDelegate: AnyObject {
    func didEditItem(_ item: ItemModel)
}
