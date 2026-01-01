//
//  SessionManager.swift
//  CRMS
//
//  Created by Abbas on 03/12/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum SessionError: LocalizedError {
    case notLoggedIn
    case userDataNotFound

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "No user is currently logged in."
        case .userDataNotFound:
            return "User data not found in database."
        }
    }
}

final class SessionManager {
    static let shared = SessionManager()
    
    private let db = Firestore.firestore()

    private init() {}

    /// The current Firebase Auth user ID
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    /// The current Firebase Auth user email
    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }

    /// The current Firebase Auth user display name
    var currentUserDisplayName: String? {
        Auth.auth().currentUser?.displayName
    }

    /// Clears the current user session (signs out of Firebase Auth)
    func clearSession() throws {
        try Auth.auth().signOut()
    }

    func requireUserId() throws -> String {
        guard let id = currentUserId else {
            throw SessionError.notLoggedIn
        }
        return id
    }
    
    /// Returns the user type (1000, 1001, or 1002)
    func getUserType() async throws -> Int {
        let userId = try requireUserId()
        
        let document = try await db.collection("User").document(userId).getDocument()
        
        guard let type = document.data()?["type"] as? Int else {
            throw SessionError.userDataNotFound
        }
        
        return type
    }
}
