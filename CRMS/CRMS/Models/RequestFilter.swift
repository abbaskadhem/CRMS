import Foundation

struct RequestFilter {
    var fromDate: Date? = nil
    var toDate: Date? = nil
    var statuses: Set<Status> = []   // فاضي = All

    var isDefault: Bool {
        fromDate == nil && toDate == nil && statuses.isEmpty
    }
}
