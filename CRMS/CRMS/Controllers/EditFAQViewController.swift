//
//  EditFAQViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class EditFAQViewController: UIViewController {

    @IBOutlet weak var questionTextView: InspectableTextView!
    @IBOutlet weak var answerTextView: InspectableTextView!
    
    var id:String?
    var question:String?
    var answer:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextView.text = question
        answerTextView.text = answer
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        showConfirmEditAlert()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
    }
    
    func showConfirmEditAlert() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "ConfirmEditAlertViewController"
        ) as! ConfirmEditAlertViewController
        
        vc.id = self.id
        vc.question = questionTextView.text
        vc.answer = answerTextView.text


        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)

    }

}
