//
//  ConfirmEditAlertViewController.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import UIKit

final class ConfirmEditAlertViewController: UIViewController {

    var id: String?
    var question: String?
    var answer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    @IBAction func saveButton(_ sender: UIButton) {
        sender.isEnabled = false

        guard let id = id, !id.isEmpty else {
            sender.isEnabled = true
            return
        }

        let q = question ?? ""
        let a = answer ?? ""

        Task {
            do {
                try await FaqController.shared.editFaq(faq: FAQ(id: id, question: q, answer: a))

                await MainActor.run { [weak self] in
                    self?.showSuccessAndClose()
                }

            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("Edit failed:", error)
            }
        }
    }



    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func showSuccessAndClose() {
        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let successVC = sb.instantiateViewController(
            withIdentifier: "FAQEditSuccessViewController"
        ) as! FAQEditSuccessViewController

        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve

        let presenter = presentingViewController

        dismiss(animated: false) {
            presenter?.present(successVC, animated: true)
        }
    }

}


