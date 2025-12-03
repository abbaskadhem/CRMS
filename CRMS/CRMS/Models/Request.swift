//
//  Request.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
import Foundation

enum Priority: Int, Codable {
    case low = 1000
    case moderate = 1001
    case high = 1002
}

enum Status: Int, Codable {
    case submitted = 1000
    case assigned = 1001
    case inProgress = 1002
    case onHold = 1003
    case cancelled = 1004
    case delayed = 1005
    case completed = 1006
}

enum Action: Int, Codable {
    case submitted = 1000
    case assigned = 1001
    case sentBack = 1002
    case scheduled = 1003
    case started = 1004
    case completed = 1005
    case delayed = 1006
    case reassigned = 1007
}

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
    var images: [String]?            // Images (URLs or paths)
    var priority: Priority           // Priority
    var status: Status               // Status
    var servicerRef: UUID?           // Servicer Ref. (optional)
    var estimatedStartDate: Date?    // Estimated start date the servicer schedueles
    var estimatedEndDate: Date?      // Estimated end date the servicer schedueles
    var actualStartDate: Date?       // Actual Start Date (when servicer clicks start, this is set)
    var actualEndDate: Date?         // Actual End Date (when servicer clicks complete, this is set)
    var ownerId: UUID                // Owner ID

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
    var action: Action           // Action
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

// MARK: - RequestFeedback
struct RequestFeedback: Codable, Identifiable {
    var id: UUID                 // UUID
    var recordNo: String         // Record No.
    var requestRef: UUID         // Request Ref.
    var requesterRef: UUID       // Requester Ref.
    var servicerRef: UUID        // Servicer Ref.
    var starRating: Int          // Stars
    var feedbackText: String     // Feedback text

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: UUID          // Created by
    var modifiedOn: Date?        // Modified on
    var modifiedBy: UUID?        // Modified by
    var inactive: Bool           // Inactive
}
