//
//  FAQ.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

// MARK: - FAQ
struct FAQ: Codable, Identifiable {
    var id: UUID             // UUID
    var question: String     // Question
    var answer: String       // Answer

    // Default Common Fields
    var createdOn: Date?     // Created on
    var createdBy: String?   // Created by (Firebase Auth UID)
    var modifiedOn: Date?    // Modified on
    var modifiedBy: String?  // Modified by (Firebase Auth UID)
    var inactive: Bool?      // Inactive
}
