//
//  AddInventorySubCatViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 03/01/2026.
//

import UIKit
import FirebaseFirestore

class AddInventorySubCatViewController: UIViewController,
                                        UIPickerViewDelegate,UIPickerViewDataSource {
        
        //MARK: Variables
        var userid:String!
        
        var categoriesArray:[ItemCategoryModel] = []
        var categoryNames:[String] = []
        
        var subCategoriesArray:[ItemCategoryModel] = []
        
        var selectedCategory: ItemCategoryModel = ItemCategoryModel(
            id: "",
         name: "",
         isParent: false,
         parentCategoryRef: "",
         createdOn: Date(),
         createdBy: "",
         modifiedOn: nil,
         modifiedBy: nil,
         inactive: false,
         isExpanded: true
        )
        
        

        //MARK: Outlets
        @IBOutlet weak var subCatTitle: UITextField!
        @IBOutlet weak var categories: UIPickerView!
        
        @IBOutlet weak var subCategoryLabel: UILabel!
        
        @IBOutlet weak var categoryLabel: UILabel!
        
        @IBOutlet var addBtn: UIView!
        
        @IBOutlet weak var stackView: UIStackView!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        userid = SessionManager.shared.currentUserId

        categories.delegate = self
        categories.dataSource = self

        Task {
            do {
                categoriesArray = try await InventoryService.shared.getAllCategories()
                
                categoriesArray = categoriesArray.filter { $0.isParent }

                categoryNames = categoriesArray.map { $0.name }

                if let first = categoriesArray.first {
                    selectedCategory = first
                }

                await MainActor.run {
                    self.categories.reloadAllComponents()
                }

            } catch {
                print("❌ Failed to load categories:", error)
            }
        }

        Task {
            do {
                subCategoriesArray = try await InventoryService.shared.getSubCategories()
            } catch {
                print("❌ Failed to load subcategories:", error)
            }
        }

        configUI()
    }



        
        //MARK: Configure the UI
        func configUI() {
            let label = UILabel()
            label.text = "Add Sub-Category"
            label.font = .boldSystemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)

            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
            ])
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
        }
        
        //MARK: Create Sub Category
        @IBAction func createSubCatTapped(_ sender: Any) {
      
            
            guard let title = subCatTitle.text, !title.isEmpty else {
                   showErrorBanner(title: "Sub-Category title cannot be empty")
                   return
               }

            if subCategoriesArray.contains(where: { $0.name == title && $0.parentCategoryRef == selectedCategory.id}) {
                   showErrorBanner(title: "Sub-Category already exists")
                   return
               }

               showConfirmAddSubCategory(title: title)

        }
        
        private func showConfirmAddSubCategory(title: String) {
            let alert = UIAlertController(
                title: "Confirm Sub-Category",
                message: "Are you sure you want to add \"\(title)\"to \"\(selectedCategory.name)\"?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
                self.createSubCategoryConfirmed(title: title)
            })

            present(alert, animated: true)
        }
        private func createSubCategoryConfirmed(title: String) {

            let categoryRef = selectedCategory.id

            let newCatModel: [String: Any] = [
                "name": title,
                "isParent": false,
                "parentCategoryRef": categoryRef,
                "createdOn": Timestamp(),
                "createdBy": userid ?? "",
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false,
                "isExpanded": false
            ]

            Task {
                do {
                    try await Firestore.firestore()
                        .collection("ItemCategory")
                        .addDocument(data: newCatModel)

                    await MainActor.run {
                        self.showSuccessAndReturn()
                    }
                } catch {
                    await MainActor.run {
                        self.showErrorBanner(title: "Failed to add sub-category")
                    }
                    print("❌ Firestore error:", error)
                }
            }
        }

        
        //MARK: Show Success Message
        private func showSuccessAndReturn() {
            
            //hide all feilds
            subCatTitle.isHidden = true
            subCategoryLabel.isHidden = true
            addBtn.isHidden = true
            categoryLabel.isHidden = true
            categories.isHidden = true
            
            let imageView = UIImageView(image: UIImage(named: "Check circle"))
            
            let lableMessage = UILabel()
            lableMessage.text = "Sub-Category added successfully"
            
            //add to stack view
            imageView.translatesAutoresizingMaskIntoConstraints = false
            lableMessage.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(lableMessage)
            

            // Auto dismiss success, then pop
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true)
            }
        }
        
        //MARK: UIPicker Functions
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return categoryNames.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return categoryNames[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedCategory = categoriesArray[row]
            print("Selected parent category:", selectedCategory.name)
        }


        //MARK: Show Error Banner
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
       

        /*
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

    }
