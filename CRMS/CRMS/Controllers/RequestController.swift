//
//  RequestController.swift
//  CRMS
//
//  Created by Abbas on 03/12/2025.
//

import Foundation
import FirebaseFirestore

final class RequestController {

// MARK: - Initializations
    // Starts a Firestore instance for the entire controller
    private let db = Firestore.firestore()

    // Gets the shared session manager for user ID 
    private let session = SessionManager.shared
    
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
        
           let ref = db.collection("counters").document(document)
        
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
            try db.collection("requestHistories")
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
            try db.collection("requests")
                .document(request.id.uuidString)
                .setData(from: request)
        } catch{
            throw NetworkError.serverUnavailable
        }
    }
}
