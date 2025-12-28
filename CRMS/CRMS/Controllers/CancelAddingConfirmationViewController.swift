//
//  CancelAddingConfirmationViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

final class CancelAddingConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    // NO = keep adding (close only this popup)
    @IBAction func noButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // YES = cancel adding (close this popup, then close the confirmation behind it)
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.presentingViewController?.dismiss(animated: true)
        }
    }
}
