//
//  NotificationsViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 29/12/2025.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user : User?
    func loadUser() async {
        do {
            let currentUser = try await SessionManager.shared.getCurrentUser()
            user = currentUser
            print(currentUser.fullName)
        } catch {
            print(error)
        }
    }

    private var isAdmin: Bool {
        user?.type == .admin
    }

    private let notificationService = NotificationService()
    private var notifications: [NotificationModel] = []
    private var visibleNotifications: [NotificationModel] = []

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
                await loadUser()
                guard let user else { return }

                configureUI()

                notificationService.startListening { [weak self] notifications in
                    guard let self else { return }

                    DispatchQueue.main.async {
                        self.notifications = notifications
                        self.applyVisibilityFilter()
                    }
                }
            }
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
        guard let user else {
            visibleNotifications = []
            tableView.reloadData()
            return
        }

        visibleNotifications = notifications.filter { notification in
            switch notification.type {

            case .announcement:
                // Admin sees announcements he created
                if isAdmin && notification.createdBy == user.id {
                    return true
                }

                // Targeted announcement
                return notification.toWho.contains(user.id)

            case .notification:
                // Notifications are always strictly targeted
                return notification.toWho.contains(user.id)
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
    
    
    @IBAction func createBtnTapped(_ sender: Any) {
  
        performSegue(withIdentifier: "ShowCreateSegue", sender: self)
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNotifDetailSegue",
           let notifVC = segue.destination as? NotifDetailViewController {
            notifVC.currentUser = user
            notifVC.notification = selectedNotif
            notifVC.title = selectedNotif?.title
        }
        
        if segue.identifier == "ShowCreateSegue",
               let vc = segue.destination as? NotifCreateViewController {
                vc.currentUser = user
            }
    }
}

import FirebaseFirestore

extension NotificationModel {

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let title = data["title"] as? String else {
            print("❌ title missing or not String")
            return nil
        }

        guard let typeRaw = data["type"] as? Int else {
            print("❌ type missing or not Int")
            return nil
        }

        guard let type = NotiType(rawValue: typeRaw) else {
            print("❌ invalid NotiType raw value:", typeRaw)
            return nil
        }

        guard let description = data["description"] as? String else {
            print("❌ description missing or not String")
            return nil
        }

        let toWhoStrings = data["toWho"] as? [String] ?? []

        guard let createdByString = data["createdBy"] as? String else {
            print("❌ createdBy missing or not String")
            return nil
        }

        let createdOn: Date? = (data["createdOn"] as? Timestamp)?.dateValue()

        let modifiedOn: Date? = (data["modifiedOn"] as? Timestamp)?.dateValue()

        let modifiedByString: String? = data["modifiedBy"] as? String

        guard let inactive = data["inactive"] as? Bool else {
            print("❌ inactive missing or not Bool")
            return nil
        }

        let requestRef = data["requestRef"] as? String
        
        self.id = document.documentID
        self.title = title
        self.description = description
        self.toWho = toWhoStrings
        self.type = type
        self.requestRef = requestRef
        self.createdOn = createdOn!
        self.createdBy = createdByString
        self.modifiedOn = modifiedOn
        self.modifiedBy = modifiedByString
        self.inactive = inactive
    }
}
