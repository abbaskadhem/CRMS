//
//  UIViewController+Extension.swift
//  CRMS
//

import UIKit

extension UIViewController {

    /// Display a simple alert with a title, message, and OK button
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message body of the alert
    func showAlert(title: String, message: String) {
        showAlert(title: title, message: message, completion: nil)
    }

    /// Display a simple alert with a title, message, OK button, and optional completion handler
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message body of the alert
    ///   - completion: Optional closure to execute when OK is tapped
    func showAlert(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    /// Display a confirmation alert with Yes/No options
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message body of the alert
    ///   - confirmHandler: Closure to execute when user confirms (taps Yes)
    func showConfirmationAlert(title: String, message: String, confirmHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            confirmHandler()
        }))

        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        present(alert, animated: true)
    }
}
