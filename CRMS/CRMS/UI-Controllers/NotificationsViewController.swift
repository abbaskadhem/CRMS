//
//  NotificationsViewController.swift
//  CRMS
//
//  Displays user notifications
//

import UIKit

final class NotificationsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView?

    // MARK: - Properties
    private var notifications: [NotificationModel] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchNotifications()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppColors.background

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = AppColors.background
        tableView?.separatorStyle = .none
    }

    // MARK: - Data Fetching

    private func fetchNotifications() {
        Task {
            do {
                let userId = try SessionManager.shared.requireUserId()
                let fetched = try await NotificationController.shared.getNotifications(forUserId: userId)
                await MainActor.run {
                    self.notifications = fetched
                    self.tableView?.reloadData()
                }
            } catch {
                await MainActor.run {
                    print("Error fetching notifications: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let notification = notifications[indexPath.row]

        cell.textLabel?.text = notification.title
        cell.detailTextLabel?.text = notification.description
        cell.backgroundColor = AppColors.background
        cell.textLabel?.textColor = AppColors.text
        cell.detailTextLabel?.textColor = AppColors.secondary

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
