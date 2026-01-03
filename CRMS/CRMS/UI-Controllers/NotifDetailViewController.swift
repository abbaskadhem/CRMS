//
//  NotifDetailViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 30/12/2025.
//

import UIKit
import FirebaseFirestore

class NotifDetailViewController: UIViewController {
    
    var notificationID: String?

    var notification: NotificationModel!
    var currentUser : User!
    
    private var confirmationOverlay: UIView?
    private var successOverlay: UIView?
    
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var editBtn: UIImageView!
    @IBOutlet weak var deleteBtn: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = AppColors.primary
    }
    
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
    
    //MARK: Edit Announcement
    @objc func clickedEdit() {
        //go to edit page
        print("edit clicked")
        
        performSegue(withIdentifier: "ShowEditSegue", sender: self)
    }

    //MARK: delete Announcement
    @objc private func clickedDelete() {
        showConfirmationOverlay("Are you sure you want to delete this item?", "delete")
    }
    
    
    //MARK: Confirmation Overlay
    private func showConfirmationOverlay(_ message: String?,_ type: String?) {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.alpha = 0

        //background
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        //Title
        let title = UILabel()
        title.text = "Confirmation"
        title.font = .boldSystemFont(ofSize: 20)
        title.textAlignment = .center

        //message
        let messageLabel = UILabel()
        messageLabel.text = message ?? "Are you sure you want to save the edits?"
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        //cancel
        let noButton = UIButton(type: .system)
        noButton.setTitle("No", for: .normal)
        noButton.layer.cornerRadius = 8
        noButton.layer.borderWidth = 1
        noButton.layer.borderColor = UIColor.systemGray4.cgColor
        noButton.addTarget(self, action: #selector(cancelSaveTapped), for: .touchUpInside)

        //confirm
        let yesButton = UIButton(type: .system)
        yesButton.setTitle("Yes, I'm sure", for: .normal)
        yesButton.backgroundColor = AppColors.primary
        yesButton.setTitleColor(.white, for: .normal)
        yesButton.layer.cornerRadius = 8
        if type == nil {
            yesButton.addTarget(self, action: #selector(confirmSaveTapped), for: .touchUpInside)
        }else if type == "delete"{
            yesButton.addTarget(self, action: #selector(confirmDeletion), for: .touchUpInside)
        }
       

        let buttons = UIStackView(arrangedSubviews: [noButton, yesButton])
        buttons.axis = .horizontal
        buttons.spacing = 12
        buttons.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [title, messageLabel, buttons])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        overlay.addSubview(card)
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 280),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])

        confirmationOverlay = overlay

        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
        }
    }
    
    //MARK: conformation cancel
    @objc private func cancelSaveTapped() {
        dismissConfirmationOverlay()
    }
    
    //MARK: conformation save
        @objc private func confirmSaveTapped() {
            dismissConfirmationOverlay()
            showSuccessOverlay(nil)
        }
    
    //MARK: Confirm Delete
    @objc private func confirmDeletion() {
        
        dismissConfirmationOverlay()
        showSuccessOverlay("Deleted Successfully")

        guard let id = self.notification?.id else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
            Firestore.firestore()
                .collection("Notification")
                .document(id)
                .delete { error in
                    if error == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
       
    }
    
    
    //MARK: overlay dissmissal
    private func dismissConfirmationOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.confirmationOverlay?.alpha = 0
        }) { _ in
            self.confirmationOverlay?.removeFromSuperview()
            self.confirmationOverlay = nil
        }
    }
    
    //MARK: succsess overlay
    private func showSuccessOverlay(_ message: String?) {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay.alpha = 0

        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false

        let check = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        check.tintColor = AppColors.primary
        check.contentMode = .scaleAspectFit
        check.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        let label = UILabel()
        label.text = message ?? "Item Details Saved Successfully"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [check, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        overlay.addSubview(container)
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 260),

            check.heightAnchor.constraint(equalToConstant: 60),

            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])

        successOverlay = overlay

        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
            check.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismissSuccessOverlay()
        }
    }

    //MARK: remove overlay
    private func dismissSuccessOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.successOverlay?.alpha = 0
        }) { _ in
            self.successOverlay?.removeFromSuperview()
            self.successOverlay = nil
        }
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
