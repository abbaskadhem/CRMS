import Foundation
import Combine
import FirebaseFirestore

// ViewModel responsible for loading, filtering, and preparing requests for the UI
final class RequestListViewModel: ObservableObject {
    
    // Requests already mapped to UI-friendly models
    @Published var requestsUI: [RequestUIModel] = []
    
    // Search text entered by the user
    @Published var searchText: String = ""
    
    // Active filter configuration
    @Published var filter = RequestFilter()
    
    // Repository that communicates with Firestore
    private let repo: FirestoreRequestRepository
    
    // Firestore listener for real-time updates
    private var listener: ListenerRegistration?
    
    // Shared data manager that holds buildings, rooms, and categories
    private let dataManager = DataManager.shared
    
    // Combine cancellables for observers
    private var cancellables = Set<AnyCancellable>()
    
    // Raw request models fetched from Firestore
    private var rawRequests: [Request] = []
    
    // Initializes the view model and starts listening to required data sources
    init(
        repo: FirestoreRequestRepository = FirestoreRequestRepository(
            currentUserId: SessionManager.shared.currentUserId ?? ""
        )
    ) {
        self.repo = repo

        // Rebuild UI whenever buildings data changes
        dataManager.$buildings
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.rebuildUI() }
            .store(in: &cancellables)

        // Rebuild UI whenever rooms data changes
        dataManager.$rooms
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.rebuildUI() }
            .store(in: &cancellables)

        // Rebuild UI whenever categories data changes
        dataManager.$categories
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.rebuildUI() }
            .store(in: &cancellables)

        // Start listening to requests assigned to the current user
        startListening()
    }
    
    // Remove Firestore listener when the view model is deallocated
    deinit {
        listener?.remove()
    }
    
    // Starts listening to request updates from Firestore
    private func startListening() {
        listener = repo.listenMyRequests { [weak self] requests in
            self?.rawRequests = requests
            self?.rebuildUI()
        }
    }
    
    // Converts raw request models into UI models with resolved names
    private func rebuildUI() {
        self.requestsUI = rawRequests.map { request in
            
            let bName = dataManager.getBuildingName(by: request.buildingRef)
            let rName = dataManager.getRoomName(by: request.roomRef)
            
            let mainName = dataManager.getMainCategoryName(by: request.requestCategoryRef)
            let subName  = dataManager.getMainCategoryName(by: request.requestSubcategoryRef)
            
            return RequestUIModel(
                id: request.id.uuidString,
                requestNo: request.requestNo,
                description: request.description,
                imageURLs: request.images ?? [],
                buildingName: bName,
                roomName: rName,
                mainCategoryName: mainName,
                subCategoryName: subName,
                priority: request.priority ?? .low,
                status: request.status,
                createdOn: request.createdOn
            )
        }
    }
    
    // Returns requests filtered by search text, status, and date range
    var filteredRequests: [RequestUIModel] {
        var result = requestsUI
        
        // Filter by search query
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            result = result.filter {
                $0.requestNo.lowercased().contains(q)
                || $0.buildingName.lowercased().contains(q)
                || $0.roomName.lowercased().contains(q)
                || $0.mainCategoryName.lowercased().contains(q)
                || $0.subCategoryName.lowercased().contains(q)
            }
        }
        
        // Filter by selected statuses
        if !filter.statuses.isEmpty {
            result = result.filter { filter.statuses.contains($0.status) }
        }
        
        // Filter by start date
        if let from = filter.fromDate {
            let start = Calendar.current.startOfDay(for: from)
            result = result.filter { $0.createdOn >= start }
        }
        
        // Filter by end date
        if let to = filter.toDate {
            let endExclusive = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Calendar.current.startOfDay(for: to)
            )!
            result = result.filter { $0.createdOn < endExclusive }
        }
        
        return result
    }
    //ينحذف
    
    // Resets all filters to their default state
    func resetFilters() {
        filter = RequestFilter()
    }
}
