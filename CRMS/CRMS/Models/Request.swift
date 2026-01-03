//
//  Request.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
import Foundation
import UIKit

// MARK: - Priority Enum

/// Request priority levels
enum Priority: Int, Codable {
    case low = 1000
    case moderate = 1001
    case high = 1002
}

// MARK: - Priority Display Extension

extension Priority {
    /// Returns the display color for this priority level
    var displayColor: UIColor {
        switch self {
        case .low:
            return .systemGreen
        case .moderate:
            return .systemOrange
        case .high:
            return .systemRed
        }
    }

    /// Returns the display string for this priority level
    var displayString: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        }
    }
}

// MARK: - Status Enum

/// Request status values representing the lifecycle of a request
enum Status: Int, Codable {
    case submitted = 1000
    case assigned = 1001
    case inProgress = 1002
    case onHold = 1003
    case cancelled = 1004
    case delayed = 1005
    case completed = 1006
}

// MARK: - Status Display Extension

extension Status {
    /// Returns the display color for this status using AppColors
    var displayColor: UIColor {
        switch self {
        case .submitted:
            return AppColors.statusSubmitted
        case .assigned:
            return AppColors.statusAssigned
        case .inProgress:
            return AppColors.statusInProgress
        case .onHold:
            return AppColors.statusOnHold
        case .cancelled:
            return AppColors.statusCancelled
        case .delayed:
            return AppColors.statusDelayed
        case .completed:
            return AppColors.statusCompleted
        }
    }

    /// Returns the display string for this status
    var displayString: String {
        switch self {
        case .submitted:
            return "Submitted"
        case .assigned:
            return "Assigned"
        case .inProgress:
            return "In Progress"
        case .onHold:
            return "On Hold"
        case .cancelled:
            return "Cancelled"
        case .delayed:
            return "Delayed"
        case .completed:
            return "Completed"
        }
    }
}

// MARK: - Action Enum

/// Actions that can be performed on a request (used in history records)
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
    var requesterRef: String         // Requester Ref. (Firebase Auth UID)
    var requestCategoryRef: UUID     // Request Category Ref.
    var requestSubcategoryRef: UUID  // Request Subcategory Ref.
    var buildingRef: UUID            // Building Ref.
    var roomRef: UUID                // Room Ref.
    var description: String          // Description
    var images: [String]?            // Images (URLs or paths)
    var priority: Priority?          // Priority
    var status: Status               // Status
    var servicerRef: String?         // Servicer Ref. (Firebase Auth UID, optional)
    var estimatedStartDate: Date?    // Estimated start date the servicer schedueles
    var estimatedEndDate: Date?      // Estimated end date the servicer schedueles
    var actualStartDate: Date?       // Actual Start Date (when servicer clicks start, this is set)
    var actualEndDate: Date?         // Actual End Date (when servicer clicks complete, this is set)
    var ownerId: String              // Owner ID (Firebase Auth UID)

    // Default Common Fields
    var createdOn: Date              // Created on
    var createdBy: String            // Created by (Firebase Auth UID)
    var modifiedOn: Date?            // Modified on
    var modifiedBy: String?          // Modified by (Firebase Auth UID)
    var inactive: Bool               // Inactive
}

// MARK: - RequestHistory
struct RequestHistory: Codable, Identifiable {
    var id: UUID                 // UUID
    var historyNo: String        // Record No.
    var requestRef: UUID         // Request Ref.
    var action: Action           // Action
    var sentBackReason: String?  // Sent back reason (optional)
    var reassignReason: String?  // Reassign reason (optional)

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: String        // Created by (Firebase Auth UID)
    var modifiedOn: Date?        // Modified on
    var modifiedBy: String?      // Modified by (Firebase Auth UID)
    var inactive: Bool           // Inactive
}

// MARK: - RequestFeedback
struct RequestFeedback: Codable, Identifiable {
    var id: UUID                 // UUID
    var feedbackNo: String       // Record No.
    var requestRef: UUID         // Request Ref.
    var requesterRef: String     // Requester Ref. (Firebase Auth UID)
    var servicerRef: String      // Servicer Ref. (Firebase Auth UID)
    var starRating: Int          // Stars
    var feedbackText: String     // Feedback text

    // Default Common Fields
    var createdOn: Date          // Created on
    var createdBy: String        // Created by (Firebase Auth UID)
    var modifiedOn: Date?        // Modified on
    var modifiedBy: String?      // Modified by (Firebase Auth UID)
    var inactive: Bool           // Inactive
}
