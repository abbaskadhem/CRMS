//
//  Untitled.swift
//  CRMS
//
//

import Foundation
import FirebaseFirestore


struct FirestoreRequestCategoryDTO: Codable {
    @DocumentID var docId: String?   // doc id من فايرستور
    var id: String?
    var name: String?
    var isParent: Bool?
    var parentCategoryRef: String?

    var createdOn: Date?
    var createdBy: String?
    var modifiedOn: Date?
    var modifiedBy: String?
    var inactive: Bool?
}
