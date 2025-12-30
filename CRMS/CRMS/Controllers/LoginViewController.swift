//
//  LoginViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class LoginViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var backgroundLogin: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPassword: UILabel!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    // Remove window property - SceneDelegate handles this
    
    //property to disable the login button ONLY if both text fields are empty
    var isLoginButtonEnabled: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return !email.isEmpty && !password.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("login view controller")
        navigationItem.hidesBackButton = true

        loginButton.isEnabled = false
        loginButton.alpha = 0.75

        emailTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(tapGesture)
    }

    @objc private func textFieldsDidChange(){
        loginButton.isEnabled = isLoginButtonEnabled
        loginButton.alpha = isLoginButtonEnabled ? 1.0 : 0.75
    }
    
    @objc private func forgotPasswordTapped(){
        performSegue(withIdentifier: "ForgotPasswordSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForgotPasswordSegue" || segue.identifier == "verificationSegue" {
            if let sheet = segue.destination.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
    }
    
    @IBAction func rememberMeButtonTapped(_ sender: UIButton){
        rememberMeButton.isSelected.toggle()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton){
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please Enter Your Email")
            return
        }

        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please Enter Your Password")
            return
        }

        loginButton.isEnabled = false
        loginButton.alpha = 0.75

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            // Re-enable button
            self?.loginButton.isEnabled = true
            self?.loginButton.alpha = 1.0

            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            // Save remember me preference
            if self?.rememberMeButton.isSelected == true {
                UserDefaults.standard.set(true, forKey: "rememberMeButton")
            } else {
                UserDefaults.standard.removeObject(forKey: "rememberMeButton")
            }
            
            // Login successful - get user and check role
            guard let user = authResult?.user else {
                self?.showAlert(title: "Error", message: "Failed to get user data")
                return
            }
            
            UserDefaults.standard.set(user.uid, forKey: "userID")
            self?.checkUserRole(for: user)
        }
    }

    
    private func checkUserRole(for user: FirebaseAuth.User) {
        let db = Firestore.firestore()
        let userID = user.uid
        
        db.collection("User").document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                self.showAlert(title: "User Not Found", message: "No user found with this ID.")
                return
            }
            
            let role = snapshot.get("type") as? Int ?? -1

            // TODO: Create separate storyboards/tab bar controllers for Servicer and Requester roles
            // Currently all roles use Admin.storyboard as a temporary solution
            let adminStoryboard = UIStoryboard(name: "Admin", bundle: nil)
            var vc: UIViewController?

            switch role {
            case 1000: // admin
                vc = adminStoryboard.instantiateInitialViewController()
            case 1002: // servicer
                vc = adminStoryboard.instantiateInitialViewController()
            case 1001: // requester
                vc = adminStoryboard.instantiateInitialViewController()
            default:
                self.showAlert(title: "Invalid Role", message: "Unknown user role.")
                return
            }
            
            if let vc = vc {
                // Navigate using navigation controller or present modally
                if let navController = self.navigationController {
                    navController.pushViewController(vc, animated: true)
                } else {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLogin.layer.cornerRadius = 200
        backgroundLogin.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundLogin.layer.masksToBounds = true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
