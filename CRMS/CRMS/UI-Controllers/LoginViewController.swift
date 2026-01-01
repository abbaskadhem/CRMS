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
import LocalAuthentication

class LoginViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var backgroundLogin: UIView!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var forgotPassword: UILabel!
    @IBOutlet weak var faceTouchId: UILabel!

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
        
        //ensuring that the page did load without any issues
        print("login view controller")

        //hiding "back" button in the navigation bar
        navigationItem.hidesBackButton = true

        //disable login button intially when the page loaded
        loginButton.isEnabled = false
        loginButton.alpha = 0.75

        //listening to text changes for live validation
        emailTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        
        //making "forget password" tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(tapGesture)

        //making "Use Face/Touch Id to Login" tappable
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(faceTouchIdTapped))
        faceTouchId.isUserInteractionEnabled = true
        faceTouchId.addGestureRecognizer(tapGesture2)

        //showing/hidding Use Face/Touch Id to Login accourding to the saved prefrences
         updateBiometricLabelVisibility()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //refreshing Face/Touch ID label every time the page appears after logout
        updateBiometricLabelVisibility()
    }

    @objc private func textFieldsDidChange(){
        //enable button only when text boxes aren't empty
        loginButton.isEnabled = isLoginButtonEnabled
        loginButton.alpha = isLoginButtonEnabled ? 1.0 : 0.75
    }
    
    //Forgot password navigate to forgot button bottom sheet
    @objc private func forgotPasswordTapped(){
        performSegue(withIdentifier: "ForgotPasswordSegue", sender: nil)
    }

    //forgot password bottom sheet
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForgotPasswordSegue" || segue.identifier == "verificationSegue" {
            if let sheet = segue.destination.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
    }
    
    //rememberMe Button Action
    @IBAction func rememberMeButtonTapped(_ sender: UIButton){
        rememberMeButton.isSelected.toggle()

        //if remember me turned OFF -> delete any saved biometric login data
        if rememberMeButton.isSelected == false {
            clearBiometricLogin()
        }
    }
    
    //login using face/touch id
    @objc private func faceTouchIdTapped(){

        //check if biometric login was enabled before (remember me is on)
        let biometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        if biometricEnabled == false {
            showAlert(title: "Not Enabled", message: "Please login with email & password first.")
            return
        }

        //get saved email and password
        guard let savedEmail = UserDefaults.standard.string(forKey: "biometricEmail"),
              let savedPassword = UserDefaults.standard.string(forKey: "biometricPassword") else {
            showAlert(title: "Missing Data", message: "Please login with email & password again.")
            return
        }

        //loacl authentication variables 
        let context = LAContext() //info used from local authentication 
        var error: NSError? //to handle error
        let reason = "Authentication required to Login"

        //check if Face/Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            //show Face/Touch ID prompt
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { 
                [weak self] success, evaluateError in
                
                guard let self = self else { return }

                DispatchQueue.main.async {

                    if success { //if authentication is success --> login again using Firebase (same logic as normal login)
                        print("Biometric success - logging in")

                        Auth.auth().signIn(withEmail: savedEmail, password: savedPassword) { [weak self] authResult, error in
                            
                            //handling firebase login errors
                            if let error = error {
                                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                                return
                            }

                            guard let user = authResult?.user else {
                                self?.showAlert(title: "Error", message: "Failed to get user data")
                                return
                            }

                            //save user id
                            UserDefaults.standard.set(user.uid, forKey: "userID")

                            //navigate to correct home page
                            self?.checkUserRole(for: user)
                        }

                    } 
                    else {
                        //device does not support biometrics or not enrolled
                        let msg = (evaluateError as NSError?)?.localizedDescription ?? "Authentication failed."
                        self.showAlert(title: "Authentication Failed", message: msg)
                    }
                }
            }
        }
        else {
            let msg = error?.localizedDescription ?? "Face ID / Touch ID is not available."
            showAlert(title: "Unavailable", message: msg)
        }
    }

    //clear biometric login data 
    private func clearBiometricLogin(){ 

        //deleting saved email/password + disabling biometric flag
        UserDefaults.standard.removeObject(forKey: "biometricEmail")
        UserDefaults.standard.removeObject(forKey: "biometricPassword")
        UserDefaults.standard.set(false, forKey: "biometricEnabled")

        //updating label visibility after clearing
        updateBiometricLabelVisibility()
    }

    //show/hide face id label
    private func updateBiometricLabelVisibility(){

        //checking if user enabled biometric login before
        let enabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        
        //checking if the device supports Face ID / Touch ID
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        ////showing label only if user enabled it & device supports biometrics
        faceTouchId.isHidden = !(enabled && available) 
    }

    //Login Button Action
    @IBAction func loginButtonTapped(_ sender: UIButton){

        //email input validation + dispaly alert message if empty using optional unwrap
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please Enter Your Email")
            return
        }

        //password input validation + display alert message if empty using optional unwrap
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please Enter Your Password")
            return
        }

        //disable button during authentication to prevent mutiple taps
        loginButton.isEnabled = false
        loginButton.alpha = 0.75

        //Log in with FireBase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            // Re-enable button
            self?.loginButton.isEnabled = true
            self?.loginButton.alpha = 1.0

            //handle authentication results
            if let error = error {
                //Login failed -> show error message using localizedDescription from Firebase
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            // Save remember me preference
            if self?.rememberMeButton.isSelected == true {
                UserDefaults.standard.set(true, forKey: "rememberMeButton")
            } else {
                UserDefaults.standard.removeObject(forKey: "rememberMeButton")
            }
            
            //if remember me is on -> save credentials for Face/Touch ID login
            if self?.rememberMeButton.isSelected == true {
                UserDefaults.standard.set(email, forKey: "biometricEmail")
                UserDefaults.standard.set(password, forKey: "biometricPassword")
                UserDefaults.standard.set(true, forKey: "biometricEnabled")
            } 
            else { //remember me off -> clear biometric login data
                self?.clearBiometricLogin()
            }

            //update label visibility after save/clear
            self?.updateBiometricLabelVisibility()

            // Login successful -> get user and check role
            guard let user = authResult?.user else {
                self?.showAlert(title: "Error", message: "Failed to get user data")
                return
            }
            
            //call checkUserRole Function to navigate to the correct home page
            UserDefaults.standard.set(user.uid, forKey: "userID")
            self?.checkUserRole(for: user)
        }
    }

    //check for role function
    private func checkUserRole(for user: FirebaseAuth.User) {
        let db = Firestore.firestore()
<<<<<<< HEAD:CRMS/CRMS/Controllers/LoginViewController.swift
        let userID = user.uid
        
        db.collection("User").document(userID).getDocument { [weak self] snapshot, error in
            
            guard let self = self else { 
                return 
            }
            
=======

        // Look up user document by Firebase Auth UID
        db.collection("User").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

>>>>>>> main:CRMS/CRMS/UI-Controllers/LoginViewController.swift
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                self.showAlert(title: "User Not Found", message: "No user profile found. Please contact support.")
                return
            }

            let role = data["type"] as? Int ?? -1

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
    }

    //this method is for rounding the bottom edge of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLogin.layer.cornerRadius = 200
        backgroundLogin.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundLogin.layer.masksToBounds = true
    }

    //helper method for alert messages
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
