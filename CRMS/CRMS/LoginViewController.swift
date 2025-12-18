//
//  LoginViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//



import UIKit
import FirebaseAuth
import FirebaseStorage

class LoginViewController: UIViewController {


    //IBOutlets
    @IBOutlet weak var backgroundLogin: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var forgotPassword: UILabel!
    
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var loginButton : UIButton!

    //For navigating to home page
    var window: UIWindow?
    
    //property to disable the login button ONLY if both text fields are empty
    var isLoginButtonEnabled : Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false // will return false if both not empty
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
        
        //making forgot password tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(tapGesture)
        
    }

    // Enables / disables login button while user types
    @objc private func textFieldsDidChange(){
        if isLoginButtonEnabled{
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
        }
        else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.75
        }
    }
    
    //Forgot password clickable
    @objc private func forgotPasswordTapped(){
        performSegue(withIdentifier: "ForgotPasswordSegue", sender: nil)
    }
    
    //cofiguring bottom sheet
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //forgot password bottom sheet
        if segue.identifier == "ForgotPasswordSegue" {
            if let sheet = segue.destination.sheetPresentationController{
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
        
        //verifictaion bottom sheet
        if segue.identifier == "verificationSegue" {
            if let sheet = segue.destination.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
    }
    
    
    //reememberMe Button Action
    @IBAction func rememberMeButtonTapped(_ sender: UIButton){
        
        rememberMeButton.isSelected.toggle()
        
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
        loginButton.alpha = 0.75 //opacity level

        //Log in with FireBase Authentication
        //Authenticate the user
        Auth.auth().signIn(withEmail: email, password: password){
            //[weak self] -> to avoid retain cycle
           [weak self] authResult, error in

           //re-enable the button after authentication
            self?.loginButton.isEnabled = true
            self?.loginButton.alpha = 1.0 //opacity level

            //handle authentication result
            if let error = error {

                //Login failed -> show error message using localizedDescription from Firebase
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }
            /*else {
                //get the current user
                guard let user = Auth.auth().currentUser else {
                    return
                }
                //send user verification link through email every time the user login
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
            }*/

            //save remember me
            if self?.rememberMeButton.isSelected == true {
                UserDefaults.standard.set(true, forKey: "rememberMeButton")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "rememberMeButton")
            }
            
            //Login in successful - save user ID to UserDefaults
            if let userID = authResult?.user.uid {
                UserDefaults.standard.set(userID, forKey: UserDefaultsKeys.userID)
            }
            
            //call checkUserRole Function to navigate to the correct home page
            
            
        }
    }

    
    
    
    //check for role function
    private func checkUserRole(_ user: User){
        /*
        let db = Firestore.firestore()
        let userID = user.uid
        
        db.collection("users").document(userID).getDocument {
            [weak self] document, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            //user exist
            if let document = document, document.exists {
                let role = document.get("role") as? String ?? ""
                
                var vc : UIViewController?
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Navigate based on user role
                if role == "admin" {
                    vc = storyboard.instantiateViewController(withIdentifier: "AdminHomeViewController")
                }
                else if role == "technician" {
                    vc = storyboard.instantiateViewController(withIdentifier: "TechnicianHomeViewController")
                }
                else if role == "Requester" {
                    vc = storyboard.instantiateViewController(withIdentifier: "RequesterHomeViewController")
                }
            }
            
            //user does't exist
            else {
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                self.window?.rootViewController = loginVC
                self.window?.makeKeyAndVisible()
            }
        }
        */
    }

    //this method is for rounding the bottom edge of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //rounding the view bottom edge to raduis 200
        backgroundLogin.layer.cornerRadius = 200

        //specify which corner (botton left & right)
        backgroundLogin.layer.maskedCorners=[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        //Ensure that any subviews are clipped to the rounded corners.
        backgroundLogin.layer.masksToBounds = true
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
