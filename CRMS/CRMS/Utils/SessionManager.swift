//
//  SessionManager.swift
//  CRMS
//
//  Created by Abbas on 03/12/2025.
//

import Foundation
import FirebaseAuth

enum SessionError: LocalizedError {
    case notLoggedIn

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "No user is currently logged in."
        }
    }
}

final class SessionManager {
    static let shared = SessionManager()

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
}
