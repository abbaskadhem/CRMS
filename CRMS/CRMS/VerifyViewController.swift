//
//  VerifyViewController.swift
//  CRMS
//
//  Created by BP-36-201-02 on 15/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class VerifyViewController: UIViewController {

    @IBOutlet weak var verifyButton: UIButton!

    @IBOutlet weak var resend : UILabel! 
    @IBOutlet weak var counter : UILabel!

    //set timer & count down
    var timer: Timer?
    var countDown = 30 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Verification"

        // Initially hide the resend & counter
        resend.isHidden = true
        counter.isHidden = true
        startTimer()

        //making resend tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resendTapped))
        resend.isUserInteractionEnabled = true
        resend.addGestureRecognizer(tapGesture)

    }
    
    //make the page appears as bottom sheet
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        // Resend verification email
        resendVerificationEmail()
    }

    @IBAction func verifyButtonTapped(_ sender : UIButton){
        //check if verified 
        
        //get the current user 
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Reload user info to check if verified
        user.reload(completion: { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            // Check if email is verified
            if user.isEmailVerified {
                //check user role and navigate accourdingly
                self?.checkUserRole(user)
            } 
            else {
                self?.showAlert(title: "Email Not Verified", message: "Please verify your email before proceeding")
            }
        })
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
        } 
        else {
            // Timer finished
            timer?.invalidate()
            resend.isHidden = false
            counter.isHidden = true
        }
    }

    private func resendVerificationEmail(){
        //get the current user 
        guard let user = Auth.auth().currentUser else {
            return
        }
        //send user verification link through email if resend ie clicked
            user.sendEmailVerification {
                //[weak self] -> to avoid retain cycle
                [weak self] error in 
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                    return
                } 
                else {
                    self?.showAlert(title: "Email Sent", message: "Verification email has been resent")
                }
            }   
        }    
    }

    //check for role function
    private func checkUserRole(_ user: User){
        /*
        let db = Firestore.firestore()
        let userID = user.uid

        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            if let document = document, document.exists {
                let role = document.get("role") as? String ?? ""

                // Navigate based on user role
                if role == "admin" {
                    self?.navigateToAdminHome()
                } else {
                    self?.navigateToUserHome()
                }
            }
        }
        */
    }

    //navigation methods for each role (admin, technician, requester)
    /*
    private func navigateToAdminHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let adminHomeVC = storyboard.instantiateViewController(withIdentifier: "AdminHomeViewController") as? AdminHomeViewController {
            adminHomeVC.modalPresentationStyle = .fullScreen
            present(adminHomeVC, animated: true)
        }
    }

    private func navigateToTechHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userHomeVC = storyboard.instantiateViewController(withIdentifier: "UserHomeViewController") as? UserHomeViewController {
            userHomeVC.modalPresentationStyle = .fullScreen
            present(userHomeVC, animated: true)
        }
    }

    private func navigateToRequesterHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userHomeVC = storyboard.instantiateViewController(withIdentifier: "UserHomeViewController") as? UserHomeViewController {
            userHomeVC.modalPresentationStyle = .fullScreen
            present(userHomeVC, animated: true)
        }
    }
    */
    
    //this method is for rounding the button
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        //rounding verify button raduis
        verifyButton.layer.cornerRadius = 20
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
