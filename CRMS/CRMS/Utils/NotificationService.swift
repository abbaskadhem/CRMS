//
//  NotificationService.swift
//  CRMS
//
//  Created by Reem Janahi on 30/12/2025.
//

import Foundation
import FirebaseFirestore

final class NotificationService {

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func startListening(
        onChange: @escaping ([NotificationModel]) -> Void
    ) {

        listener = db.collection("Notification")
            .whereField("inactive", isEqualTo: false)
            .order(by: "createdOn", descending: true)
            .addSnapshotListener { snapshot, error in

                guard let documents = snapshot?.documents, error == nil else {
                    onChange([])
                    return
                }

                let notifications = documents.compactMap {
                    NotificationModel(document: $0)
                }

                onChange(notifications)
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
