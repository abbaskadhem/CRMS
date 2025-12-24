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
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    @IBAction func deleteButtonAction(_ sender: Any) {
        
    }
    

}
