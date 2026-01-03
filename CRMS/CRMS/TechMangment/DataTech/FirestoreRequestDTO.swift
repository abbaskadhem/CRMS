//
//  ].swift
//  CRMS
//
//

import Foundation
import FirebaseFirestore

struct FirestoreRequestDTO: Codable, Identifiable {
    @DocumentID var id: String?

    var requestNo: String
    var requesterRef: String
    var servicerRef: String?

    var requestCategoryRef: String
    var requestSubcategoryRef: String
    var buildingRef: String
    var roomRef: String

    var description: String
    var images: [String]?

    var priority: Int?
    var status: Int

    var estimatedStartDate: Date?
    var estimatedEndDate: Date?
    var actualStartDate: Date?
    var actualEndDate: Date?
    var ownerId: String?

    var createdOn: Date
    var createdBy: String
    var modifiedOn: Date?
    var modifiedBy: String?
    var inactive: Bool
}
