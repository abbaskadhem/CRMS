//
//  LoginViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//

/* needs to be checked 
    1- validating user role is missing !!
    2- ForgotPasswordViewController !!
*/


import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {


    //IBOutlets
    @IBOutlet weak var backgroundLogin: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPassword: UILabel!

    @IBOutlet weak var loginButton : UIButton!
    
    
    

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

        //disable login buttom intially when the page loaded
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
        performSegue(withIdentifier: "ForgotPasswordSegue", sender: self)
    }


    //Login Button Action
    @IBAction func loginButtonTapped(_ sender: UIButton){
        
        //email input validation + dispaly alert message if empty using optional unwrap
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), 
        !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please Enter Your Email Address")
            return
        }

        //password input validation + display alert message if empty using optional unwrap
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
        !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please Enter Your Password Address")
            return
        }

        //disable button during authentication to prevent mutiple taps
        loginButton.isEnabled = false
        loginButton.alpha = 0.75 //opacity level

        //Log in with FireBase Authentication
        //Authenticate the user
        Auth.auth().signIn(withEmail: email, password: password){
            //[weak self] --> to avoid retain cycle
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

            //Login in successful - save user ID to UserDefaults
            if let userID = authResult?.user.uid {
                UserDefaults.standard.set(userID, forKey: UserDefaultsKeys.userID)
            }
            
            //calling sendOTP function
            
            

            //navigate to home screen
            //self?.navigateToHome()
        }
    }
    
    //after email verification the system will sent an OTP to the user email fro extra security verification
    /*func sendOTP(){
        Auth.auth().sen
    }*/

    //navigating to home screen function
    /*
    private func navigateToHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeVC.modalPresentationStyle = .fullScreen
            present(homeVC, animated: true)
        }
    }
     */

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
