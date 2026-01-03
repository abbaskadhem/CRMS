//
//  RequestController.swift
//  CRMS
//
//  Created by Abbas on 03/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

// MARK: - Request Errors
/// Custom errors for request operations validation
enum RequestError: LocalizedError {
    case unauthorizedAction
    case invalidUserType
    case invalidRequestStatus
    case requestAlreadyAssigned
    case requestNotAssigned
    case requestNotFound
    case servicerNotFound
    case invalidServicer

    var errorDescription: String? {
        switch self {
        case .unauthorizedAction:
            return "You are not authorized to perform this action."
        case .invalidUserType:
            return "Invalid user type for this operation."
        case .invalidRequestStatus:
            return "Request status does not allow this action."
        case .requestAlreadyAssigned:
            return "This request is already assigned to a servicer."
        case .requestNotAssigned:
            return "This request is not assigned to any servicer."
        case .requestNotFound:
            return "Request not found."
        case .servicerNotFound:
            return "Servicer not found."
        case .invalidServicer:
            return "The specified user is not a servicer."
        }
    }
}

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

// MARK: - Autonumber Generation

    /// Generates the next sequential number for a given document type
    /// - Parameter document: The document type identifier (e.g., "requests", "requestHistories")
    /// - Returns: A formatted string like "REQ-00001" based on the counter's format
    /// - Throws: `NetworkError.noInternet` if offline
    /// - Note: Uses Firestore Counters collection to track and increment numbers atomically
    func getNextAutonumber(document: String) async throws -> String {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let ref = db.collection("Counters").document(document)

        // Read current counter value and format string
        let snapshot = try await ref.getDocument()
        let last = snapshot.data()?["lastNumber"] as? Int ?? 0
        let format = snapshot.data()?["format"] as? String ?? "ERR-%05d"
        let next = last + 1

        // Atomically update the counter
        try await ref.setData(["lastNumber": next], merge: true)

        return String(format: format, next)
    }

// MARK: - History Record Creation

    /// Creates an audit trail record for a request action
    /// - Parameters:
    ///   - requestRef: UUID of the request this history belongs to
    ///   - action: The action that was performed (e.g., .assigned, .completed)
    ///   - sentBackReason: Optional reason if action is .sentBack
    ///   - reassignReason: Optional reason if action is .reassigned
    /// - Throws: `NetworkError.noInternet` if offline, `SessionError.notLoggedIn` if no user
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

    /// Fetches all history records for a specific request, ordered by creation date
    /// - Parameter requestId: The UUID of the request
    /// - Returns: Array of RequestHistoryDisplayModel with user names and formatted data
    /// - Throws: NetworkError if offline or server unavailable
    func getRequestHistory(requestId: UUID) async throws -> [RequestHistoryDisplayModel] {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        // Fetch all history records for the request
        let snapshot = try await db.collection("RequestHistory")
            .whereField("requestRef", isEqualTo: requestId.uuidString)
            .order(by: "createdOn", descending: false)
            .getDocuments()

        var displayModels: [RequestHistoryDisplayModel] = []

        for document in snapshot.documents {
            guard let history = try? document.data(as: RequestHistory.self) else {
                continue
            }

            // Fetch user name
            let userName = await getUserName(userId: history.createdBy)

            // Format date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: history.createdOn)

            // Get action string
            let actionString = getActionString(for: history.action)

            // Determine if there's a reason
            let hasReason = history.action == .reassigned || history.action == .sentBack
            let reasonText: String?
            if history.action == .reassigned {
                reasonText = history.reassignReason
            } else if history.action == .sentBack {
                reasonText = history.sentBackReason
            } else {
                reasonText = nil
            }

            let model = RequestHistoryDisplayModel(
                history: history,
                actionString: actionString,
                createdByName: userName,
                dateString: dateString,
                hasReason: hasReason,
                reasonText: reasonText
            )

            displayModels.append(model)
        }

        return displayModels
    }

    /// Helper method to get user name from user ID
    private func getUserName(userId: String) async -> String {
        do {
            let userDoc = try await db.collection("User").document(userId).getDocument()
            if let userName = userDoc.data()?["fullName"] as? String {
                return userName
            }
        } catch {
            // Silently fail and return the user ID instead
        }
        return userId
    }

    /// Helper method to convert Action enum to display string
    private func getActionString(for action: Action) -> String {
        switch action {
        case .submitted:
            return "Request Submitted"
        case .assigned:
            return "Servicer Assigned"
        case .sentBack:
            return "Request Sent Back"
        case .scheduled:
            return "Work Scheduled"
        case .started:
            return "Work Started"
        case .completed:
            return "Work Completed"
        case .delayed:
            return "Work Delayed"
        case .reassigned:
            return "Servicer Reassigned"
        case .priorityChanged:
            return "Priority Assigned"
        }
    }

// MARK: - Submitting a Request

    /// Submits a new service request to Firestore
    /// - Parameters:
    ///   - requestCategoryRef: UUID of the selected main category
    ///   - requestSubcategoryRef: UUID of the selected subcategory
    ///   - buildingRef: UUID of the building location
    ///   - roomRef: UUID of the specific room
    ///   - description: User-provided description of the issue
    ///   - images: Array of uploaded image URLs from Firebase Storage
    /// - Throws: `NetworkError.noInternet` if offline, `SessionError.notLoggedIn` if no user
    func submitRequest(
        requestCategoryRef: UUID,
        requestSubcategoryRef: UUID,
        buildingRef: UUID,
        roomRef: UUID,
        description: String,
        images: [String]
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
            priority: nil,
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

    /// Fetches all requests filtered by the current user's role
    /// - Admin (1000): Gets all active requests
    /// - Requester (1001): Gets only their submitted requests
    /// - Servicer (1002): Gets only requests assigned to them
    /// - Returns: Array of Request objects sorted by creation date (newest first)
    /// - Throws: `NetworkError.noInternet` if offline, `SessionError` if user issues
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

    /// Loads and caches reference data (buildings, rooms, categories) from Firestore
    /// - Note: Called automatically by display methods when cache is empty
    /// - Throws: Firestore errors if documents cannot be fetched
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

    /// Fetches all requests with resolved reference data for display purposes
    /// - Returns: Array of RequestDisplayModel with building, room, and category names resolved
    /// - Throws: `NetworkError.noInternet` if offline
    /// - Note: Automatically loads and caches reference data (buildings, rooms, categories) on first call
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

    /// Fetches a single request with resolved reference data for display
    /// - Parameter requestId: UUID of the request to fetch
    /// - Returns: RequestDisplayModel with resolved names, or nil if not found
    /// - Throws: `NetworkError.noInternet` if offline
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

// MARK: - Image Upload
    /// Converts images to Base64 strings for storage in Firestore
    /// - Parameter images: Array of UIImage objects to convert
    /// - Returns: Array of Base64 encoded strings
    /// - Note: Using Base64 encoding instead of Firebase Storage due to access restrictions
    func uploadImages(_ images: [UIImage]) async throws -> [String] {
        var base64Strings: [String] = []

        for (index, image) in images.enumerated() {
            // Compress image to reduce size (0.5 quality for Base64 to stay within Firestore limits)
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                print("⚠️ Failed to convert image \(index) to JPEG data")
                continue
            }

            // Check size (Firestore has 1MB document limit, warn if image is too large)
            let sizeInKB = Double(imageData.count) / 1024.0
            print("📦 Image \(index) size: \(String(format: "%.2f", sizeInKB)) KB")

            if imageData.count > 500_000 { // Warn if larger than 500KB
                print("⚠️ Warning: Image \(index) is large (\(String(format: "%.2f", sizeInKB)) KB). Consider reducing quality.")
            }

            // Convert to Base64 string
            let base64String = imageData.base64EncodedString()

            // Add data URI prefix to make it a proper image data URL
            let dataURL = "data:image/jpeg;base64,\(base64String)"
            base64Strings.append(dataURL)

            print("✅ Converted image \(index) to Base64 (size: \(String(format: "%.2f", sizeInKB)) KB)")
        }

        return base64Strings
    }

    /// Converts a Base64 data URL back to UIImage
    /// - Parameter base64String: Base64 encoded image string (with or without data URI prefix)
    /// - Returns: UIImage if conversion successful, nil otherwise
    func base64ToImage(_ base64String: String) -> UIImage? {
        // Remove data URI prefix if present
        let base64Data: String
        if base64String.hasPrefix("data:image") {
            // Extract just the base64 part after the comma
            if let commaIndex = base64String.firstIndex(of: ",") {
                base64Data = String(base64String[base64String.index(after: commaIndex)...])
            } else {
                return nil
            }
        } else {
            base64Data = base64String
        }

        // Decode Base64 to Data
        guard let imageData = Data(base64Encoded: base64Data, options: .ignoreUnknownCharacters) else {
            print("❌ Failed to decode Base64 string")
            return nil
        }

        // Convert Data to UIImage
        return UIImage(data: imageData)
    }


// MARK: - Get Servicers
    /// Fetches all servicer users from the database for admin to select from when assigning requests
    /// - Returns: Array of User objects with servicer type
    func getServicers() async throws -> [User] {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        // Validate that the current user is an admin
        let userType = try await session.getUserType()
        guard userType == UserType.admin.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Query users with servicer type (1002)
        let snapshot = try await db.collection("User")
            .whereField("type", isEqualTo: UserType.servicer.rawValue)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> User? in
            let data = doc.data()

            guard let id = data["id"] as? String,
                  let fullName = data["fullName"] as? String,
                  let userNo = data["userNo"] as? String,
                  let typeRaw = data["type"] as? Int,
                  let type = UserType(rawValue: typeRaw),
                  let email = data["email"] as? String,
                  let inactive = data["inactive"] as? Bool,
                  let createdOn = data["createdOn"] as? Timestamp,
                  let createdBy = data["createdBy"] as? String

            else { return nil }

            // Skip inactive users
            if inactive == true {
                return nil
            }

            let subtypeRaw = data["subtype"] as? Int
            let subtype = subtypeRaw.flatMap { SubType(rawValue: $0) }

            return User(
                id: id,
                userNo: userNo,
                fullName: fullName,
                type: type,
                subtype: subtype,
                email: email,
                createdOn: createdOn.dateValue(),
                createdBy: createdBy,
                inactive: inactive
            )
        }
    }

// MARK: - Assign New Request
    /// Assigns a new request to a servicer (Admin only)
    /// - Parameters:
    ///   - requestId: The UUID of the request to assign
    ///   - servicerId: The Firebase Auth UID of the servicer to assign
    func assignNewRequest(requestId: UUID, servicerId: String) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is an admin
        let userType = try await session.getUserType()
        guard userType == UserType.admin.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Validate that the servicerId belongs to a servicer
        let servicerDoc = try await db.collection("User").document(servicerId).getDocument()
        guard let servicerData = servicerDoc.data(),
              let servicerType = servicerData["type"] as? Int,
              servicerType == UserType.servicer.rawValue else {
            throw RequestError.invalidServicer
        }

        // Fetch the request and validate its status
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate request status is submitted
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .submitted else {
            throw RequestError.invalidRequestStatus
        }

        // Validate servicerRef is empty
        if let existingServicer = requestData["servicerRef"] as? String, !existingServicer.isEmpty {
            throw RequestError.requestAlreadyAssigned
        }

        // Update the request with the servicer assignment
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "servicerRef": servicerId,
            "status": Status.assigned.rawValue,
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for the assignment
        try await createHistoryRecord(requestRef: requestId, action: .assigned, sentBackReason: nil, reassignReason: nil)
        
        
        //send a notification the request owner and technician
       let reqNo = requestData.self["requestNo"] as! String
        let ownerID = requestData.self["ownerRef"] as! String
        
        let toWhoOwner: [String] = [ownerID]
        let toWhoServicer: [String] = [servicerId]
        
        //Owner notif
        let notifOwner: NotificationModel = NotificationModel(
            id: UUID().uuidString,
            title: "Servicer appointed on request number \"\(reqNo)\".",
            description: nil,
            toWho: toWhoOwner,
            type: NotiType.notification,
            requestRef: requestId.uuidString,
            createdOn: Date(),
            createdBy: userId,
            modifiedOn: nil,
            modifiedBy: nil,
            inactive: false
        )
        await NotifCreateViewController.shared.createNotif(data: notifOwner)
        
        //Owner notif
        let notifServicer: NotificationModel = NotificationModel(
            id: UUID().uuidString,
            title: "Appointed to request number \"\(reqNo)\".",
            description: nil,
            toWho: toWhoServicer,
            type: NotiType.notification,
            requestRef: requestId.uuidString,
            createdOn: Date(),
            createdBy: userId,
            modifiedOn: nil,
            modifiedBy: nil,
            inactive: false
        )
        await NotifCreateViewController.shared.createNotif(data: notifServicer)
    }

// MARK: - Send Back Request
    /// Allows a servicer to send back a request to admin with a reason
    /// - Parameters:
    ///   - requestId: The UUID of the request to send back
    ///   - reason: The reason for sending back the request
    func sendBackRequest(requestId: UUID, reason: String) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is a servicer
        let userType = try await session.getUserType()
        guard userType == UserType.servicer.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Fetch the request and validate
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate the request is assigned to this servicer
        guard let servicerRef = requestData["servicerRef"] as? String,
              servicerRef == userId else {
            throw RequestError.unauthorizedAction
        }

        // Validate request status is assigned (can only send back if just assigned)
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .assigned else {
            throw RequestError.invalidRequestStatus
        }

        // Update the request - remove servicer and set status back to submitted
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "servicerRef": FieldValue.delete(),
            "status": Status.submitted.rawValue,
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for the send back action
        try await createHistoryRecord(requestRef: requestId, action: .sentBack, sentBackReason: reason, reassignReason: nil)
    }

// MARK: - Schedule Request
    /// Allows a servicer to set estimated start and end dates for a request
    /// - Parameters:
    ///   - requestId: The UUID of the request to schedule
    ///   - estimatedStartDate: The estimated start date
    ///   - estimatedEndDate: The estimated end date
    func scheduleRequest(requestId: UUID, estimatedStartDate: Date, estimatedEndDate: Date) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is a servicer
        let userType = try await session.getUserType()
        guard userType == UserType.servicer.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Fetch the request and validate
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate the request is assigned to this servicer
        guard let servicerRef = requestData["servicerRef"] as? String,
              servicerRef == userId else {
            throw RequestError.unauthorizedAction
        }

        // Validate request status is assigned
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .assigned else {
            throw RequestError.invalidRequestStatus
        }

        // Update the request with estimated dates
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "estimatedStartDate": Timestamp(date: estimatedStartDate),
            "estimatedEndDate": Timestamp(date: estimatedEndDate),
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for scheduling
        try await createHistoryRecord(requestRef: requestId, action: .scheduled, sentBackReason: nil, reassignReason: nil)
    }

// MARK: - Start Request
    /// Allows a servicer to mark a request as started
    /// - Parameter requestId: The UUID of the request to start
    func startRequest(requestId: UUID) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is a servicer
        let userType = try await session.getUserType()
        guard userType == UserType.servicer.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Fetch the request and validate
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate the request is assigned to this servicer
        guard let servicerRef = requestData["servicerRef"] as? String,
              servicerRef == userId else {
            throw RequestError.unauthorizedAction
        }

        // Validate request status is assigned (must be assigned before starting)
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .assigned else {
            throw RequestError.invalidRequestStatus
        }

        // Update the request status to inProgress and set actual start date
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "status": Status.inProgress.rawValue,
            "actualStartDate": Timestamp(date: Date()),
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for starting the request
        try await createHistoryRecord(requestRef: requestId, action: .started, sentBackReason: nil, reassignReason: nil)
    }

// MARK: - Complete Request
    /// Allows a servicer to mark a request as completed
    /// - Parameter requestId: The UUID of the request to complete
    func completeRequest(requestId: UUID) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is a servicer
        let userType = try await session.getUserType()
        guard userType == UserType.servicer.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Fetch the request and validate
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate the request is assigned to this servicer
        guard let servicerRef = requestData["servicerRef"] as? String,
              servicerRef == userId else {
            throw RequestError.unauthorizedAction
        }

        // Validate request status is inProgress (must be in progress before completing)
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .inProgress else {
            throw RequestError.invalidRequestStatus
        }

        // Update the request status to completed and set actual end date
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "status": Status.completed.rawValue,
            "actualEndDate": Timestamp(date: Date()),
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for completing the request
        try await createHistoryRecord(requestRef: requestId, action: .completed, sentBackReason: nil, reassignReason: nil)
    }

// MARK: - Check For Delayed Requests
    /// Checks for requests that have passed their estimated end date and marks them as delayed
    /// Should be called when an admin logs in
    /// - Returns: The number of requests marked as delayed
    @discardableResult
    func checkForDelayedRequests() async throws -> Int {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        // Validate that the current user is an admin
        let userType = try await session.getUserType()
        guard userType == UserType.admin.rawValue else {
            throw RequestError.unauthorizedAction
        }

        let userId = try session.requireUserId()
        let now = Date()

        // Query requests that are in progress and have an estimated end date
        let snapshot = try await db.collection("Request")
            .whereField("inactive", isEqualTo: false)
            .whereField("status", isEqualTo: Status.inProgress.rawValue)
            .getDocuments()

        var delayedCount = 0

        for doc in snapshot.documents {
            let data = doc.data()

            // Check if estimated end date exists and has passed
            guard let estimatedEndTimestamp = data["estimatedEndDate"] as? Timestamp else {
                continue
            }

            let estimatedEndDate = estimatedEndTimestamp.dateValue()

            // If the estimated end date has passed, mark as delayed
            if estimatedEndDate < now {
                guard let idString = data["id"] as? String,
                      let requestId = UUID(uuidString: idString) else {
                    continue
                }

                // Update status to delayed
                try await db.collection("Request").document(requestId.uuidString).updateData([
                    "status": Status.delayed.rawValue,
                    "modifiedOn": Timestamp(date: Date()),
                    "modifiedBy": userId
                ])

                // Create history record for delayed status
                try await createHistoryRecord(requestRef: requestId, action: .delayed, sentBackReason: nil, reassignReason: nil)

                delayedCount += 1
            }
        }

        return delayedCount
    }

// MARK: - Reassign Request
    /// Reassigns a request to a different servicer (Admin only)
    /// - Parameters:
    ///   - requestId: The UUID of the request to reassign
    ///   - newServicerId: The Firebase Auth UID of the new servicer
    ///   - reason: The reason for reassignment
    func reassignRequest(requestId: UUID, newServicerId: String, reason: String) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is an admin
        let userType = try await session.getUserType()
        guard userType == UserType.admin.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Validate that the newServicerId belongs to a servicer
        let servicerDoc = try await db.collection("User").document(newServicerId).getDocument()
        guard let servicerData = servicerDoc.data(),
              let servicerType = servicerData["type"] as? Int,
              servicerType == UserType.servicer.rawValue else {
            throw RequestError.invalidServicer
        }

        // Fetch the request and validate
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate the request is currently assigned to a servicer
        guard let currentServicer = requestData["servicerRef"] as? String,
              !currentServicer.isEmpty else {
            throw RequestError.requestNotAssigned
        }

        // Validate request status allows reassignment (assigned, inProgress, or delayed)
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .assigned || status == .onHold || status == .delayed else {
            throw RequestError.invalidRequestStatus
        }

        // Update the request with the new servicer and reset to assigned status
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "servicerRef": newServicerId,
            "status": Status.assigned.rawValue,
            "estimatedStartDate": FieldValue.delete(),
            "estimatedEndDate": FieldValue.delete(),
            "actualStartDate": FieldValue.delete(),
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for the reassignment
        try await createHistoryRecord(requestRef: requestId, action: .reassigned, sentBackReason: nil, reassignReason: reason)
    }

// MARK: - Assign Priority

    /// Allows an admin to assign priority to a request (one-time only, when request is first submitted)
    /// - Parameters:
    ///   - requestId: The UUID of the request
    ///   - priority: The priority level to assign (Low/Moderate/High)
    /// - Throws: RequestError or NetworkError if validation fails
    func assignPriority(requestId: UUID, priority: Priority) async throws {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let userId = try session.requireUserId()

        // Validate that the current user is an admin
        let userType = try await session.getUserType()
        guard userType == UserType.admin.rawValue else {
            throw RequestError.unauthorizedAction
        }

        // Fetch the request and validate
        let requestDoc = try await db.collection("Request").document(requestId.uuidString).getDocument()
        guard let requestData = requestDoc.data() else {
            throw RequestError.requestNotFound
        }

        // Validate request status is submitted
        guard let statusRaw = requestData["status"] as? Int,
              let status = Status(rawValue: statusRaw),
              status == .submitted else {
            throw RequestError.invalidRequestStatus
        }

        // Validate priority is currently nil (not already assigned)
        if let existingPriority = requestData["priority"] as? Int, existingPriority != 0 {
            throw RequestError.invalidRequestStatus
        }

        // Validate servicer is not yet assigned
        if let servicerRef = requestData["servicerRef"] as? String, !servicerRef.isEmpty {
            throw RequestError.requestAlreadyAssigned
        }

        // Update the request with the new priority
        try await db.collection("Request").document(requestId.uuidString).updateData([
            "priority": priority.rawValue,
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": userId
        ])

        // Create history record for the priority assignment
        try await createHistoryRecord(requestRef: requestId, action: .priorityChanged, sentBackReason: nil, reassignReason: nil)
    }
}
