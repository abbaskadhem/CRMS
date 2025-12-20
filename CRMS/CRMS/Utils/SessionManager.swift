//
//  SessionManager.swift
//  CRMS
//
//  Created by BP-36-201-10 on 03/12/2025.
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

    var currentUserId: UUID? {
        UUID(uuidString: Auth.auth().currentUser?.uid ?? "")
    }

    func requireUserId() throws -> UUID {
        guard let id = currentUserId else {
            throw SessionError.notLoggedIn
        }
        return id
    }
}
