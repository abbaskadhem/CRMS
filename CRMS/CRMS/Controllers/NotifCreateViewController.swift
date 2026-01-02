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
    var notif : NotificationModel?
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var detail: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = AppColors.primary
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        if notif != nil {
            titleInput.text = notif?.title
            detail.text = notif?.description
        }
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
                    
                    //send announcement to all users in the toWho
                    showAnnouncementBanner(title: title, message: description)
                    
                    //send push notif
                    
                    
                    
                    //go back to list
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.navigationController?.viewControllers.forEach { vc in
                            if vc is NotificationsViewController {
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }

                    }
                    
                } catch {
                    // show error to user
                    print("Notification not created")
                }

            }
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        let alert = UIAlertController(
               title: "Discard Announcement?",
               message: "Any changes you made will be lost.",
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
           alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
               self.navigationController?.popViewController(animated: true)
           })

           present(alert, animated: true)
    }
    
    func showAnnouncementBanner(title: String, message: String) {
        let banner = UIView()
        banner.backgroundColor = AppColors.secondary
        banner.layer.cornerRadius = 12
        banner.alpha = 0

        let label = UILabel()
        label.text = "\(title)\n\(message)"
        label.numberOfLines = 2
        label.textColor = .white

        banner.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        banner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -12),
        ])

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow })
        else { return }
        window.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 12),
            banner.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 12),
            banner.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -12)
        ])

        UIView.animate(withDuration: 0.2) {
            banner.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 0.2, animations: {
                banner.alpha = 0
            }) { _ in
                banner.removeFromSuperview()
            }
        }
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
