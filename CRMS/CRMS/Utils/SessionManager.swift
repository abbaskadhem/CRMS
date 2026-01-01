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
    
    func getCurrentUser() async throws -> User {
        let userId = try requireUserId()
        
        let document = try await db.collection("User").document(userId).getDocument()
        
        guard let data = document.data() else {
            throw SessionError.userDataNotFound
        }
        
        let email = currentUserEmail ?? ""
        let name = currentUserDisplayName ?? ""
        let type = data["type"] as? Int ?? -1
        let userNo = data["userNo"] as? String ?? ""
        let subtype = data["subtype"] as? Int
        let createdOn = data["createdOn"] as? Date ?? Date()
        let createdBy = data["createdBy"] as? String ?? ""
        let modifiedOn = data["modifiedOn"] as? Date ?? nil
        let modifiedBy = data["modifiedBy"] as? String ?? nil
        let inactive: Bool = (data["inactive"] != nil)
        
        //get the type valye from UserType
        guard let userType = UserType(rawValue: type) else {
            throw SessionError.userDataNotFound
        }
        //get the subtype
        let finalSubType = subtype.flatMap { SubType(rawValue: $0) }

        return User(
            id: userId,
            userNo: userNo,
            fullName: name,
            type: userType,
            subtype: finalSubType,
            email: email,
            createdOn: createdOn,
            createdBy: createdBy,
            modifiedOn: modifiedOn,
            modifiedBy: modifiedBy,
            inactive: inactive
            
        )
    }
    
    func fetchUserIDs(subtype: SubType) async -> [String] {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("User")
                .whereField("subtype", isEqualTo: subtype.rawValue)
                .whereField("inactive", isEqualTo: false)
                .getDocuments()

            return snapshot.documents.map { $0.documentID }
        } catch {
            return []
        }
    }

}
