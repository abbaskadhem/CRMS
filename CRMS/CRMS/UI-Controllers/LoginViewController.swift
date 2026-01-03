//
//  LoginViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//

import UIKit
import FirebaseAuth
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {

    //IBOutlets
    @IBOutlet weak var backgroundLogin: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPassword: UILabel!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    
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
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.isEnabled = false
        loginButton.alpha = 0.75

        emailTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(tapGesture)
        
    }
    
    //showing cursor
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder() //move cursor to password textField
        }
        else {
            textField.resignFirstResponder() //hide keyboard
        }
        return true
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
            
            print("User:", user)
            
            UserDefaults.standard.set(user.uid, forKey: "userID")
            self?.checkUserRole(for: user)
        }
    }
    
    //Checks the user role via SessionManager and navigates to the appropriate storyboard
    private func checkUserRole(for user: FirebaseAuth.User) {
        Task {
            do {
                let role = try await SessionManager.shared.getUserType()
                print("Role: \(role)")
                // Fire admin background work
                if role == UserType.admin.rawValue {
                    Task.detached {
                        do {
                            let delayedCount = try await RequestController.shared.checkForDelayedRequests()
                            if delayedCount > 0 {
                                print("Marked \(delayedCount) request(s) as delayed")
                            }
                        } catch {
                            print("Failed to check for delayed requests: \(error)")
                        }
                    }
                }

                await MainActor.run {
                    let vc: UIViewController?

                    switch role {
                    case UserType.admin.rawValue:
                        print("Going to Admin")
                        vc = UIStoryboard(name: "Admin", bundle: nil).instantiateInitialViewController()
                    case UserType.servicer.rawValue:
                        print("Going to Servicer")
                        vc = UIStoryboard(name: "Servicer", bundle: nil).instantiateInitialViewController()
                    case UserType.requester.rawValue:
                        print("Going to Requester")
                        vc = UIStoryboard(name: "Requester", bundle: nil).instantiateInitialViewController()
                    default:
                        self.showAlert(title: "Invalid Role", message: "Unknown user role.")
                        return
                    }

                    guard let vc else { return }

                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = vc
                        window.makeKeyAndVisible()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLogin.layer.cornerRadius = 200  // Large custom radius for background design
        backgroundLogin.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundLogin.layer.masksToBounds = true
    }
}
