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
    case student = 1000
    case staff = 1001
    case maintenance = 1002
    case technician = 1003
}

// MARK: - User
struct User: Codable, Identifiable {
    var id: String                 // UUID
    var userNo: String           // User No.
    var fullName: String         // Full Name
    var type: UserType           // Type (Admin/Requester/Servicer)
    var subtype: SubType?        // Subtype (optional)
    var email: String            // Email

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: String          // Created by
    var modifiedOn: Date?        // Modified on
    var modifiedBy: String?        // Modified by
    var inactive: Bool           // Inactive
}


