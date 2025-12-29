//
//  NotificationsViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 29/12/2025.
//

import UIKit
import FirebaseDatabase

class NotificationsViewController: UIViewController {

    var isAdmin : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // check the type of user : Admin/student/staff
        //if admin
        isAdmin = true
        
        //else
        isAdmin = false
        
        isAdmin ? print("Admin") : print("Not Admin")
        
    
        
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
