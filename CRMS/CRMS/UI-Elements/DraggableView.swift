//
//  DraggableView.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

/// A view controller that presents content in a draggable popup sheet with blur background
final class DraggablePopupViewController: UIViewController, UIGestureRecognizerDelegate {

    private let contentVC: UIViewController
    private let popupHeight: CGFloat
    private var originalY: CGFloat = 0

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: nil)
        return view
    }()

    init(contentVC: UIViewController, height: CGFloat = UIScreen.main.bounds.height * 0.7) {
        self.contentVC = contentVC
        self.popupHeight = height
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPanGesture()
        setupBackgroundTap()
        setupKeyboardObservers()
    }

    private func setupUI() {
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)

        view.backgroundColor = .clear

        addChild(contentVC)
        view.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)

        contentVC.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: popupHeight)
        originalY = view.frame.height - popupHeight
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        UIView.animate(withDuration: AppAnimation.standard) {
            // Adjust the popup to sit right above the keyboard
            self.contentVC.view.frame.origin.y = self.view.frame.height - self.popupHeight - keyboardHeight + 100
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: AppAnimation.standard) {
            self.contentVC.view.frame.origin.y = self.originalY
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if gesture.state == .changed {
            let newY = contentVC.view.frame.origin.y + translation.y
            if newY >= originalY {
                contentVC.view.frame.origin.y = newY
            }
            gesture.setTranslation(.zero, in: view)
        } else if gesture.state == .ended {
            let draggedDistance = contentVC.view.frame.origin.y - originalY
            if draggedDistance > (popupHeight * 0.3) { dismissPopup() } else { snapBack() }
        }
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        if !contentVC.view.frame.contains(gesture.location(in: view)) {
            contentVC.view.endEditing(true)
            dismissPopup()
        }
    }

    /// Animates the popup into view
    func presentPopup() {
        UIView.animate(withDuration: AppAnimation.standard) {
            self.blurEffectView.effect = UIBlurEffect(style: .systemThinMaterialDark)
            self.contentVC.view.frame.origin.y = self.originalY
        }
    }

    /// Animates the popup out of view and dismisses
    func dismissPopup() {
        UIView.animate(withDuration: AppAnimation.standard, animations: {
            self.blurEffectView.effect = nil
            self.contentVC.view.frame.origin.y = self.view.frame.height
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    private func snapBack() {
        UIView.animate(withDuration: AppAnimation.quick) {
            self.contentVC.view.frame.origin.y = self.originalY
        }
    }

    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        contentVC.view.addGestureRecognizer(pan)
    }

    private func setupBackgroundTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
