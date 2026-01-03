//
//  User.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

enum UserType: Int, Codable {
    case admin = 1000
    case requester = 1001
    case servicer = 1002
}

enum SubType: Int, Codable {
    case admin = 1000
    case student = 1001
    case staff = 1002
    case maintenance = 1003
    case technician = 1004
}

// MARK: - User
/// User document in Firestore. The document ID is the Firebase Auth UID.
struct User: Codable, Identifiable {
    var id: String               // Firebase Auth UID (document ID)
    var fullName: String         // Full Name
    var type: UserType           // Type (Admin/Requester/Servicer)
    var subtype: SubType?        // Subtype (optional)
    var email: String            // Email
}
