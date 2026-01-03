//
//  FAQConfirmationViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

final class FAQConfirmationViewController: UIViewController {

    var question: String?
    var answer: String?
    var onSaveSuccess: (() -> Void)?
    
    @IBOutlet weak var yesButton: UIButton?
    @IBOutlet weak var noButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    @IBAction func yesTapped(_ sender: Any) {
        yesButton?.isEnabled = false
        noButton?.isEnabled = false

        Task {
            do {
                try await createFAQ()
                await MainActor.run { [weak self] in
                    self?.showSuccessAndCloseConfirmation()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.yesButton?.isEnabled = true
                    self?.noButton?.isEnabled = true
                }
                print("Failed to create FAQ:", error)
            }
        }
    }

    @IBAction func noTapped(_ sender: Any) {
       dismiss(animated: true)
    }

    private func createFAQ() async throws {
        let newFaq = FAQ(id:"",question: question ?? "", answer: answer ?? "" )
        try await FaqController.shared.addFaq(newFaq)
    }
 
    
    private func showSuccessAndCloseConfirmation() {
            let sb = UIStoryboard(name: "Faq", bundle: nil)
            let successVC = sb.instantiateViewController(
                withIdentifier: "FAQSuccessViewController"
            ) as! FAQSuccessViewController

            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve

            // Capture the NewFAQViewController
            let presenter = self.presentingViewController

            dismiss(animated: false) {
                // Tell the parent the save was successful before showing success screen
                self.onSaveSuccess?()
                presenter?.present(successVC, animated: true)
            }
        }
    

}
