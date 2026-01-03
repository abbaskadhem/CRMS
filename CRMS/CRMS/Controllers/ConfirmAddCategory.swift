//
//  ConfirmAddCategory.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import UIKit

class ConfirmAddCategory: UIViewController {
    
    var name:String?
    var onCategoryAdded: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false

        let name = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            sender.isEnabled = true
            return
        }

        Task {
            do {
                try await CategoryController.shared.addCategory(name: name)

                await MainActor.run { [weak self] in
                    self?.showSuccessThenCloseAll()
                }

            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("❌ add category failed:", error)
            }
        }
    }
    
    @IBAction func cancelbuttonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func showSuccessThenCloseAll() {
            let sb = UIStoryboard(name: "Faq", bundle: nil)
            let successVC = sb.instantiateViewController(
                withIdentifier: "CategoryAddSuccess"
            ) as! CategoryAddSuccess

            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve

            let addVC = presentingViewController

            dismiss(animated: false) {
                if let add = addVC,
                   let popup = add.parent as? DraggablePopupViewController {

                    popup.dismiss(animated: false) {
                        self.onCategoryAdded?()

                        popup.presentingViewController?.present(successVC, animated: true)
                    }
                } else {
                    self.onCategoryAdded?()
                    addVC?.present(successVC, animated: true)
                }
            }
        }

}
