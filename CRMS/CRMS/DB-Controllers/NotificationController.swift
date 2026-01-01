//
//  NotificationController.swift
//  CRMS
//
//  Created by BP-36-201-10 on 03/12/2025.
//

import Foundation
import FirebaseFirestore

final class NotificationController {
    static let shared = NotificationController()

    private let db = Firestore.firestore()
    private let collectionName = "Notification"

    private init() {}

    func getNotifications(forUserId userId: String) async throws -> [NotificationModel] {
        let snapshot = try await db.collection(collectionName)
            .whereField("toWho", arrayContains: userId)
            .whereField("inactive", isEqualTo: false)
            .order(by: "createdOn", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> NotificationModel? in
            let data = doc.data()

            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let title = data["title"] as? String,
                  let toWho = data["toWho"] as? [String],
                  let typeRaw = data["type"] as? Int,
                  let type = NotiType(rawValue: typeRaw),
                  let createdOn = (data["createdOn"] as? Timestamp)?.dateValue(),
                  let createdBy = data["createdBy"] as? String,
                  let inactive = data["inactive"] as? Bool else {
                return nil
            }

            let description = data["description"] as? String
            let requestRefString = data["requestRef"] as? String
            let requestRef = requestRefString.flatMap { UUID(uuidString: $0) }
            let modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
            let modifiedBy = data["modifiedBy"] as? String

            return NotificationModel(
                id: id,
                title: title,
                description: description,
                toWho: toWho,
                type: type,
                requestRef: requestRef,
                createdOn: createdOn,
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }
    }
}
