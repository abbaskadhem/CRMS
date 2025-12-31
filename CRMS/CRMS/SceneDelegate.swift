//
//  SceneDelegate.swift
//  CRMS
//
//  Created by Hoor Hasan on 26/11/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if remember me is enabled and user is logged in
        let rememberUser = UserDefaults.standard.bool(forKey: "rememberMeButton")
        guard rememberUser, let currentUser = Auth.auth().currentUser else {
            let loginVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            window?.rootViewController = loginVC
            window?.makeKeyAndVisible()
            return
        }
        
        // Check user role if credentials exist
        checkUserRole(for: currentUser)
    }
    
    // Check for role function (non-async callback version)
    private func checkUserRole(for user: FirebaseAuth.User) {
        // Check for connectivity (implement this method or remove)
        Task {
            guard await hasInternetConnection() else {
                showAlert(title: "No Internet", message: "Please check your connection.")
                fallbackToLogin()
                return
            }
            
            let db = Firestore.firestore()
            let userID = user.uid
            
            db.collection("User").document(userID).getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    self.fallbackToLogin()
                    return
                }
                
                // User exists
                guard let snapshot = snapshot, snapshot.exists else {
                    self.showAlert(title: "User Not Found", message: "No user found with this ID.")
                    self.fallbackToLogin()
                    return
                }
                
                // Fetch role type
                let role = snapshot.get("type") as? Int ?? -1

                // TODO: Create separate storyboards/tab bar controllers for Servicer and Requester roles
                // Currently all roles use Admin.storyboard as a temporary solution
                let adminStoryboard = UIStoryboard(name: "Admin", bundle: nil)
                var vc: UIViewController?

                // Navigate based on user role
                switch role {
                case 1000: // admin
                    vc = adminStoryboard.instantiateInitialViewController()
                case 1002: // servicer
                    vc = adminStoryboard.instantiateInitialViewController()
                case 1001: // requester
                    vc = adminStoryboard.instantiateInitialViewController()
                default:
                    self.showAlert(title: "Invalid Role", message: "Unknown user role.")
                    self.fallbackToLogin()
                    return
                }
                
                if let vc = vc {
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func fallbackToLogin() {
        let loginVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Safely present from root view controller chain
        if let presentedVC = window?.rootViewController?.presentedViewController {
            presentedVC.present(alert, animated: true)
        } else {
            window?.rootViewController?.present(alert, animated: true)
        }
    }
    
    // MARK: - Network Check (implement based on your needs)
    private func hasInternetConnection() async -> Bool {
        // Simple Reachability check - implement your preferred method
        // For now, return true or use NWPathMonitor
        return true
    }

        
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
        
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
        
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
        
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


    
    // MARK: - Scene Lifecycle
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

}
