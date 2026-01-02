//
//  Notification.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

enum NotiType: Int, Codable {
    case notification = 1000
    case announcement = 1001
}

// MARK: - Notification
struct NotificationModel: Codable, Identifiable {
    var id: UUID             // UUID
    var title: String        // Title
    var description: String? // Description
    var toWho: [String]      // To who (Firebase Auth UIDs)
    var type: NotiType       // Type
    var requestRef: UUID?    // Request Ref.

    // Default Common Fields
    var createdOn: Date      // Created on
    var createdBy: String    // Created by (Firebase Auth UID)
    var modifiedOn: Date?    // Modified on
    var modifiedBy: String?  // Modified by (Firebase Auth UID)
    var inactive: Bool       // Inactive
}
