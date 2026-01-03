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
var id: String // UUID
var title: String // Title
var description: String? // Description
var toWho: [String] // To who
var type: NotiType // Type
var requestRef: String? // Request Ref.

// Default Common Fields
var createdOn: Date // Created on
var createdBy: String // Created by
var modifiedOn: Date? // Modified on
var modifiedBy: String? // Modified by
var inactive: Bool // Inactive
}

