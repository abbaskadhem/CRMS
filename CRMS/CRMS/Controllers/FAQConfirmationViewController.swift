//
//  FAQConfirmationViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit


class FAQConfirmationViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    private func removeFromParentAndShowSuccess() {

        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = sb.instantiateViewController(
            withIdentifier: "FAQSuccessViewController"
        ) as! FAQSuccessViewController
  
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    private func removeFromParentAndShowCancelConfirmation() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = sb.instantiateViewController(
            withIdentifier: "CancelAddingConfirmationViewController"
        ) as! CancelAddingConfirmationViewController
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        vc.view.insertSubview(blur, at: 0)
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)

    }
    
    @IBAction func yesTapped(_ sender: Any) {
        removeFromParentAndShowSuccess()
        print("dsfsd")
    }
    
    @IBAction func noTapped(_ sender: Any) {
        print("dsfsdfdfddf")
        removeFromParentAndShowCancelConfirmation()
    }
    
}
