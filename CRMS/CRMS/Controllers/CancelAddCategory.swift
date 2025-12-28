//
//  CancelAddCategory.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import UIKit
class CancelAddCategory: UIViewController {
    
    var name:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    
    @IBAction func yesButtonTapped(_ sender: Any) {

        guard let presentingVC = self.presentingViewController else {
            self.dismiss(animated: true)
            return
        }

        self.dismiss(animated: false) {
        
            if let popup = presentingVC as? DraggablePopupViewController {
                popup.dismissPopup()
            } else if let popup = presentingVC.parent as? DraggablePopupViewController {
                popup.dismissPopup()
            } else {
                presentingVC.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)

    }
    
}
