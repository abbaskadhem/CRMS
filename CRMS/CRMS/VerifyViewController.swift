//
//  VerifyViewController.swift
//  CRMS
//
//  Created by BP-36-201-02 on 15/12/2025.
//

import UIKit

class VerifyViewController: UIViewController {

    @IBOutlet var verifyButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Verification"

        // Do any additional setup after loading the view.
    }
    
    //make the page appears as bottom sheet
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //rounding verify button raduis
        verifyButton.layer.cornerRadius = 20
     
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
