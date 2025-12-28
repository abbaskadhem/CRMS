//
//  CategoryController.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import FirebaseFirestore

final class CategoryController {
    static let shared = CategoryController()

    func getAllCategories() async throws -> [Category] {
        let db = Firestore.firestore()
        let snap = try await db.collection("Category").getDocuments()

        return snap.documents.map { doc in
            let data = doc.data()

            let name = data["name"] as? String ?? ""

            let subArray = data["subCategories"] as? [[String: Any]] ?? []
            let subs: [SubCategory] = subArray.map {
                SubCategory(
                    name: $0["name"] as? String ?? "",
                    isActive: $0["isActive"] as? Bool ?? true
                )
            }

            return Category(
                id: doc.documentID,
                name: name,
                isExpanded: false,
                subCategories: subs
            )
        }
    }
    
    func addCategory(name: String) async throws {
        let db = Firestore.firestore()
        
        try await db.collection("Category").addDocument(data: [
            "name": name
        ])
    }

    func addSubCategory(categoryId: String, subCategory: SubCategory) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("Category").document(categoryId)

        let newSub: [String: Any] = [
            "name": subCategory.name,
            "isActive": subCategory.isActive
        ]

        try await ref.updateData([
            "subCategories": FieldValue.arrayUnion([newSub])
        ])
    }

    func updateSubCategories(categoryId: String, subCategories: [SubCategory]) async throws {
        let db = Firestore.firestore()
        let ref = db.collection("Category").document(categoryId)

        let data = subCategories.map { sub in
            [
                "name": sub.name,
                "isActive": sub.isActive
            ] as [String: Any]
        }

        try await ref.updateData([
            "subCategories": data
        ])
    }
}


