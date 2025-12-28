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
        let sb = UIStoryboard(name: "Main", bundle: nil)

        let vc = sb.instantiateViewController(
            withIdentifier: "FAQConfirmationViewController"
        ) as! FAQConfirmationViewController

        vc.answer = answerTextView.text
        vc.question = questionTextView.text

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }

    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        showAddConfirmationScreen()
    }
    
    
    
}
