import Foundation

@MainActor
final class RequestDetailViewModel: ObservableObject {

    // Published properties that update the UI when changed
    @Published var estimatedFrom: Date?
    @Published var estimatedTo: Date?
    @Published var status: Status

    // Unique identifier of the request (matches Firestore document ID)
    private let requestId: UUID

    // Repository responsible for all request-related Firestore operations
    private let repo: RequestRepository

    // Firebase Auth UID of the user who modifies the request
    private let modifiedBy: String

    // Initializes the view model with request information and dependencies
    init(
        requestId: UUID,
        initialStatus: Status,
        repo: RequestRepository,
        modifiedBy: String = SessionManager.shared.currentUserId ?? ""
    ) {
        self.requestId = requestId
        self.status = initialStatus
        self.repo = repo
        self.modifiedBy = modifiedBy
    }

    // Loads the request details from the repository and updates local state
    func load() async {
        guard let req = await repo.fetchRequest(by: requestId) else { return }
        estimatedFrom = req.estimatedStartDate
        estimatedTo   = req.estimatedEndDate
        status        = req.status
    }

    // Marks the request as started and refreshes its data
    func startWork() async {
        await repo.start(requestId: requestId)
        await load()
    }

    // Marks the request as completed and refreshes its data
    func completeWork() async {
        await repo.markCompleted(requestId: requestId)
        await load()
    }

    // Schedules the request with estimated start and end dates
    // Then updates the status automatically if needed
    func schedule(from: Date, to: Date) async {
        await repo.schedule(requestId: requestId, from: from, to: to)
        await load()
        await autoUpdateStatusIfNeeded()
    }

    // Automatically updates the request status based on current time
    // Does not override completed or cancelled statuses
    func autoUpdateStatusIfNeeded() async {
        guard let from = estimatedFrom, let to = estimatedTo else { return }
        let now = Date()

        // Do not modify terminal states
        if status == .completed || status == .cancelled {
            return
        }

        // Before scheduled start time, ensure status is assigned
        if now < from {
            if status != .assigned {
                await repo.updateStatus(
                    requestId: requestId,
                    status: .assigned,
                    modifiedBy: modifiedBy
                )
                await load()
            }
            return
        }

        // During scheduled window, do nothing
        if now >= from && now < to {
            return
        }

        // After scheduled end time, mark as delayed if not completed
        if now >= to {
            if status != .delayed {
                await repo.updateStatus(
                    requestId: requestId,
                    status: .delayed,
                    modifiedBy: modifiedBy
                )
                await load()
            }
        }
    }

    // Sends the request back to on-hold state with a reason
    func sendBack(reason: String) async {
        await repo.sendBack(
            requestId: requestId,
            reason: reason,
            modifiedBy: modifiedBy
        )
        await load()
    }
}
