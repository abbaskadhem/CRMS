
import SwiftUI
extension Priority {
    var color: Color {
        switch self {
        case .high: return .red
        case .moderate: return .orange
        case .low: return .green
        }
    }
}
