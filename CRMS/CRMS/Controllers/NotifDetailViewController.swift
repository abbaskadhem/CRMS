//
//  NotifDetailViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 30/12/2025.
//

import UIKit

class NotifDetailViewController: UIViewController {

    var notification: NotificationModel!
    var currentUser : User!
    
    @IBOutlet weak var detail: UITextView!
    
    @IBOutlet weak var date: UILabel!
    
    
    @IBOutlet weak var editBtn: UIImageView!
    
    @IBOutlet weak var deleteBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detail.text = notification.description
        
        //show only the date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        date.text = formatter.string(from: notification.createdOn)
        
        //toggle images, only admin can see them
        if currentUser.type != .admin {
            editBtn.isHidden = true
            deleteBtn.isHidden = true
        }else{
            //make the images clickable
            editBtn.isUserInteractionEnabled = true
            deleteBtn.isUserInteractionEnabled = true
            
            let editGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickedEdit))
            editBtn.addGestureRecognizer(editGestureRecognizer)
            
            let deleteGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickedDelete))
            deleteBtn.addGestureRecognizer(deleteGestureRecognizer)
        }


        
    }
    
    @objc func clickedEdit() {
        //go to edit page
        print("edit clicked")
    }
    
    @objc func clickedDelete() {
        //delete the notif
        print("delete clicked")
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
