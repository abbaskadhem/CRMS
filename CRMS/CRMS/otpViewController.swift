//
//  otpViewController.swift
//  CRMS
//
//  Created by Hoor Hasan
//

import UIKit

class otpViewController: UIViewController {

    @IBOutlet weak var backgroundOTP: UIView!
    @IBOutlet weak var verifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hiding "back" button in the navigation bar
        navigationItem.hidesBackButton = true

    }
    
    //this method is for rounding the bottom edge of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //rounding the view bottom edge to raduis 200
        backgroundOTP.layer.cornerRadius = 200

        //specify which corner (botton left & right)
        backgroundOTP.layer.maskedCorners=[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        //Ensure that any subviews are clipped to the rounded corners.
        backgroundOTP.layer.masksToBounds = true
        
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
