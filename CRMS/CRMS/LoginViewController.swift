//
//  LoginViewController.swift
//  CRMS
//
//  Created by Guest User on 08/12/2025.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var forgotPassword: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("login view controller")

        navigationItem.hidesBackButton = true
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background.layer.cornerRadius = background.frame.height/2
        
        background.translatesAutoresizingMaskIntoConstraints = true
    }

}
