//
//  CancelAddingConfirmationViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class CancelAddingConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        removeAllConfirmationScreens()
      }
      
      @IBAction func yesButtonTapped(_ sender: UIButton) {
          removeAllConfirmationScreens()
      }
      

    private func removeAllConfirmationScreens() {
            var targetVC: UIViewController? = self.parent
            
            while targetVC != nil {
                if targetVC is NewFAQViewController {
                    break
                }
                targetVC = targetVC?.parent
            }
            
            guard let newFAQVC = targetVC else { return }
            
            for child in newFAQVC.children {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
}
