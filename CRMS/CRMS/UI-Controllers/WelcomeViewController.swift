//
//  WelcomeViewController.swift
//  CRMS
//
//  Created by Hoor Hasan 08/12/2025.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    @IBOutlet var backgroundWelcomeScreen: UIView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Welcome view controller")
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        //rounding the view bottom edge

        //rounding the view bottom edge to raduis 200 (large custom radius for background design)
        backgroundWelcomeScreen.layer.cornerRadius = 200
        //specify which corner (botton left & right)
        backgroundWelcomeScreen.layer.maskedCorners=[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        //Ensure that any subviews are clipped to the rounded corners.
        backgroundWelcomeScreen.layer.masksToBounds = true
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
