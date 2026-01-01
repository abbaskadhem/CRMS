//
//  ForgotPasswordViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ForgotPasswordViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var resend: UILabel!
    @IBOutlet weak var counter: UILabel!
    
    //set timer & count down
    var timer: Timer?
    var countDown = 30

    //property to disable the send button ONLY if text field is empty
    var isSendButtonEnabled: Bool {
        guard let email = emailTextField.text, !email.isEmpty else {
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rounding send button radius
        sendButton.layer.cornerRadius = 20
        
        self.title = "Forgot Password"

        //disable send button initially
        sendButton.isEnabled = false
        sendButton.alpha = 0.75

        // Initially hide the resend & counter
        resend.isHidden = true
        counter.isHidden = true

        //listening to text changes for live validation
        emailTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)

        //making resend tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resendTapped))
        resend.isUserInteractionEnabled = true
        resend.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate() // Clean up timer when leaving VC [web:77][web:82]
    }
    
    deinit {
        timer?.invalidate() // Final cleanup [web:80]
    }

    //resend label tapped
    @objc private func resendTapped(){
        // Hide the resend label and restart the timer
        resend.isHidden = true

        //fade effect
        UIView.animate(withDuration: 0.5, animations: {
            self.resend.alpha = 0.0 }) { _ in
            self.resend.alpha = 1.0 // Reset alpha for next time
            self.startTimer() // Restart the timer
        }
        
        //resend forgot password link
        sendLink()
    }
    
    // Enables / disables send button while user types
    @objc private func textFieldsDidChange(){
        sendButton.isEnabled = isSendButtonEnabled
        sendButton.alpha = isSendButtonEnabled ? 1.0 : 0.75
    }

    //send reset password email
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendLink()
    }

    private func sendLink(){
        //email input validation
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please Enter Your Email Address")
            return
        }

        //disable button during request
        sendButton.isEnabled = false
        sendButton.alpha = 0.75
        
        //checking if the email is correctly and in the db
        let db = Firestore.firestore()

        db.collection("User").whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                self?.sendButton.isEnabled = true
                self?.sendButton.alpha = 1.0
                return
            }
            
            guard let self = self else { return }
            
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                // Email exists, send reset link ✅ Fixed: no label needed
                self.sendPasswordReset(email)
            } else {
                self.showAlert(title: "Email Not Found", message: "No account found with this email")
                self.sendButton.isEnabled = true
                self.sendButton.alpha = 1.0
            }
        }
    }

    private func sendPasswordReset(_ email: String){ // ✅ Fixed parameter label
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            //re-enable button
            self?.sendButton.isEnabled = true
            self?.sendButton.alpha = 1.0

            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Email Sent", message: "A password reset link has been sent to your email")
                self?.startTimer() // Start timer after sending email
            }
        }
    }

    private func startTimer(){
        // Update the label to show countdown initially
        resend.isHidden = true
        counter.isHidden = false

        countDown = 30 // Reset countdown time
        timer?.invalidate() // Invalidate any previous timer
        
        // Create a new timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc func updateCountdown() {
        if countDown > 0 {
            countDown -= 1
            counter.text = "Resend in \(countDown)s"
        } else {
            // Timer finished
            timer?.invalidate()
            resend.isHidden = false
            counter.isHidden = true
        }
    }

    //helper method for alert messages
    private func showAlert(title: String, message: String){ // Made private
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
