//
//  Request.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
import Foundation

// MARK: - Request
struct Request: Codable, Identifiable {
    var id: UUID                     // UUID
    var requestNo: String            // Request No.
    var requesterRef: UUID           // Requester Ref.
    var requestCategoryRef: UUID     // Request Category Ref.
    var requestSubcategoryRef: UUID  // Request Subcategory Ref.
    var buildingRef: UUID            // Building Ref.
    var roomRef: UUID                // Room Ref.
    var description: String          // Description
    var images: [String]             // Images (URLs or paths)
    var priority: String             // Priority
    var status: String               // Status
    var servicerRef: UUID?           // Servicer Ref. (optional)
    var startDate: Date?             // Start Date
    var endDate: Date?               // End Date
    var ownerId: UUID                // Owner ID
    var stars: Int?                  // Stars (optional rating)
    var feedbackText: String?        // Feedback text (optional)

    // Default Common Fields
    var createdOn: Date              // Created on
    var createdBy: UUID              // Created by
    var modifiedOn: Date?            // Modified on
    var modifiedBy: UUID?            // Modified by
    var inactive: Bool               // Inactive
}

// MARK: - RequestHistory
struct RequestHistory: Codable, Identifiable {
    var id: UUID                 // UUID
    var recordNo: String         // Record No.
    var requestRef: UUID         // Request Ref.
    var action: String           // Action
    var sentBackReason: String?  // Sent back reason (optional)
    var reassignReason: String?  // Reassign reason (optional)
    var dateTime: Date           // Date/Time

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: UUID          // Created by
    var modifiedOn: Date?        // Modified on
    var modifiedBy: UUID?        // Modified by
    var inactive: Bool           // Inactive
}
