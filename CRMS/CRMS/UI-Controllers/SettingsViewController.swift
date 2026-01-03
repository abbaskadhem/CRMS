//
//  SettingsViewController.swift
//  CRMS
//
//  User settings and profile management
//

import UIKit
import FirebaseAuth

final class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var logoutButton: UIButton?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserInfo()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppColors.background

        // Style profile image
        profileImageView?.layer.cornerRadius = (profileImageView?.frame.width ?? 80) / 2
        profileImageView?.clipsToBounds = true
        profileImageView?.backgroundColor = AppColors.secondary

        // Style labels
        nameLabel?.textColor = AppColors.text
        emailLabel?.textColor = AppColors.secondary

        // Style logout button
        logoutButton?.backgroundColor = AppColors.error
        logoutButton?.setTitleColor(.white, for: .normal)
        logoutButton?.layer.cornerRadius = AppSize.cornerRadius
    }

    private func loadUserInfo() {
        nameLabel?.text = SessionManager.shared.currentUserDisplayName ?? "User"
        emailLabel?.text = SessionManager.shared.currentUserEmail ?? ""
    }

    // MARK: - Actions

    @IBAction func logoutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try SessionManager.shared.clearSession()

            // Navigate back to login
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    let navController = UINavigationController(rootViewController: loginVC)
                    window.rootViewController = navController
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
