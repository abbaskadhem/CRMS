//
//  ConfirmDeleteViewController.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import UIKit

final class ConfirmDeleteViewController: UIViewController {

    var id: String?
    var onDeleted: (() -> Void)?   // optional: let the list refresh
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("cancel")
        dismiss(animated: true)
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        print("confirm")
        sender.isEnabled = false

        guard let id = id, !id.isEmpty else {
            print("❌ Cannot delete: FAQ id is missing")
            sender.isEnabled = true
            return
        }

        Task {
            do {
                try await FaqController.shared.deleteFaq(withId: id)

                await MainActor.run { [weak self] in
                    self?.onDeleted?()
                    self?.showDeleteSuccessAndClose()
                }
            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("Delete failed:", error)
            }
        }
    }

    private func showDeleteSuccessAndClose() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let raw = sb.instantiateViewController(withIdentifier: "DeleteSuccessViewController")
        print("Loaded type:", type(of: raw))

        let successVC = sb.instantiateViewController(
            withIdentifier: "DeleteSuccessViewController"
        ) as! DeleteSuccessViewController

        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve

        let presenter = presentingViewController

        dismiss(animated: false) {
            presenter?.present(successVC, animated: true)
        }
    }
}

