//
//  ForgotPasswordViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        //disable send button initially
        sendButton.isEnabled = false
        sendButton.alpha = 0.5

        //listening to text changes for live validation
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    //enable / disable send button while user types
    @objc private func textFieldDidChange() {

        if let email = emailTextField.text, !email.isEmpty {
            sendButton.isEnabled = true
            sendButton.alpha = 1.0
        } 
        else {
            sendButton.isEnabled = false
            sendButton.alpha = 0.5
        }
    }

    //send reset password email
    @IBAction func sendButtonTapped(_ sender: UIButton) {

        //email input validation
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please Enter Your Email Address")
            return
        }

        //disable button during request
        sendButton.isEnabled = false
        sendButton.alpha = 0.5

        //send reset password email using firebase
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in

            //re-enable button
            self?.sendButton.isEnabled = true
            self?.sendButton.alpha = 1.0

            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } 
            else {
                self?.showAlert(title: "Email Sent", message: "A password reset link has been sent to your email.") {
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    //helper method for alert messages 
    func showAlert (title: String, message: String){

        // Create an alert controller with a specified title and message.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Create an action for the alert, which will be a button labeled "OK".
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Present the alert on the screen.
        present(alert, animated: true)
    }

}
