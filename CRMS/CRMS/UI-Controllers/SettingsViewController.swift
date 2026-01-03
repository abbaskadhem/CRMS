//
//  SettingsViewController.swift
//  CRMS
//
//Created by Maryam Abdulla
//Handels user settings including profile, preferences, support & information and logout functionality
//
import UIKit
import FirebaseAuth
import FirebaseFirestore


class SettingsViewController: UIViewController {

// MARK: - Outlet
    //Profile
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var profile: UIView!
    
    //Toggles
    @IBOutlet weak var mode: UISwitch!
    @IBOutlet weak var notification: UISwitch!
    
   //About App, FAQ and Logout
    @IBOutlet var aboutApp: UIView!
    @IBOutlet weak var faq: UIView!
    @IBOutlet weak var logOut: UIView!
   
    
    // MARK: - UserDefaults Keys
    private let notificationsKey = "notificationsEnabled"
    private let darkModeKey = "darkModeEnabled"

    // MARK: - Firestore
    private let db = Firestore.firestore()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSwitches()
        fetchUserProfile()

    }
    
    // MARK: - UI Setup
    ///Configure static UI e;ements and gesture recognizers
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        //Profile image styling
        img.image = UIImage(systemName: "person.fill")
        img.tintColor = .white
        img.backgroundColor = .systemGray2
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = 50
        img.clipsToBounds = true
        
        //About App tab gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(aboutAppTapped))
        aboutApp.isUserInteractionEnabled = true
        aboutApp.addGestureRecognizer(tapGesture)
        
        //FAQ tab gesture
        /*
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(faqTapped))
        faq.isUserInteractionEnabled = true
        faq.addGestureRecognizer(tapGesture2)
         */
    
        //Logout tab gesture
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        logOut.isUserInteractionEnabled = true
        logOut.addGestureRecognizer(tapGesture3)
    }
    // MARK: - Switch Setup
    ///Loads saved switches states and applies them
    private func setupSwitches() {
        notification.isOn = UserDefaults.standard.bool(forKey: notificationsKey)
        mode.isOn = UserDefaults.standard.bool(forKey: darkModeKey)

        notification.onTintColor = AppColors.secondary
        mode.onTintColor = AppColors.secondary

        applyInterfaceStyle(dark: mode.isOn)
    }

    // MARK: - Fetch Profile
    ///Fetch user profile information from Firestore
    private func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("User").document(uid).getDocument { [weak self] snapshot, _ in
            guard let data = snapshot?.data() else { return }

            self?.name.text = data["fullName"] as? String ?? ""
            self?.email.text = data["email"] as? String ?? ""
            self?.role.text = self?.mapRole(from: data["type"] as? Int ?? -1)
        }
    }
    //Convert numeric role value to readable text
    private func mapRole(from role: Int) -> String {
        switch role {
        case 1000: return "Admin"
        case 1001: return "Requester"
        case 1002: return "Servicer"
        default: return "Unknown"
        }
    }
    

    // MARK: - Switch Actions
    ///Saves notification preference
    @IBAction func notificationChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: notificationsKey)
    }

    //Saves theme preference and  applies UI style
    @IBAction func darkModeChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: darkModeKey)
        applyInterfaceStyle(dark: sender.isOn)
    }

    //MARK: - Navigation Actions
    ///Navigate to About App screen
    @objc private func aboutAppTapped() {
        let storyboard = UIStoryboard(name: "AboutApp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AboutAppController")
        navigationController?.pushViewController(vc, animated: true)
    }
    ///Navigate to FAQ screen
/*
    @objc private func faqTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "FAQViewControllers") else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    **/
    
    //Triggers logout confirmation dialog
    @objc private func logoutTapped(){
        showLogoutPopup()
    }


    // MARK: - Dark Mode
    ///Apply dark or light interface
    private func applyInterfaceStyle(dark: Bool) {
        let style: UIUserInterfaceStyle = dark ? .dark : .light
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }

    // MARK: - Logout
    ///Display logout confirmation alert
    private func showLogoutPopup() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.performLogout()
        })

        present(alert, animated: true)
    }
    //Signs out user and reset app to login screen
    private func performLogout() {
        do {
            try Auth.auth().signOut()

        } catch {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        else { return }

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    

}

