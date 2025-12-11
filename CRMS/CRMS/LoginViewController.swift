//
//  LoginViewController.swift
//  CRMS
//
//  Created by Guest User on 08/12/2025.
//

import UIKit

class LoginViewController: UIViewController {


    @IBOutlet weak var backgroundLogin: UIView!
    
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
    
    //this method is for rounding the bottom edge of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //rounding the view bottom edge
        backgroundLogin.layer.cornerRadius = 200
        backgroundLogin.layer.maskedCorners=[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundLogin.layer.masksToBounds = true
        
    }

}
