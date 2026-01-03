//
//  Untitled.swift
//  CRMS
//

import Foundation
import FirebaseFirestore


import Foundation
import FirebaseFirestore

struct FirestoreRoomDTO: Codable {
    @DocumentID var id: String?
    var roomNo: String
    var buildingRef: String
    var inactive: Bool

    // ✅ Firebase Auth UID fields (String)
    var createdOn: Date?
    var createdBy: String?
    var modifiedOn: Date?
    var modifiedBy: String?
}

final class FirestoreRoomRepository {
    private let db = Firestore.firestore()

    func listenRooms(
        onChange: @escaping ([FirestoreRoomDTO]) -> Void
    ) -> ListenerRegistration {

        db.collection(FBCollections.rooms)
            .whereField("inactive", isEqualTo: false)
            .addSnapshotListener { snap, error in
                if let error {
                    print("🔥 rooms listen error:", error)
                    onChange([])
                    return
                }

                let items: [FirestoreRoomDTO] = snap?.documents.compactMap { doc in
                    try? doc.data(as: FirestoreRoomDTO.self)
                } ?? []

                onChange(items)
            }
    }
}

