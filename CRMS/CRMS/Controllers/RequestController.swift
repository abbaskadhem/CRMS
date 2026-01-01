//
//  RequestController.swift
//  CRMS
//
//  Created by Abbas on 03/12/2025.
//

import Foundation
import FirebaseFirestore

final class RequestController {

    static let shared = RequestController()

// MARK: - Initializations
    // Starts a Firestore instance for the entire controller
    private let db = Firestore.firestore()

    // Gets the shared session manager for user ID
    private let session = SessionManager.shared

    // Cache for buildings, rooms, and categories
    private var buildingsCache: [UUID: Building] = [:]
    private var roomsCache: [UUID: Room] = [:]
    private var categoriesCache: [UUID: RequestCategory] = [:]
    
// MARK: - Get Priority
    // Function to get the priority based on the cat and subcat
    func getPriority(requestCategoryRef: UUID, requestSubcategoryRef: UUID) -> Priority
    {
        // todo: implement logic to determine priority based on category and subcategory
        return .low
    }

// MARK: - Autonumber Generation
    // Function to get the next autonumber for a given document
    func getNextAutonumber(document: String) async throws -> String {
        
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }
        
        // Gets the reference to the counters collection and the specific document in the param
        
           let ref = db.collection("Counters").document(document)
        
        // Takes a snapshot of the document to read the last number and format to be implemented. In case of failure, defaults ERR is used to signal that an error occured with this request, allowing to track.
        let snapshot = try await ref.getDocument()
        let last = snapshot.data()?["lastNumber"] as? Int ?? 0
        let format = snapshot.data()?["format"] as? String ?? "ERR-%05d"
        let next = last + 1

        // Sets the new last number in the document
        try await ref.setData(["lastNumber": next], merge: true)

        // Returns the formatted request number
        return String(format: format, next)
    }

// MARK: - History Record Creation
    // Function to create a history record for a request. it takes the request ref, action done, and in cases of sent back or reassignment, the reasons for those actions.
    func createHistoryRecord(requestRef: UUID, action: Action, sentBackReason: String?, reassignReason: String?) async throws {
        
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }
        
        let userId = try session.requireUserId()

        let history = RequestHistory(
            id: UUID(),
            historyNo: try await getNextAutonumber(document: "requestHistories"),
            requestRef: requestRef,
            action: action,
            sentBackReason: sentBackReason,
            reassignReason: reassignReason,

            // Default Common Fields
            createdOn: Date(),
            createdBy: userId,
            modifiedOn: nil,
            modifiedBy: nil,
            inactive: false
        )
        
        do {
            try db.collection("RequestHistory")
                .document(history.id.uuidString)
                .setData(from: history)
        } catch {
            throw NetworkError.serverUnavailable
        }
       
    }

// MARK: - Submitting a Requets
    func submitRequest(
        requestCategoryRef: UUID,
        requestSubcategoryRef: UUID,
        buildingRef: UUID,
        roomRef: UUID,
        description: String,
        images: [String],
    ) async throws {
        
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }
        
        let userId = try session.requireUserId()

        let request = Request(
            id: UUID(),
            requestNo: try await getNextAutonumber(document: "requests"),
            requesterRef: userId,
            requestCategoryRef: requestCategoryRef,
            requestSubcategoryRef: requestSubcategoryRef,
            buildingRef: buildingRef,
            roomRef: roomRef,
            description: description,
            images: images,
            priority: getPriority(requestCategoryRef: requestCategoryRef,requestSubcategoryRef: requestSubcategoryRef),
            status: .submitted,
            ownerId: userId,

            // Default Common Fields
            createdOn: Date(),
            createdBy: userId,
            modifiedOn: nil,
            modifiedBy: nil,
            inactive: false
        )
        
        try await createHistoryRecord(requestRef: request.id, action: .submitted, sentBackReason: nil, reassignReason: nil)
        
        do{
            try db.collection("Request")
                .document(request.id.uuidString)
                .setData(from: request)
        } catch{
            throw NetworkError.serverUnavailable
        }
    }

    // MARK: - Fetch All Requests (Filtered by User Type)
        func getAllRequests() async throws -> [Request] {
            guard await hasInternetConnection() else {
                throw NetworkError.noInternet
            }

            let userId = try SessionManager.shared.requireUserId()
            let userType = try await SessionManager.shared.getUserType()
            
            var query = db.collection("Request")
                .whereField("inactive", isEqualTo: false)
            
            // Apply user type filtering
            switch userType {
            case 1000: // Admin - no additional filter, get all requests
                break
                
            case 1001: // Requester - filter by requesterRef
                query = query.whereField("requesterRef", isEqualTo: userId)
                
            case 1002: // Servicer - filter by servicerRef
                query = query.whereField("servicerRef", isEqualTo: userId)
                
            default:
                throw SessionError.userDataNotFound
            }
            
            let snapshot = try await query
                .order(by: "createdOn", descending: true)
                .getDocuments()

            return snapshot.documents.compactMap { doc -> Request? in
                let data = doc.data()

                guard let idString = data["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let requestNo = data["requestNo"] as? String,
                      let requesterRef = data["requesterRef"] as? String,
                      let requestCategoryRefString = data["requestCategoryRef"] as? String,
                      let requestCategoryRef = UUID(uuidString: requestCategoryRefString),
                      let requestSubcategoryRefString = data["requestSubcategoryRef"] as? String,
                      let requestSubcategoryRef = UUID(uuidString: requestSubcategoryRefString),
                      let buildingRefString = data["buildingRef"] as? String,
                      let buildingRef = UUID(uuidString: buildingRefString),
                      let roomRefString = data["roomRef"] as? String,
                      let roomRef = UUID(uuidString: roomRefString),
                      let description = data["description"] as? String,
                      let statusRaw = data["status"] as? Int,
                      let status = Status(rawValue: statusRaw),
                      let ownerId = data["ownerId"] as? String,
                      let createdOn = (data["createdOn"] as? Timestamp)?.dateValue(),
                      let createdBy = data["createdBy"] as? String,
                      let inactive = data["inactive"] as? Bool
                else { return nil }

                let images = data["images"] as? [String]
                let priorityRaw = data["priority"] as? Int
                let priority = priorityRaw.flatMap { Priority(rawValue: $0) }
                let servicerRef = data["servicerRef"] as? String
                let estimatedStartDate = (data["estimatedStartDate"] as? Timestamp)?.dateValue()
                let estimatedEndDate = (data["estimatedEndDate"] as? Timestamp)?.dateValue()
                let actualStartDate = (data["actualStartDate"] as? Timestamp)?.dateValue()
                let actualEndDate = (data["actualEndDate"] as? Timestamp)?.dateValue()
                let modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
                let modifiedBy = data["modifiedBy"] as? String

                return Request(
                    id: id,
                    requestNo: requestNo,
                    requesterRef: requesterRef,
                    requestCategoryRef: requestCategoryRef,
                    requestSubcategoryRef: requestSubcategoryRef,
                    buildingRef: buildingRef,
                    roomRef: roomRef,
                    description: description,
                    images: images,
                    priority: priority,
                    status: status,
                    servicerRef: servicerRef,
                    estimatedStartDate: estimatedStartDate,
                    estimatedEndDate: estimatedEndDate,
                    actualStartDate: actualStartDate,
                    actualEndDate: actualEndDate,
                    ownerId: ownerId,
                    createdOn: createdOn,
                    createdBy: createdBy,
                    modifiedOn: modifiedOn,
                    modifiedBy: modifiedBy,
                    inactive: inactive
                )
            }
        }

// MARK: - Load Reference Data
    private func loadReferenceData() async throws {
        // Load buildings
        let buildingsSnap = try await db.collection("Building").getDocuments()
        for doc in buildingsSnap.documents {
            let data = doc.data()
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let buildingNo = data["buildingNo"] as? String,
                  let createdOn = (data["createdOn"] as? Timestamp)?.dateValue(),
                  let createdBy = data["createdBy"] as? String,
                  let inactive = data["inactive"] as? Bool
            else { continue }

            let modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
            let modifiedBy = data["modifiedBy"] as? String

            buildingsCache[id] = Building(
                id: id,
                buildingNo: buildingNo,
                createdOn: createdOn,
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }

        // Load rooms
        let roomsSnap = try await db.collection("Room").getDocuments()
        for doc in roomsSnap.documents {
            let data = doc.data()
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let roomNo = data["roomNo"] as? String,
                  let buildingRefString = data["buildingRef"] as? String,
                  let buildingRef = UUID(uuidString: buildingRefString),
                  let createdOn = (data["createdOn"] as? Timestamp)?.dateValue(),
                  let createdBy = data["createdBy"] as? String,
                  let inactive = data["inactive"] as? Bool
            else { continue }

            let modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
            let modifiedBy = data["modifiedBy"] as? String

            roomsCache[id] = Room(
                id: id,
                roomNo: roomNo,
                buildingRef: buildingRef,
                createdOn: createdOn,
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }

        // Load categories
        let categoriesSnap = try await db.collection("RequestCategory").getDocuments()
        for doc in categoriesSnap.documents {
            let data = doc.data()
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = data["name"] as? String,
                  let isParent = data["isParent"] as? Bool,
                  let createdOn = (data["createdOn"] as? Timestamp)?.dateValue(),
                  let createdBy = data["createdBy"] as? String,
                  let inactive = data["inactive"] as? Bool
            else { continue }

            let parentCategoryRefString = data["parentCategoryRef"] as? String
            let parentCategoryRef = parentCategoryRefString.flatMap { UUID(uuidString: $0) }
            let modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
            let modifiedBy = data["modifiedBy"] as? String

            categoriesCache[id] = RequestCategory(
                id: id,
                name: name,
                isParent: isParent,
                parentCategoryRef: parentCategoryRef,
                createdOn: createdOn,
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }
    }

// MARK: - Get All Requests with Display Data
    func getAllRequestsForDisplay() async throws -> [RequestDisplayModel] {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        // Load reference data if not cached
        if buildingsCache.isEmpty || roomsCache.isEmpty || categoriesCache.isEmpty {
            try await loadReferenceData()
        }

        let requests = try await getAllRequests()

        return requests.map { request in
            let buildingNo = buildingsCache[request.buildingRef]?.buildingNo ?? "Unknown"
            let roomNo = roomsCache[request.roomRef]?.roomNo ?? "Unknown"
            let categoryName = categoriesCache[request.requestCategoryRef]?.name ?? "Unknown"
            let subcategoryName = categoriesCache[request.requestSubcategoryRef]?.name ?? "Unknown"

            return RequestDisplayModel(
                request: request,
                buildingNo: buildingNo,
                roomNo: roomNo,
                categoryName: categoryName,
                subcategoryName: subcategoryName
            )
        }
    }

// MARK: - Get Single Request for Display
    func getRequestForDisplay(requestId: UUID) async throws -> RequestDisplayModel? {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        // Load reference data if not cached
        if buildingsCache.isEmpty || roomsCache.isEmpty || categoriesCache.isEmpty {
            try await loadReferenceData()
        }

        let doc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let data = doc.data() else { return nil }

        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let requestNo = data["requestNo"] as? String,
              let requesterRef = data["requesterRef"] as? String,
              let requestCategoryRefString = data["requestCategoryRef"] as? String,
              let requestCategoryRef = UUID(uuidString: requestCategoryRefString),
              let requestSubcategoryRefString = data["requestSubcategoryRef"] as? String,
              let requestSubcategoryRef = UUID(uuidString: requestSubcategoryRefString),
              let buildingRefString = data["buildingRef"] as? String,
              let buildingRef = UUID(uuidString: buildingRefString),
              let roomRefString = data["roomRef"] as? String,
              let roomRef = UUID(uuidString: roomRefString),
              let description = data["description"] as? String,
              let statusRaw = data["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              let ownerId = data["ownerId"] as? String,
              let createdOn = (data["createdOn"] as? Timestamp)?.dateValue(),
              let createdBy = data["createdBy"] as? String,
              let inactive = data["inactive"] as? Bool
        else { return nil }

        let images = data["images"] as? [String]
        let priorityRaw = data["priority"] as? Int
        let priority = priorityRaw.flatMap { Priority(rawValue: $0) }
        let servicerRef = data["servicerRef"] as? String
        let estimatedStartDate = (data["estimatedStartDate"] as? Timestamp)?.dateValue()
        let estimatedEndDate = (data["estimatedEndDate"] as? Timestamp)?.dateValue()
        let actualStartDate = (data["actualStartDate"] as? Timestamp)?.dateValue()
        let actualEndDate = (data["actualEndDate"] as? Timestamp)?.dateValue()
        let modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
        let modifiedBy = data["modifiedBy"] as? String

        let request = Request(
            id: id,
            requestNo: requestNo,
            requesterRef: requesterRef,
            requestCategoryRef: requestCategoryRef,
            requestSubcategoryRef: requestSubcategoryRef,
            buildingRef: buildingRef,
            roomRef: roomRef,
            description: description,
            images: images,
            priority: priority,
            status: status,
            servicerRef: servicerRef,
            estimatedStartDate: estimatedStartDate,
            estimatedEndDate: estimatedEndDate,
            actualStartDate: actualStartDate,
            actualEndDate: actualEndDate,
            ownerId: ownerId,
            createdOn: createdOn,
            createdBy: createdBy,
            modifiedOn: modifiedOn,
            modifiedBy: modifiedBy,
            inactive: inactive
        )

        let buildingNo = buildingsCache[request.buildingRef]?.buildingNo ?? "Unknown"
        let roomNo = roomsCache[request.roomRef]?.roomNo ?? "Unknown"
        let categoryName = categoriesCache[request.requestCategoryRef]?.name ?? "Unknown"
        let subcategoryName = categoriesCache[request.requestSubcategoryRef]?.name ?? "Unknown"

        return RequestDisplayModel(
            request: request,
            buildingNo: buildingNo,
            roomNo: roomNo,
            categoryName: categoryName,
            subcategoryName: subcategoryName
        )
    }
}
