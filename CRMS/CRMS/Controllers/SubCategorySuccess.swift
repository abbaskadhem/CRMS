//
//  SubCategorySuccess.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//
import UIKit

class SubCategorySuccess: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
        }
    }
}
