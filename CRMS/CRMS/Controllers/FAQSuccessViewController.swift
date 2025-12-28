//
//  FAQSuccessViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

 class FAQSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}

