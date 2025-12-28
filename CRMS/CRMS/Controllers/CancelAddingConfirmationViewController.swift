//
//  CancelAddingConfirmationViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

final class CancelAddingConfirmationViewController: UIViewController {
    
        var onConfirmCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        // Dismiss the popup first
                self.dismiss(animated: true) {
                    // After dismissal is complete, tell the parent to execute the code
                    self.onConfirmCancel?()
        }
    }
}
