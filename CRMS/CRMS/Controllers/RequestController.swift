//
//  RequestController.swift
//  CRMS
//
//  Created by BP-36-201-10 on 03/12/2025.
//

import Foundation
import FirebaseFirestore

final class RequestController {

    private let db = Firestore.firestore()
    private let session = SessionManager.shared
    
    // Function to get the priority based on the cat and subcat
    func getPriority(requestCategoryRef: UUID, requestSubcategoryRef: UUID) -> Priority
    {
        return .low
    }

    func getNextAutonumber() async throws -> String {
        let db = Firestore.firestore()
        let ref = db.collection("counters").document("requests")

        let snapshot = try await ref.getDocument()
        let last = snapshot.data()?["lastNumber"] as? Int ?? 0
        let next = last + 1

        try await ref.setData(["lastNumber": next], merge: true)

        return String(format: "REQ-%05d", next)
    }

    // MARK: - Use cases

    func submitRequest(
        requestCategoryRef: UUID,
        requestSubcategoryRef: UUID,
        buildingRef: UUID,
        roomRef: UUID,
        description: String,
        images: [String],
    ) async throws {
        let userId = try session.requireUserId()

        let request = Request(
            id: UUID(),
            requestNo: try await getNextAutonumber(),
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
            createdOn: Date(),
            createdBy: userId,
            modifiedOn: nil,
            modifiedBy: nil,
            inactive: false
        )

        try db.collection("requests")
            .document(request.id.uuidString)
            .setData(from: request)
    }

}



