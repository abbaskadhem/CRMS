//
//  DeleteSuccessViewController.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import UIKit

class DeleteSuccessViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
        }
    }
}
