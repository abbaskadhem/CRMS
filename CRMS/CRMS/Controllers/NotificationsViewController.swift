//
//  NotificationsViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 29/12/2025.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currentUser: User?
    
    private var isAdmin: Bool {
        currentUser?.type == .admin
    }

    
    private let notificationService = NotificationService()

    private var notifications: [NotificationModel] = []
    private var visibleNotifications: [NotificationModel] = []

    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTestUser(uid: "ADM-301225")
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationService.stopListening()
    }

    
    private func configureUI() {

        if !isAdmin {
            hideAddButton()
        }

        setupTableView()
    }

    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            NotificationCell.self,
            forCellReuseIdentifier: NotificationCell.reuseID
        )

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    private func applyVisibilityFilter() {
        guard let currentUser else {
            visibleNotifications = []
            tableView.reloadData()
            return
        }

        visibleNotifications = notifications.filter { notification in
            switch notification.type {

            case .announcement:
                // Global announcement
                if notification.toWho.isEmpty {
                    return true
                }

                // Admin sees announcements he created
                if isAdmin && notification.createdBy == currentUser.id {
                    return true
                }

                // Targeted announcement
                return notification.toWho.contains(currentUser.id)

            case .notification:
                // Notifications are always strictly targeted
                return notification.toWho.contains(currentUser.id)
            }
        }

        tableView.reloadData()
    }



    private func hideAddButton() {
        navigationItem.rightBarButtonItem = nil
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          visibleNotifications.count
      }

      func tableView(
          _ tableView: UITableView,
          cellForRowAt indexPath: IndexPath
      ) -> UITableViewCell {

          guard let cell = tableView.dequeueReusableCell(
              withIdentifier: NotificationCell.reuseID,
              for: indexPath
          ) as? NotificationCell else {
              return UITableViewCell()
          }

          let notification = visibleNotifications[indexPath.row]
          cell.configure(with: notification)
          
          
          return cell
      }
    
    var selectedNotif: NotificationModel!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            selectedNotif = visibleNotifications[indexPath.row]
       
        if selectedNotif.type == .announcement {
            // Perform the segue
            performSegue(withIdentifier: "ShowNotifDetailSegue", sender: self)
        }else{
            //go to the ticket itself
        }
    }
    
    
    private func loadTestUser(uid: String) {
        Firestore.firestore()
            .collection("User")
            .document(uid)
            .getDocument { [weak self] snapshot, error in

                guard let self else { return }

                if let error {
                    print("❌ Failed to fetch user:", error)
                    return
                }

                guard
                    let snapshot,
                    let user = User(document: snapshot)
                else {
                    print("❌ Invalid user document")
                    return
                }

                DispatchQueue.main.async {
                    self.currentUser = user
                    self.configureUI()

                    self.notificationService.startListening { [weak self] notifications in
                        guard let self else { return }

                        DispatchQueue.main.async {
                            self.notifications = notifications
                            self.applyVisibilityFilter()
                        }
                    }
                }

            }
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNotifDetailSegue",
           let notifVC = segue.destination as? NotifDetailViewController {
            notifVC.currentUser = currentUser
            notifVC.notification = selectedNotif
            notifVC.title = selectedNotif?.title
        }
    }
}

import FirebaseFirestore

extension NotificationModel {

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let title = data["title"] as? String,
            let typeRaw = data["type"] as? Int,
            let description = data["description"] as? String,
            let type = NotiType(rawValue: typeRaw),
            let toWhoStrings = data["toWho"] as? [String],
            let createdByString = data["createdBy"] as? String,
            let createdOnTimestamp = data["createdOn"] as? Timestamp,
            let modifiedOnTimestamp = data["modifiedOn"] as? Timestamp,
            let modifiedByString = data["modifiedBy"] as? String,
            let inactive = data["inactive"] as? Bool,
            let requestRef =  data["requestRef"] as? String
        else {
            print("Notif nill")
            return nil
        }

        self.id = document.documentID

        self.title = title
        self.description = description

        
        self.toWho = toWhoStrings

        self.type = type
        self.requestRef = requestRef

        self.createdOn = createdOnTimestamp.dateValue()
        self.createdBy = createdByString


        self.modifiedOn = modifiedOnTimestamp.dateValue()
        self.modifiedBy = modifiedByString
        self.inactive = inactive
    }
}

extension User {

    init?(document: DocumentSnapshot) {
        let data = document.data()

        guard
            let data,
            let userNo = data["userNo"] as? String,
            let fullName = data["fullName"] as? String,
            let typeRaw = data["type"] as? Int,
            let email = data["email"] as? String,
            let createdOnTimestamp = data["createdOn"] as? Timestamp,
            let createdByString = data["createdBy"] as? String,
            let inactive = data["inactive"] as? Bool
        else {
            return nil
        }


        self.id = document.documentID


        self.userNo = userNo
        self.fullName = fullName
        
        let type = UserType(rawValue: typeRaw)!
        self.type = type

        // Subtype is optional
        if self.type == .admin {
            self.subtype = nil
        } else if let subtypeRaw = data["subtype"] as? Int,
                  let subtype = SubType(rawValue: subtypeRaw) {
            self.subtype = subtype
        } else {
            self.subtype = nil
        }

        
        self.email = email
        self.createdOn = createdOnTimestamp.dateValue()
        self.createdBy = createdByString
        
       
        self.modifiedOn = nil
        self.modifiedBy = nil
        self.inactive = inactive
    }
}
