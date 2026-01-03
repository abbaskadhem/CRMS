//
//  AddInventoryCatViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 03/01/2026.
//

import UIKit
import FirebaseFirestore

class AddInventoryCatViewController: UIViewController {
    var userid:String!
    
    var categoriesArray: [ItemCategoryModel] = []
    
    
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var catTitle: UITextField!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userid = SessionManager.shared.currentUserId
        Task{
            do{
                categoriesArray = try await InventoryService.shared.getParentCategories()
                
            }catch{
                print("❌ Failed to load categories:", error)
            }
        }
        configUI()
        
        print("Popover AddInventoryCatViewController!!")
    }
    
    //MARK: Configure the UI
    func configUI() {
        let label = UILabel()
        label.text = "Add Category"
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
    
    //MARK: Create Category
    @IBAction func addCatTapped(_ sender: Any) {
        guard let title = catTitle.text, !title.isEmpty else {
            showErrorBanner(title: "Category title connot be empty")
            return }
        
           if categoriesArray.contains(where: { $0.name == title }) {
               showErrorBanner(title: "Category already exists")
               return }

           let newCatModel: [String: Any] = [
               "name": title,
               "isParent": true,
               "parentCategoryRef": NSNull(),
               "createdOn": Timestamp(),
               "createdBy": userid ?? "",
               "modifiedOn": NSNull(),
               "modifiedBy": NSNull(),
               "inactive": false,
               "isExpanded": true
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
                   print("❌ Failed to add category:", error)
               }
           }
    }
    
    
    //MARK: Show Success Message
    private func showSuccessAndReturn() {
        
        //hide all feilds
        catTitle.isHidden = true
        addBtn.isHidden = true
        categoryLabel.isHidden = true
        
        let imageView = UIImageView(image: UIImage(named: "Check circle"))
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true

        
        let lableMessage = UILabel()
        lableMessage.text = "Category added successfully"
        
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
