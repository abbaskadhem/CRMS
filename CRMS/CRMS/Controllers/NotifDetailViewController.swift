//
//  NotifDetailViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 30/12/2025.
//

import UIKit
import FirebaseFirestore

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
        
        performSegue(withIdentifier: "ShowEditSegue", sender: self)
    }
    
    @objc func clickedDelete() {
        //delete the notif
        let alert = UIAlertController(
               title: "Delete Announcement?",
               message: "This action cannot be undone.",
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

           alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
               guard let id = self.notification?.id else { return }

               do {
                    Firestore.firestore()
                       .collection("Notification")
                       .document(id)
                       .updateData(["inactive": true]) { error in
                           if error == nil {
                               self.navigationController?.popViewController(animated: true)
                           }
                       }
               }
               
           })

           present(alert, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEditSegue",
               let vc = segue.destination as? NotifCreateViewController {
                vc.notif = notification
            vc.currentUser = currentUser
            }
    }
}
