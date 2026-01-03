//
//  RequestDisplayModel.swift
//  CRMS
//
//  Display model for requests with resolved references
//

import Foundation

struct RequestDisplayModel {
    let request: Request
    let buildingNo: String
    let roomNo: String
    let categoryName: String
    let subcategoryName: String

    var requestNo: String { request.requestNo }
    var status: Status { request.status }
    var priority: Priority? { request.priority }
    var createdOn: Date { request.createdOn }
    var description: String { request.description }
    var images: [String]? { request.images }

    // Helper for display
    var locationString: String {
        "Building \(buildingNo) - Room \(roomNo)"
    }

    var categoryString: String {
        "\(categoryName) - \(subcategoryName)"
    }

    var priorityString: String {
        guard let priority = priority else { return "Unassigned" }
        switch priority {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }

    var statusString: String {
        switch status {
        case .submitted: return "Submitted"
        case .assigned: return "Assigned"
        case .inProgress: return "In Progress"
        case .onHold: return "On-Hold"
        case .cancelled: return "Cancelled"
        case .delayed: return "Delayed"
        case .completed: return "Completed"
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: createdOn)
    }
}

// MARK: - RequestHistoryDisplayModel
/// A display model for request history records with formatted data for table view presentation
struct RequestHistoryDisplayModel {
    let history: RequestHistory
    let actionString: String
    let createdByName: String
    let dateString: String
    let hasReason: Bool
    let reasonText: String?
}
