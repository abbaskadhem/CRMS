//
//  DraggbleView.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

final class DraggablePopupViewController: UIViewController {

    // MARK: - Properties

    private let contentVC: UIViewController
    private let popupHeight: CGFloat

    private var originalY: CGFloat = 0

    // MARK: - Init

    init(
        contentVC: UIViewController,
        height: CGFloat = UIScreen.main.bounds.height * 0.7
    ) {
        self.contentVC = contentVC
        self.popupHeight = height
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPanGesture()
        setupBackgroundTap()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        addChild(contentVC)
        view.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)

        contentVC.view.frame = CGRect(
            x: 0,
            y: view.frame.height,
            width: view.frame.width,
            height: popupHeight
        )

        contentVC.view.layer.cornerRadius = 20
        contentVC.view.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        contentVC.view.clipsToBounds = true

        originalY = view.frame.height - popupHeight
    }

    // MARK: - Gestures

    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        contentVC.view.addGestureRecognizer(pan)
    }

    private func setupBackgroundTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundTapped(_:))
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            let newY = contentVC.view.frame.origin.y + translation.y
            if newY >= originalY {
                contentVC.view.frame.origin.y = newY
            }
            gesture.setTranslation(.zero, in: view)

        case .ended:
            let velocity = gesture.velocity(in: view).y
            velocity > 1000 ? dismissPopup() : snapBack()

        default:
            break
        }
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)

        if !contentVC.view.frame.contains(location) {
            dismissPopup()
        }
    }

    // MARK: - Presentation

    func presentPopup() {
        UIView.animate(withDuration: 0.3) {
            self.contentVC.view.frame.origin.y = self.originalY
        }
    }

    func dismissPopup() {
        UIView.animate(withDuration: 0.25, animations: {
            self.contentVC.view.frame.origin.y = self.view.frame.height
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    private func snapBack() {
        UIView.animate(withDuration: 0.2) {
            self.contentVC.view.frame.origin.y = self.originalY
        }
    }
}
