//
//  AddCatogryViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class AddCatogryViewController: UIViewController {
    
    var onCategoryAdded: (() -> Void)?
    
    @IBOutlet weak var nameTextView: InspectableTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let name = nameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let confirmVC = sb.instantiateViewController(
            withIdentifier: "ConfirmAddCategory"
            )as! ConfirmAddCategory

        confirmVC.name = name

        confirmVC.onCategoryAdded = onCategoryAdded

        confirmVC.modalPresentationStyle = .overFullScreen
        confirmVC.modalTransitionStyle = .crossDissolve
        present(confirmVC, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CancelAddCategory") as! CancelAddCategory

          vc.modalPresentationStyle = .overFullScreen
          vc.modalTransitionStyle = .crossDissolve

          present(vc, animated: true)
    }
    
}
