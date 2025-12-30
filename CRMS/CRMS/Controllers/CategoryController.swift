//
//  CategoryController.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import FirebaseFirestore

/// Controller for managing Request Categories using the RequestCategory model.
/// Categories use a flat parent-child structure via isParent and parentCategoryRef.
final class CategoryController {
    static let shared = CategoryController()

    private let collectionName = "RequestCategory"

    // MARK: - Fetch Methods

    /// Fetches all request categories from Firestore
    func getAllCategories() async throws -> [RequestCategory] {
        let db = Firestore.firestore()
        let snap = try await db.collection(collectionName).getDocuments()

        return snap.documents.compactMap { doc -> RequestCategory? in
            let data = doc.data()

            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = data["name"] as? String,
                  let isParent = data["isParent"] as? Bool,
                  let createdOnTimestamp = data["createdOn"] as? Timestamp,
                  let createdByString = data["createdBy"] as? String,
                  let createdBy = UUID(uuidString: createdByString),
                  let inactive = data["inactive"] as? Bool
            else { return nil }

            // Parse optional parentCategoryRef
            var parentCategoryRef: UUID? = nil
            if let parentRefString = data["parentCategoryRef"] as? String {
                parentCategoryRef = UUID(uuidString: parentRefString)
            }

            // Parse optional modified fields
            var modifiedOn: Date? = nil
            if let modifiedTimestamp = data["modifiedOn"] as? Timestamp {
                modifiedOn = modifiedTimestamp.dateValue()
            }

            var modifiedBy: UUID? = nil
            if let modifiedByString = data["modifiedBy"] as? String {
                modifiedBy = UUID(uuidString: modifiedByString)
            }

            return RequestCategory(
                id: id,
                name: name,
                isParent: isParent,
                parentCategoryRef: parentCategoryRef,
                createdOn: createdOnTimestamp.dateValue(),
                createdBy: createdBy,
                modifiedOn: modifiedOn,
                modifiedBy: modifiedBy,
                inactive: inactive
            )
        }
    }

    /// Fetches only parent categories (isParent = true)
    func getParentCategories() async throws -> [RequestCategory] {
        let allCategories = try await getAllCategories()
        return allCategories.filter { $0.isParent && !$0.inactive }
    }

    /// Fetches subcategories for a given parent category
    func getSubcategories(forParentId parentId: UUID) async throws -> [RequestCategory] {
        let allCategories = try await getAllCategories()
        return allCategories.filter { $0.parentCategoryRef == parentId && !$0.inactive }
    }

    // MARK: - Add Methods

    /// Adds a new parent category
    /// - Parameters:
    ///   - name: The name of the category
    ///   - createdBy: The UUID of the user creating this category
    func addCategory(name: String, createdBy: UUID) async throws {
        let db = Firestore.firestore()
        let newId = UUID()

        try await db.collection(collectionName).document(newId.uuidString).setData([
            "id": newId.uuidString,
            "name": name,
            "isParent": true,
            "parentCategoryRef": NSNull(),
            "createdOn": Timestamp(date: Date()),
            "createdBy": createdBy.uuidString,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])
    }

    /// Adds a new subcategory under a parent category
    /// - Parameters:
    ///   - name: The name of the subcategory
    ///   - parentId: The UUID of the parent category
    ///   - createdBy: The UUID of the user creating this subcategory
    func addSubCategory(name: String, parentId: UUID, createdBy: UUID) async throws {
        let db = Firestore.firestore()
        let newId = UUID()

        try await db.collection(collectionName).document(newId.uuidString).setData([
            "id": newId.uuidString,
            "name": name,
            "isParent": false,
            "parentCategoryRef": parentId.uuidString,
            "createdOn": Timestamp(date: Date()),
            "createdBy": createdBy.uuidString,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])
    }

    // MARK: - Update Methods

    /// Updates the inactive status of a category (activate/deactivate)
    /// - Parameters:
    ///   - categoryId: The UUID of the category to update
    ///   - inactive: The new inactive status (true = inactive, false = active)
    ///   - modifiedBy: The UUID of the user making the change
    func updateCategoryStatus(categoryId: UUID, inactive: Bool, modifiedBy: UUID) async throws {
        let db = Firestore.firestore()
        let ref = db.collection(collectionName).document(categoryId.uuidString)

        try await ref.updateData([
            "inactive": inactive,
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": modifiedBy.uuidString
        ])
    }

    /// Updates the name of a category
    /// - Parameters:
    ///   - categoryId: The UUID of the category to update
    ///   - name: The new name
    ///   - modifiedBy: The UUID of the user making the change
    func updateCategoryName(categoryId: UUID, name: String, modifiedBy: UUID) async throws {
        let db = Firestore.firestore()
        let ref = db.collection(collectionName).document(categoryId.uuidString)

        try await ref.updateData([
            "name": name,
            "modifiedOn": Timestamp(date: Date()),
            "modifiedBy": modifiedBy.uuidString
        ])
    }
}
