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
        showCancelPopup()
    }

    private func createFAQ() async throws {
        let newFaq = FAQ(id:"",question: question ?? "", answer: answer ?? "" )
        try await FaqController.shared.addFaq(newFaq)
    }
    
    private func showCancelPopup() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "CancelAddingConfirmationViewController"
        ) as! CancelAddingConfirmationViewController

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    private func showSuccessAndCloseConfirmation() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let successVC = sb.instantiateViewController(
            withIdentifier: "FAQSuccessViewController"
        ) as! FAQSuccessViewController

        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve

        let presenter = self.presentingViewController  // NewFAQViewController

        dismiss(animated: false) {
            presenter?.present(successVC, animated: true)
        }
    }


}
