//
//  NewFAQViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class NewFAQViewController: UIViewController {
    
    @IBOutlet weak var answerTextView: InspectableTextView!
    @IBOutlet weak var questionTextView: InspectableTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func showAddConfirmationScreen() {
        let sb = UIStoryboard(name: "Faq", bundle: nil)

        let vc = sb.instantiateViewController(
            withIdentifier: "FAQConfirmationViewController"
        ) as! FAQConfirmationViewController

        vc.answer = answerTextView.text
        vc.question = questionTextView.text

        // --- ADD THIS BLOCK ---
        // When the confirmation screen finishes saving successfully, pop this view controller
        vc.onSaveSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        // ----------------------

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }

    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        view.endEditing(true)
            
            let sb = UIStoryboard(name: "Faq", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "CancelAddingConfirmationViewController") as! CancelAddingConfirmationViewController
            
            // Set the closure here
            vc.onConfirmCancel = { [weak self] in
                // This code runs in the parent after the popup is gone
                self?.navigationController?.popViewController(animated: true)
            }
            
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            
            self.present(vc, animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        showAddConfirmationScreen()
    }
    
 
    
    
}
