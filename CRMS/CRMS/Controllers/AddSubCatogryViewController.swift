//
//  AddSubCatogryViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

final class AddSubCatogryViewController: UIViewController {

    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var targetCategoryId: String?
    var categories: [Category] = []
    
    private var selectedCategoryId: String?
    var onSubCategoryAdded: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextView.becomeFirstResponder()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissPopup()
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        let subName = nameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !subName.isEmpty, let categoryId = targetCategoryId else { return }

                sender.isEnabled = false
                let sub = SubCategory(name: subName, isActive: true)

                Task {
                    do {
                        try await CategoryController.shared.addSubCategory(categoryId: categoryId, subCategory: sub)
                        await MainActor.run { [weak self] in
                            self?.onSubCategoryAdded?()
                            self?.dismissPopup()
                        }
                    } catch {
                        await MainActor.run { sender.isEnabled = true }
                        print("❌ Backend Error:", error)
                    }
                }
    }

    private func dismissPopup() {
            if let popup = parent as? DraggablePopupViewController {
                popup.dismiss(animated: true)
            } else {
                dismiss(animated: true)
            }
        }
    
}

