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
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
         
        window = UIWindow(windowScene: windowScene)
         
        //check if there if any stored credentials
        guard let rememberUser = UserDefaults.standard.bool(forKey: "rememberMeButton"), let currentUser = Auth.auth().currentUser else {
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            self.window?.rootViewController = loginVC
            self.window?.makeKeyAndVisible()
            return
        }

        //call check user role if credentials exist 
        checkUserRole(for: user)
        
    }
         
    //check for role function
    private func checkUserRole(for user: User) async throws -> String {
        
        //check for connectivity
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }
        
        let db = Firestore.firestore()
        let userID = user.uid
        
        do {
            try db.collection("User").document(userID).getDocument {
                [weak self] document, error in
                guard let self = self else {
                    return
                }
                
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                //user exist
                guard let document = document, document.exists else {
                    self.showAlert(title: "User Not Found", message: "No user found with this ID.")
                    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                    self.window?.rootViewController = loginVC
                    self.window?.makeKeyAndVisible()
                    return
                }
                
                //fetch role type
                let role = document.get("type") as? Int ?? -1
                    
                var vc : UIViewController?
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                // Navigate based on user role
                if role == 1000 { //admin
                    vc = storyboard.instantiateViewController(withIdentifier: "AdminHomeViewController")
                }
                else if role == 1002 { //servicer
                    vc = storyboard.instantiateViewController(withIdentifier: "ServicerHomeViewController")
                }
                else if role == 1001 { //requester
                    vc = storyboard.instantiateViewController(withIdentifier: "RequesterHomeViewController")
                }

                if let vc = vc {
                    window?.rootViewController = vc
                    window?.makeKeyAndVisible()
                }
            }
        }
        catch {
            throw NetworkError.serviceUnavailable
        }
    }
        
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
        
}
