//
//  User.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

enum UserType: String, Codable {
    case admin = "Admin"
    case requester = "Requester"
    case servicer = "Servicer"
}

// MARK: - User
struct User: Codable, Identifiable {
    var id: UUID                 // UUID
    var userNo: String           // User No.
    var fullName: String         // Full Name
    var type: UserType           // Type (Admin/Requester/Servicer)
    var subtype: String?         // Subtype (optional)
    var email: String            // Email
    var hashedPassword: String   // Hashed Password

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: UUID          // Created by
    var modifiedOn: Date?        // Modified on
    var modifiedBy: UUID?        // Modified by
    var inactive: Bool           // Inactive
}


