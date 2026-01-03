//
//  NotificationsViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 29/12/2025.
//

import UIKit
import FirebaseFirestore

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Variables
    var user : User?
    
    private let notificationService = NotificationService()
    private var notifications: [NotificationModel] = []
    private var visibleNotifications: [NotificationModel] = []
    var selectedNotif: NotificationModel!
    private var isAdmin: Bool {
        user?.type == .admin
    }

    private var filterFromDate: Date?
    private var filterToDate: Date?


    @IBOutlet weak var tableView: UITableView!
    
    

    func loadUser() async {
        do {
            let currentUser = try await SessionManager.shared.getCurrentUser()
            user = currentUser
            print(currentUser.fullName)
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        notificationService.startListening { [weak self] notifications in
            guard let self else { return }

            DispatchQueue.main.async {
                self.notifications = notifications
                self.applyVisibilityFilter()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

           Task {
               await loadUser()
               guard user != nil else { return }
               
               
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
    
    
    //MARK: Config UI
    private func configureUI() {

        if !isAdmin {
            hideAddButton()
        }

        setupTableView()
    }

    //MARK: Setup table
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
    
    //MARK: Apply Visibility Filter
    private func applyVisibilityFilter() {
        guard let user else {
            visibleNotifications = []
            tableView.reloadData()
            return
        }

        var result = notifications.filter { notification in
            switch notification.type {

            case .announcement:
                if isAdmin && notification.createdBy == user.id {
                    return true
                }
                return notification.toWho.contains(user.id)

            case .notification:
                return notification.toWho.contains(user.id)
            }
        }

        // Apply date filter if active
        if let from = filterFromDate {
            result = result.filter { $0.createdOn >= from }
        }

        if let to = filterToDate {
            result = result.filter { $0.createdOn <= to }
        }

        visibleNotifications = result
        tableView.reloadData()
    }



    //MARK: Hide Buttons
    private func hideAddButton() {
        navigationItem.rightBarButtonItem = nil
    }


    //MARK: Table: number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          visibleNotifications.count
      }

    //MARK: Table: cell For Row At
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
    
    
    //MARK: Table: did Select Row At
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            selectedNotif = visibleNotifications[indexPath.row]
       
        if selectedNotif.type == .announcement {
            // Perform the segue
            performSegue(withIdentifier: "ShowNotifDetailSegue", sender: self)
        }else{
            //go to the ticket itself
            performSegue(withIdentifier: "ShowNotifSegue", sender: self)
        }
    }
    
    
    @IBAction func createBtnTapped(_ sender: Any) {
  
        performSegue(withIdentifier: "ShowCreateSegue", sender: self)
        
    }
    
    //MARK: Filter
    @IBAction func filterBtnTapped(_ sender: Any) {
        let vc = NotificationFilterViewController()

           vc.onApply = { [weak self] from, to in
               self?.applyDateFilter(from: from, to: to)
           }

           vc.onClear = { [weak self] in
               self?.clearDateFilter()
           }

           if let sheet = vc.sheetPresentationController {
               sheet.detents = [.medium()]
               sheet.prefersGrabberVisible = true
               sheet.preferredCornerRadius = 20
           }

           present(vc, animated: true)
    }
    
    //MARK: Date Filter
    private func applyDateFilter(from: Date?, to: Date?) {
        filterFromDate = from
        filterToDate = to
        applyVisibilityFilter()
    }
    
    //MARK: Clear Filter
    private func clearDateFilter() {
        filterFromDate = nil
        filterToDate = nil
        applyVisibilityFilter()
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
        
        
        //TODO: Navigate to the request detail page
//        if segue.identifier == "ShowNotifSegue",
//           let vc = segue.destination as? NotifViewController {
//            vc.currentUser = user
//            vc.reguestRef = selectedNotif.requestRef
//        }
    }
}

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
