//
//  NotifCreateViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 31/12/2025.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class NotifCreateViewController: UIViewController {

    var isTechSelected = false
    var isStudentSelected = false
    var isStaffSelected = false
    
    var currentUser : User?
    
    @IBOutlet weak var titleInput: UITextField!
    
    
    @IBOutlet weak var detail: UITextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        print("NotifCreate")
    }
    
    func configUI() {
        titleInput.backgroundColor = .clear
        titleInput.layer.cornerRadius = 10
        titleInput.layer.borderWidth = 1
        titleInput.layer.borderColor = AppColors.primary.cgColor
        
        detail.layer.cornerRadius = 10
        detail.layer.borderWidth = 1
        detail.layer.borderColor = AppColors.primary.cgColor
    }
    
    @IBAction func techBtnTapped(_ sender: UIButton) {
        isTechSelected = toggleCheckBox(sender)
    }
    
    
    @IBAction func studentBtnTapped(_ sender: UIButton) {
        isStudentSelected = toggleCheckBox(sender)
    }
    
    
    @IBAction func staffBtnTapped(_ sender: UIButton) {
        isStaffSelected = toggleCheckBox(sender)
    }
    
    func toggleCheckBox(_ button: UIButton) -> Bool {
        button.isSelected.toggle()
        return button.isSelected
    }

    
    @IBAction func sendBtnTapped(_ sender: Any) {
        print("send tapped")
        guard isTechSelected || isStudentSelected || isStaffSelected else { return }
            guard
                let title = titleInput.text, !title.isEmpty else {
                
                print("returned title")
                return
            }
               guard let description = detail.text, !description.isEmpty else {
                    
                    print("returned description")
                    return
                }
              guard  let createdBy = currentUser?.id else {
                    print("returned createdBy")
                    return
                }
        

            Task {
                async let techIDs = isTechSelected
                       ? SessionManager.shared.fetchUserIDs(subtype: .technician)
                       : []

                   async let studentIDs = isStudentSelected
                       ? SessionManager.shared.fetchUserIDs(subtype: .student)
                       : []

                   async let staffIDs = isStaffSelected
                       ? SessionManager.shared.fetchUserIDs(subtype: .staff)
                       : []

                let toWho = Array(Set(await techIDs + studentIDs + staffIDs))

                let data: [String: Any] = [
                    "title": title,
                    "description": description,
                    "type": NotiType.announcement.rawValue,
                    "toWho": toWho,
                    "createdBy": createdBy,
                    "createdOn": Timestamp(),
                    "inactive": false
                ]

                do {
                    try await Firestore.firestore()
                        .collection("Notification")
                        .addDocument(data: data)
                    print("Created notification")
                    //go back to list
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } catch {
                    // show error to user
                    print("Notification not created")
                }

            }
    }
    
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
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
