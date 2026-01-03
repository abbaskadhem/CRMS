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

    static public let shared = NotifCreateViewController()

    //MARK: Variables
    var isTechSelected = false
    var isStudentSelected = false
    var isStaffSelected = false
    
    var currentUser : User?
    var notif : NotificationModel?
    
    private var confirmationOverlay: UIView?
    private var successOverlay: UIView?
    
    //MARK: Outlets
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = AppColors.primary
        
        sendBtn.backgroundColor = AppColors.primary
        
        cancelBtn.backgroundColor = AppColors.primary
        
        sendBtn.layer.cornerRadius = 8
        cancelBtn.layer.cornerRadius = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        if notif != nil {
            titleInput.text = notif?.title
            detail.text = notif?.description
        }
        
        sendBtn.backgroundColor = AppColors.primary
        
        cancelBtn.backgroundColor = AppColors.primary
   
        print("NotifCreate")
    }
    
    //MARK: Config UI
    func configUI() {
        sendBtn.backgroundColor = AppColors.primary
        
        cancelBtn.backgroundColor = AppColors.primary
        titleInput.backgroundColor = .clear
        titleInput.layer.cornerRadius = 10
        titleInput.layer.borderWidth = 1
        titleInput.layer.borderColor = AppColors.primary.cgColor
        
        detail.layer.cornerRadius = 10
        detail.layer.borderWidth = 1
        detail.layer.borderColor = AppColors.primary.cgColor
    }
    
    //MARK: Buttons
    @IBAction func techBtnTapped(_ sender: UIButton) {
        isTechSelected = toggleCheckBox(sender)
    }
    
    
    @IBAction func studentBtnTapped(_ sender: UIButton) {
        isStudentSelected = toggleCheckBox(sender)
    }
    
    
    @IBAction func staffBtnTapped(_ sender: UIButton) {
        isStaffSelected = toggleCheckBox(sender)
    }
    
    //MARK: Toggle Checkbox
    func toggleCheckBox(_ button: UIButton) -> Bool {
        button.isSelected.toggle()
        return button.isSelected
    }

    //MARK: Send Button
    @IBAction func sendBtnTapped(_ sender: Any) {
        showConfirmationOverlay(nil,nil)
        print("send tapped")
        
    }
    
    
    
    //MARK: Cancel Button
    @IBAction func cancelBtnTapped(_ sender: Any) {
        showConfirmationOverlay("Are you sure you want to cancel?", "cancel")
    }
    
    
    //MARK: Banner
    func showBanner(title: String, _ message: String?, _ toWho: [String]) {

        let currentUserId = SessionManager.shared.currentUserId!
        guard toWho.contains(currentUserId) else { return }

        let banner = UIView()
        banner.backgroundColor = AppColors.secondary
        banner.layer.cornerRadius = 12
        banner.alpha = 0

        let label = UILabel()
        label.text = message == nil ? title : "\(title)\n\(message!)"
        label.numberOfLines = message == nil ? 1 : 2
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

    //MARK: Notification creation
    func createNotif(data: NotificationModel) async{
  
        let notif: [String: Any?] = [
            "title": data.title,
            "description": data.description,
            "type": data.type.rawValue,
            "toWho": data.toWho,
            "createdBy": data.createdBy,
            "createdOn": data.createdOn,
            "inactive": false
        ]

        do {
            try await Firestore.firestore()
                .collection("Notification")
                .addDocument(data: notif as [String : Any])
            print("Created notification")
            
            //send announcement to all users in the toWho
            showBanner(title: data.title,nil, data.toWho)
            
        } catch {
            // show error to user
            print("Notification not created")
        }

    }
    
    //MARK: showConfirmationOverlay
    private func showConfirmationOverlay(_ message: String? ,_ type: String?) {
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
        messageLabel.text = message ?? "Are you sure you want to send this announcement?"

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
        } else if type == "cancel" {
            yesButton.addTarget(self, action: #selector(confirmCancelTapped), for: .touchUpInside)
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
    
    //MARK: cancel-confirm
    @objc private func confirmCancelTapped() {
        dismissConfirmationOverlay()
        showSuccessOverlay("Canceled Successfully")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    //MARK: conformation cancel save
    @objc private func cancelSaveTapped() {
        dismissConfirmationOverlay()
    }
    
    //MARK: Create Announcement
    @objc private func confirmSaveTapped() {
        guard isTechSelected || isStudentSelected || isStaffSelected else {
            showErrorBanner(title: "Select at least one target")
            dismissConfirmationOverlay()
            return
        }

            guard
                let title = titleInput.text, !title.isEmpty else {
                
                showErrorBanner(title: "Invalid title")
                dismissConfirmationOverlay()
                return
            }
               guard let description = detail.text, !description.isEmpty else {
                    
                   showErrorBanner(title: "Invalid description")
                   dismissConfirmationOverlay()
                    return
                }
              guard  let createdBy = currentUser?.id else {
                  showErrorBanner(title: "Invalid userID")
                  dismissConfirmationOverlay()
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
                    
                    await MainActor.run {
                                   dismissConfirmationOverlay()
                                   showSuccessOverlay(nil)
                                   showBanner(title: title, description, toWho)
                               }
                    
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
        label.text = message ?? "Announcement Created Successfully"
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
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: Error Banner
    func showErrorBanner(title: String) {
        let banner = UIView()
        banner.backgroundColor = AppColors.secondary
        banner.layer.cornerRadius = 12
        banner.alpha = 0

        let label = UILabel()
        label.text = "\(title)"
        label.numberOfLines = 1
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
