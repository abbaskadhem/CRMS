import Foundation

// Adds user friendly text representations for each request status
extension Status {

    // A readable name that can be displayed directly in the UI
    var displayName: String {
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
