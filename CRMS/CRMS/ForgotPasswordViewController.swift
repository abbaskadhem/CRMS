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
    
    //property to disable the send button ONLY if text field is empty
    var isSendButtonEnabled : Bool {
        guard let email = emailTextField.text else {
            return false // will return false if not empty
        }
        return !email.isEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Forgot Password"

        //disable send button initially
        sendButton.isEnabled = false
        sendButton.alpha = 0.75

        //listening to text changes for live validation
        emailTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
    }

    //make the page appears as bottom sheet
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //rounding send button raduis
        sendButton.layer.cornerRadius = 20
     
    }
    
    // Enables / disables send button while user types
    @objc private func textFieldsDidChange(){
        if isSendButtonEnabled{
            sendButton.isEnabled = true
            sendButton.alpha = 1.0
        }
        else {
            sendButton.isEnabled = false
            sendButton.alpha = 0.75
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
        sendButton.alpha = 0.75

        //send reset password email using firebase
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in

            //re-enable button
            self?.sendButton.isEnabled = true
            self?.sendButton.alpha = 1.0

            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            else {
                self?.showAlert(title: "Email Sent", message: "A password reset link has been sent to your email")
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
