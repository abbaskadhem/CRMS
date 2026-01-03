//
//  FAQDetailsViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class FAQDetailsViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var id: String?
    var question: String?
    var answer: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerLabel.text = answer
        questionLabel.text = question
    }
    
    func showConfirmDelete() {
        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConfirmDeleteViewController") as! ConfirmDeleteViewController

        vc.id = id

        vc.onDeleted = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    @IBAction func deleteButtonAction(_ sender: Any) {
        showConfirmDelete()
    }
    
    func handleDelete()async throws{
        do{
            try await FaqController.shared.deleteFaq(withId: id ?? "")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFaqSegue"{
            let vc = segue.destination as! EditFAQViewController
            vc.id = id
            vc.question = question
            vc.answer = answer
        }
    }
    

}
