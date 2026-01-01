//
//  Location.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

// MARK: - Building
struct Building: Codable, Identifiable {
    var id: UUID                 // UUID
    var buildingNo: String       // Building No.

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: String        // Created by (Firebase Auth UID)
    var modifiedOn: Date?        // Modified on
    var modifiedBy: String?      // Modified by (Firebase Auth UID)
    var inactive: Bool           // Inactive
}

// MARK: - Room
struct Room: Codable, Identifiable {
    var id: UUID                 // UUID
    var roomNo: String           // Room No.
    var buildingRef: UUID        // Building Ref.

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: String        // Created by (Firebase Auth UID)
    var modifiedOn: Date?        // Modified on
    var modifiedBy: String?      // Modified by (Firebase Auth UID)
    var inactive: Bool           // Inactive
}
