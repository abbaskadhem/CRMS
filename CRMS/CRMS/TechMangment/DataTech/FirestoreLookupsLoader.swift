//
//  Untitled.swift
//  CRMS
//
//


import Foundation
import FirebaseFirestore

final class FirestoreLookupsLoader {
    private let db = Firestore.firestore()

    func listenCategories(onChange: @escaping ([RequestCategory]) -> Void) -> ListenerRegistration {

        db.collection(FBCollections.categories) 
            .addSnapshotListener { snap, error in
                if let error {
                    print("🔥 categories error:", error)
                    return
                }

                let dtos: [FirestoreRequestCategoryDTO] = snap?.documents.compactMap { doc in
                    do { return try doc.data(as: FirestoreRequestCategoryDTO.self) }
                    catch {
                        print("❌ category decode failed docID=\(doc.documentID)\n", error)
                        return nil
                    }
                } ?? []

                let models: [RequestCategory] = dtos.compactMap(FirestoreCategoryMapper.toModel)

                print("✅ categories docs:", snap?.documents.count ?? 0)
                print("✅ categories dtos:", dtos.count)
                print("✅ categories models:", models.count)

                onChange(models)
            }
    }
}
