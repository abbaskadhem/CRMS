



import SwiftUI

extension Status {
    var color: Color {
        switch self {
        case .completed: return .green
        case .inProgress: return .yellow
        case .submitted: return .blue
        case .onHold: return .orange
        case .cancelled: return .red
        case .delayed: return .gray
        case .assigned: return .purple
        }
    }
}

