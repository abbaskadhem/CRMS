//
//  InventoryService.swift
//  CRMS
//
//  Created by Reem Janahi on 02/01/2026.
//

import Foundation
import FirebaseFirestore

final class InventoryService {
    static let shared = InventoryService()
    private init() {}

    func listenToInventoryCategories(
        onUpdate: @escaping ([ItemCategoryModel]) -> Void
    ) -> ListenerRegistration {

        return Firestore.firestore()
            .collection("ItemCategory")
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                let categories = docs.compactMap {
                    ItemCategoryModel(from: $0)
                }

                onUpdate(categories)
            }
    }
    
    func listenToItems(
        onUpdate: @escaping ([ItemModel]) -> Void
    ) -> ListenerRegistration {

        Firestore.firestore()
            .collection("Item")
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                let items = docs.compactMap {
                    ItemModel(from: $0)
                }

                onUpdate(items)
            }
    }


    
    func getAllCategories() async throws -> [ItemCategoryModel] {
        let db = Firestore.firestore()
        let snap = try await db.collection("ItemCategory").getDocuments()
        

        return snap.documents.compactMap { doc in
            ItemCategoryModel(from: doc)
        }
    }
    
    func getParentCategories() async throws -> [ItemCategoryModel] {
           let all = try await getAllCategories()
           return all.filter { $0.isParent && !$0.inactive }
       }

       func getSubCategories() async throws -> [ItemCategoryModel] {
           let all = try await getAllCategories()
           return all.filter { !$0.isParent && !$0.inactive }
       }
}

extension ItemCategoryModel {

    init?(from doc: QueryDocumentSnapshot) {
        let data = doc.data()

        guard
            let name = data["name"] as? String,
            let isParent = data["isParent"] as? Bool,
            let createdOn = data["createdOn"] as? Timestamp,
            let createdBy = data["createdBy"] as? String,
            let inactive = data["inactive"] as? Bool
        else {
            return nil
        }

        self.id = doc.documentID
        self.name = name
        self.isParent = isParent
        self.parentCategoryRef = data["parentCategoryRef"] as? String
        self.createdOn = createdOn.dateValue()
        self.createdBy = createdBy
        self.modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
        self.modifiedBy = data["modifiedBy"] as? String
        self.inactive = inactive
        self.isExpanded = data["isExpanded"] as? Bool ?? false
    }
}

extension ItemModel{
    init?(from doc: QueryDocumentSnapshot) {
        let data = doc.data()

        guard
            let name = data["name"] as? String,
            let partNo = data["partNo"] as? String,
            let unitCost = data["unitCost"] as? Double,
            let vendor = data["vendor"] as? String,
            let itemCategoryRef = data["itemCategoryRef"] as? String,
            let itemSubCategoryRef = data["itemSubCategoryRef"] as? String,
            let quantity = data["quantity"] as? Int,
            let description = data["description"] as? String,
            let usage = data["usage"] as? String,
            let createdOn = data["createdOn"] as? Timestamp,
            let createdBy = data["createdBy"] as? String,
            let inactive = data["inactive"] as? Bool
        else {
            return nil
        }

        self.id = doc.documentID
        self.name = name
        self.partNo = partNo
        self.unitCost = unitCost
        self.vendor = vendor
        self.itemCategoryRef = itemCategoryRef
        self.itemSubcategoryRef = itemSubCategoryRef
        self.quantity = quantity
        self.description = description
        self.usage = usage
        
        self.createdOn = createdOn.dateValue()
        self.createdBy = createdBy
        self.modifiedOn = (data["modifiedOn"] as? Timestamp)?.dateValue()
        self.modifiedBy = data["modifiedBy"] as? String
        self.inactive = inactive
      
    }
}
