//
//  LocationController.swift
//  CRMS
//
//  Created for fetching Buildings and Rooms from Firestore
//

import FirebaseFirestore

final class LocationController {
    static let shared = LocationController()

    private let db = Firestore.firestore()

    // MARK: - Fetch Buildings

    // Fetches all active buildings from Firestore
    func getActiveBuildings() async throws -> [Building] {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let snap = try await db.collection("Building").getDocuments()

        return snap.documents.compactMap { doc -> Building? in
            let data = doc.data()

            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let buildingNo = data["buildingNo"] as? String,
                  let createdOnTimestamp = data["createdOn"] as? Timestamp,
                  let createdBy = data["createdBy"] as? String,
                  let inactive = data["inactive"] as? Bool,
                  !inactive // Only return active buildings
            else { return nil }

            var modifiedOn: Date? = nil
            if let modifiedTimestamp = data["modifiedOn"] as? Timestamp {
                modifiedOn = modifiedTimestamp.dateValue()
            }

            let modifiedBy = data["modifiedBy"] as? String

            return Building(
                id: id,
                buildingNo: buildingNo,
                createdOn: createdOnTimestamp.dateValue(),
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }
    }

    // MARK: - Fetch Rooms

    /// Fetches all active rooms for a specific building
    func getActiveRooms(forBuildingId buildingId: UUID) async throws -> [Room] {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let snap = try await db.collection("Room").getDocuments()

        return snap.documents.compactMap { doc -> Room? in
            let data = doc.data()

            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let roomNo = data["roomNo"] as? String,
                  let buildingRefString = data["buildingRef"] as? String,
                  let buildingRef = UUID(uuidString: buildingRefString),
                  let createdOnTimestamp = data["createdOn"] as? Timestamp,
                  let createdBy = data["createdBy"] as? String,
                  let inactive = data["inactive"] as? Bool,
                  !inactive, // Only return active rooms
                  buildingRef == buildingId // Filter by building
            else { return nil }

            var modifiedOn: Date? = nil
            if let modifiedTimestamp = data["modifiedOn"] as? Timestamp {
                modifiedOn = modifiedTimestamp.dateValue()
            }

            let modifiedBy = data["modifiedBy"] as? String

            return Room(
                id: id,
                roomNo: roomNo,
                buildingRef: buildingRef,
                createdOn: createdOnTimestamp.dateValue(),
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }
    }
}
