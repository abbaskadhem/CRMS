//
//  Notification.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

// MARK: - Notification
struct NotificationModel: Codable, Identifiable {
var id: UUID // UUID
var title: String // Title
var description: String? // Description
var toWho: [UUID] // To who
var type: String? // Type
var requestRef: UUID? // Request Ref.

// Default Common Fields
var createdOn: Date // Created on
var createdBy: UUID // Created by
var modifiedOn: Date? // Modified on
var modifiedBy: UUID? // Modified by
var inactive: Bool // Inactive
}
