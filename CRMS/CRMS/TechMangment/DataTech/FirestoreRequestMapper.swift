//
//  FirestoreRequestMapper.swift
//  CRMS
//
//

import Foundation

enum FirestoreRequestMapper {

    static func toModel(_ dto: FirestoreRequestDTO) -> Request? {
        guard
            let idStr = dto.id,
            let id = UUID(uuidString: idStr),

            let cat = UUID(uuidString: dto.requestCategoryRef),
            let sub = UUID(uuidString: dto.requestSubcategoryRef),
            let building = UUID(uuidString: dto.buildingRef),
            let room = UUID(uuidString: dto.roomRef)
        else { return nil }

        return Request(
            id: id,
            requestNo: dto.requestNo,

            requesterRef: dto.requesterRef,          // ✅ String UID
            requestCategoryRef: cat,
            requestSubcategoryRef: sub,
            buildingRef: building,
            roomRef: room,

            description: dto.description,
            images: dto.images,
            priority: dto.priority.flatMap(Priority.init(rawValue:)),
            status: Status(rawValue: dto.status) ?? .submitted,

            servicerRef: dto.servicerRef,            // ✅ String UID?
            estimatedStartDate: dto.estimatedStartDate,
            estimatedEndDate: dto.estimatedEndDate,
            actualStartDate: dto.actualStartDate,
            actualEndDate: dto.actualEndDate,

            ownerId: dto.ownerId ?? dto.requesterRef, // ✅ String UID
            createdOn: dto.createdOn,
            createdBy: dto.createdBy,                 // ✅ String UID
            modifiedOn: dto.modifiedOn,
            modifiedBy: dto.modifiedBy,               // ✅ String UID?
            inactive: dto.inactive
        )
    }
}
