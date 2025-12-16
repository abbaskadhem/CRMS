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

    @IBOutlet var verifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        //rounding verify button raduis
        verifyButton.layer.cornerRadius = 20

        self.title = "Verification"

    }
    
    //make the page appears as bottom sheet
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    private func navigateToUserHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userHomeVC = storyboard.instantiateViewController(withIdentifier: "UserHomeViewController") as? UserHomeViewController {
            userHomeVC.modalPresentationStyle = .fullScreen
            present(userHomeVC, animated: true)
        }
    }
    */
    
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
