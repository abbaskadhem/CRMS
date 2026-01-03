//
//  Untitled.swift
//  CRMS
//
//

import Foundation
import FirebaseFirestore


struct FirestoreBuildingDTO: Codable {
    var id: String
    var buildingNo: String
    var inactive: Bool

    // ✅ Firebase Auth UID fields (String)
    var createdOn: Date?
    var createdBy: String?
    var modifiedOn: Date?
    var modifiedBy: String?
}

import FirebaseFirestore

final class FirestoreBuildingRepository {
    private let db = Firestore.firestore()

    func listenBuildings(
        onChange: @escaping ([FirestoreBuildingDTO]) -> Void
    ) -> ListenerRegistration {

        db.collection(FBCollections.buildings)
            .whereField("inactive", isEqualTo: false)
            .addSnapshotListener { snap, error in
                if let error {
                    print("🔥 buildings listen error:", error)
                }

                let items: [FirestoreBuildingDTO] = snap?.documents.compactMap { doc in
                    var data = doc.data()
                    data["id"] = doc.documentID
                    return try? Firestore.Decoder().decode(
                        FirestoreBuildingDTO.self,
                        from: data
                    )
                } ?? []

                onChange(items)
            }
    }
}

