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

    @IBOutlet weak var biometrics: UILabel!

    
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
        
        //making "Login by biometrics" tappable
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(biometricsTapped))
        biometrics.isUserInteractionEnabled = true
        biometrics.addGestureRecognizer(tapGesture2)
        
        //updateBiometricLabelVisibility
        updateBiometricLabelVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBiometricLabelVisibility()
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
            
            UserDefaults.standard.set(user.uid, forKey: "userID")
            self?.updateBiometricLabelVisibility()
            self?.checkUserRole(for: user)
        }
    }
    
    //Checks the user role via SessionManager and navigates to the appropriate storyboard
    private func checkUserRole(for user: FirebaseAuth.User) {
        Task {
            do {
                // Use SessionManager to get user type from database
                let role = try await SessionManager.shared.getUserType()

                await MainActor.run {
                    var vc: UIViewController?

                    switch role {
                    case UserType.admin.rawValue:
                        let adminStoryboard = UIStoryboard(name: "Admin", bundle: nil)
                        vc = adminStoryboard.instantiateInitialViewController()
                    case UserType.servicer.rawValue:
                        // TODO: Create separate Servicer storyboard
                        let adminStoryboard = UIStoryboard(name: "Admin", bundle: nil)
                        vc = adminStoryboard.instantiateInitialViewController()
                    case UserType.requester.rawValue:
                        let requesterStoryboard = UIStoryboard(name: "Requester", bundle: nil)
                        vc = requesterStoryboard.instantiateInitialViewController()
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
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    @objc private func biometricsTapped(){
        
        //check for previous session
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Not Logged In", message: "Plaese login with email & password first")
            return
        }

        let context = LAContext()
        var error: NSError?
        let reason = "Authentication is required to continue"
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let msg = error?.localizedDescription ?? "Face ID / Touch ID is not available"
            showAlert(title: "Unavailable", message: msg)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){
            [weak self] success, evaluateError in
            guard let self else {
                return
            }
            
            DispatchQueue.main.async{
                if success {
                    UserDefaults.standard.set(user.uid, forKey: "userID")
                    //navigate to correct home page
                    self.checkUserRole(for: user)
                }
                else {
                    let msg = (evaluateError as NSError?)?.localizedDescription ?? "Authentication Failed"
                    self.showAlert(title: "Authentication Failed", message: msg)
                }
            }
        }
    }
    
    //show/hide face id label
    private func updateBiometricLabelVisibility(){
        
        //checking if the device supports Face ID / Touch ID
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        let loggedin = (Auth.auth().currentUser != nil)
        
        //showing label only if user have a firebase session & device supports biometrics
        biometrics.isHidden = !(available && loggedin)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLogin.layer.cornerRadius = 200  // Large custom radius for background design
        backgroundLogin.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundLogin.layer.masksToBounds = true
    }
}
