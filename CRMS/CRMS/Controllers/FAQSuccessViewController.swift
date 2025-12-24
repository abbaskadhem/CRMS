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

        removeAfterDelay()
    }
    
    private func removeAfterDelay() {
           DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
               self.removeFromParentScreen()
           }
       }
       
       private func removeFromParentScreen() {
           willMove(toParent: nil)
           view.removeFromSuperview()
           removeFromParent()
       }
}
