//
//  WelcomeViewController.swift
//  CRMS
//
//  Created by Guest User on 08/12/2025.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    @IBOutlet var backgroundWelcomeScreen: UIView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Welcome view controller")
        
        // Do any additional setup after loading the view.
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
        //rounding the view bottom edge
        backgroundWelcomeScreen.layer.cornerRadius = 200
        backgroundWelcomeScreen.layer.maskedCorners=[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundWelcomeScreen.layer.masksToBounds = true
        
    }

}
