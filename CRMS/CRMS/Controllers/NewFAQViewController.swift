//
//  NewFAQViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class NewFAQViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func showAddConfirmationScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = sb.instantiateViewController(
            withIdentifier: "FAQConfirmationViewController"
        ) as! FAQConfirmationViewController
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        vc.view.insertSubview(blur, at: 0)
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        showAddConfirmationScreen()
    }
    
}
