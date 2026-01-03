//
//  Untitled.swift
//  CRMS
//
//

import Foundation

enum FirestoreCategoryMapper {

    static func toModel(_ dto: FirestoreRequestCategoryDTO) -> RequestCategory? {

        // id الخاص بالكاتيجوري (هذا فقط UUID)
        guard let rawId = dto.id ?? dto.docId,
              let id = UUID(uuidString: rawId)
        else { return nil }

        return RequestCategory(
            id: id,
            name: dto.name ?? "Unknown",
            isParent: dto.isParent ?? false,
            parentCategoryRef: dto.parentCategoryRef.flatMap { UUID(uuidString: $0) },
            createdOn: dto.createdOn ?? Date(),

            // ✅ Firebase Auth UID → String
            createdBy: dto.createdBy ?? "",

            modifiedOn: dto.modifiedOn,

            // ✅ Firebase Auth UID → String؟
            modifiedBy: dto.modifiedBy,

            inactive: dto.inactive ?? false
        )
        }
}
