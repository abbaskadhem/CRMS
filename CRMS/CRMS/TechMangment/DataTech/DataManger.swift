import Foundation
import FirebaseFirestore

// Central data manager responsible for syncing shared lookup data from Firestore
final class DataManager: ObservableObject {

    // Shared singleton instance used across the app
    static let shared = DataManager()

    // Published lists that update SwiftUI views automatically
    @Published var buildings: [Building] = []
    @Published var rooms: [Room] = []
    @Published var categories: [RequestCategory] = []

    // Firestore listeners to keep real-time updates
    private var buildingsListener: ListenerRegistration?
    private let buildingsRepo = FirestoreBuildingRepository()

    private var roomsListener: ListenerRegistration?
    private let roomsRepo = FirestoreRoomRepository()

    // Loader and listener for lookup data such as categories
    private let lookups = FirestoreLookupsLoader()
    private var catReg: ListenerRegistration?

    // Private initializer to enforce singleton usage
    private init() {
        startBuildingsSync()
        startRoomsSync()
        startCategoriesSync()
    }

    // Starts listening to buildings collection and maps DTOs to domain models
    private func startBuildingsSync() {
        // Remove any existing listener before creating a new one
        buildingsListener?.remove()

        buildingsListener = buildingsRepo.listenBuildings { [weak self] dtos in
            guard let self else { return }

            // Convert Firestore DTOs into Building models
            let mapped: [Building] = dtos.compactMap { dto in
                guard let id = UUID(uuidString: dto.id) else { return nil }

                return Building(
                    id: id,
                    buildingNo: dto.buildingNo,
                    createdOn: dto.createdOn ?? Date(),
                    createdBy: dto.createdBy ?? "",
                    modifiedOn: dto.modifiedOn,
                    modifiedBy: dto.modifiedBy,
                    inactive: dto.inactive
                )
            }

            // Update published property on the main thread
            DispatchQueue.main.async {
                self.buildings = mapped
            }
        }
    }

    // Starts listening to rooms collection and maps DTOs to domain models
    private func startRoomsSync() {
        // Remove any existing listener before creating a new one
        roomsListener?.remove()

        roomsListener = roomsRepo.listenRooms { [weak self] dtos in
            guard let self else { return }

            // Convert Firestore DTOs into Room models
            let mapped: [Room] = dtos.compactMap { dto in
                guard
                    let idStr = dto.id,
                    let id = UUID(uuidString: idStr),
                    let buildingId = UUID(uuidString: dto.buildingRef)
                else { return nil }

                return Room(
                    id: id,
                    roomNo: dto.roomNo,
                    buildingRef: buildingId,
                    createdOn: dto.createdOn ?? Date(),
                    createdBy: dto.createdBy ?? "",
                    modifiedOn: dto.modifiedOn,
                    modifiedBy: dto.modifiedBy,
                    inactive: dto.inactive
                )
            }

            // Update published property on the main thread
            DispatchQueue.main.async {
                self.rooms = mapped
            }
        }
    }

    // Starts listening to request categories lookup data
    private func startCategoriesSync() {
        // Remove existing category listener if any
        catReg?.remove()

        catReg = lookups.listenCategories { [weak self] cats in
            // Update categories on the main thread
            DispatchQueue.main.async {
                self?.categories = cats
            }
        }
    }

    // Clean up all Firestore listeners when the manager is deallocated
    deinit {
        buildingsListener?.remove()
        roomsListener?.remove()
        catReg?.remove()
    }
}
