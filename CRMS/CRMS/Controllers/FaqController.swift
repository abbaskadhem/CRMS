//
//  FaqController.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

import FirebaseFirestore

class FaqController {
    
    static let shared = FaqController()
    
    func getFaqs() async throws -> [FAQ] {
        let faqsRef = try await Firestore.firestore().collection("Faq").getDocuments()
        
        let fetchedFaqs = faqsRef.documents.compactMap { document -> FAQ? in
            let data = document.data()
            let question = data["question"] as? String ?? ""
            let answer = data["answer"] as? String ?? ""
            let id = document.documentID
            return FAQ(id: id, question: question , answer: answer)
            
        }
        return fetchedFaqs
    }
    
    func addFaq(_ faq: FAQ) async throws {
        var data: [String: Any] = [:]
        data["question"] = faq.question
        data["answer"] = faq.answer
        
        
        try await Firestore.firestore().collection("Faq").document().setData(data)
    }
    
    func deleteFaq(withId id: String) async throws {
        try await Firestore.firestore().collection("Faq").document(id).delete()
    }
    
    func editFaq( faq: FAQ) async throws {
        var data: [String: Any] = [:]
        data["question"] = faq.question
        data["answer"] = faq.answer
        
        try await Firestore.firestore().collection("Faq").document(faq.id).updateData(data)
    }
}
