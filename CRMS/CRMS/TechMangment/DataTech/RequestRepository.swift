//
//  Untitled.swift
//  TechRequestMangment
//
//

import Foundation

import FirebaseFirestore

protocol RequestRepository {
    var currentUserId: String { get }

    func listenMyRequests(onChange: @escaping ([Request]) -> Void) -> ListenerRegistration
    func fetchRequest(by id: UUID) async -> Request?

    func schedule(requestId: UUID, from: Date, to: Date) async
    func start(requestId: UUID) async
    func markCompleted(requestId: UUID) async

    func updateStatus(requestId: UUID, status: Status, modifiedBy: String) async
    func sendBack(requestId: UUID, reason: String, modifiedBy: String) async
}
