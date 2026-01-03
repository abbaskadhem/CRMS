import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreRequestRepository: RequestRepository {

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Firebase Auth UID (String) للفني الحالي
    let currentUserId: String

    init(currentUserId: String = Auth.auth().currentUser?.uid ?? "") {
        self.currentUserId = currentUserId
    }

    deinit { listener?.remove() }

    // MARK: - Listen My Requests (technician)
    @discardableResult
    
    func listenMyRequests(onChange: @escaping ([Request]) -> Void) -> ListenerRegistration {

        listener?.remove()

        //  حل مؤقت بدون تسجيل دخول
        let demoUserId = "ATSunrOKb4Uwstb181mIkiaxOwD3"   // حطي UID حق الفني اللي تبغينه
        let uid = currentUserId.isEmpty ? demoUserId : currentUserId

        print("👤 listenMyRequests uid =", uid)

        let reg = db.collection(FBCollections.requests)
            .whereField("servicerRef", isEqualTo: uid)     // ✅ String عادي
            .whereField("inactive", isEqualTo: false)
            .addSnapshotListener { snap, error in

                if let error {
                    print("🔥 Firestore error:", error)
                }

                let docs = snap?.documents ?? []
                print("✅ requests docs:", docs.count)

                let dtos: [FirestoreRequestDTO] = docs.compactMap { doc in
                    try? doc.data(as: FirestoreRequestDTO.self)
                }

                onChange(dtos.compactMap(FirestoreRequestMapper.toModel))
            }

        listener = reg
        return reg
    }

    // MARK: - Fetch Single Request
    func fetchRequest(by id: UUID) async -> Request? {
        do {
            let doc = try await db.collection(FBCollections.requests)
                .document(id.uuidString)   // ✅ doc id = UUID string
                .getDocument()

            let dto = try doc.data(as: FirestoreRequestDTO.self)
            return FirestoreRequestMapper.toModel(dto)
        } catch {
            print("🔥 fetchRequest error:", error)
            return nil
        }
    }

    // MARK: - Schedule
    func schedule(requestId: UUID, from: Date, to: Date) async {
        do {
            try await db.collection(FBCollections.requests)
                .document(requestId.uuidString)
                .updateData([
                    "estimatedStartDate": from,
                    "estimatedEndDate": to,
                    "modifiedOn": Date(),
                    "modifiedBy": currentUserId  // ✅ String UID
                ])
        } catch {
            print("🔥 schedule error:", error)
        }
    }

    // MARK: - Start
    func start(requestId: UUID) async {
        do {
            try await db.collection(FBCollections.requests)
                .document(requestId.uuidString)
                .updateData([
                    "actualStartDate": Date(),
                    "status": Status.inProgress.rawValue,
                    "modifiedOn": Date(),
                    "modifiedBy": currentUserId
                ])
        } catch {
            print("🔥 start error:", error)
        }
    }

    // MARK: - Complete
    func markCompleted(requestId: UUID) async {
        do {
            try await db.collection(FBCollections.requests)
                .document(requestId.uuidString)
                .updateData([
                    "actualEndDate": Date(),
                    "status": Status.completed.rawValue,
                    "modifiedOn": Date(),
                    "modifiedBy": currentUserId
                ])
        } catch {
            print("🔥 markCompleted error:", error)
        }
    }

    // MARK: - Update Status
    func updateStatus(requestId: UUID, status: Status, modifiedBy: String) async {
        do {
            try await db.collection(FBCollections.requests)
                .document(requestId.uuidString)
                .updateData([
                    "status": status.rawValue,
                    "modifiedOn": Date(),
                    "modifiedBy": modifiedBy  // ✅ String UID (مررّتيه من VM)
                ])
        } catch {
            print("🔥 updateStatus error:", error)
        }
    }

    // MARK: - Send Back
    func sendBack(requestId: UUID, reason: String, modifiedBy: String) async {
        do {
            try await db.collection(FBCollections.requests)
                .document(requestId.uuidString)
                .updateData([
                    "status": Status.onHold.rawValue,
                    "sendBackReason": reason,
                    "modifiedOn": Date(),
                    "modifiedBy": modifiedBy
                ])
        } catch {
            print("🔥 sendBack error:", error)
        }
    }
}
