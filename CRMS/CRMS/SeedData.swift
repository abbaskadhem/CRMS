//
//  SeedData.swift
//  CRMS
//
//  Temporary file to seed Firestore collections with sample data.
//  Call SeedData.seedAllCollections() from AppDelegate or a test button.
//  DELETE THIS FILE after seeding is complete.
//

import Foundation
import FirebaseFirestore

class SeedData {

    private static let db = Firestore.firestore()

    // MARK: - Main Seed Function
    static func seedAllCollections() async {
        print("🌱 Starting database seeding...")

        do {
            // Placeholder system ID for createdBy fields (use "system" or a Firebase Auth UID)
            let systemId = "system"

            // Seed in order of dependencies
            try await seedCounters()
            let (buildingIds, roomIds) = try await seedLocations(createdBy: systemId)
            let (categoryIds, subcategoryIds) = try await seedRequestCategories(createdBy: systemId)
            let (itemCategoryIds, itemSubcategoryIds) = try await seedItemCategories(createdBy: systemId)
            try await seedItems(createdBy: systemId, categoryId: itemCategoryIds.first!, subcategoryId: itemSubcategoryIds.first!)
            try await seedFAQs(createdBy: systemId)
            try await seedRequests(createdBy: systemId, buildingId: buildingIds.first!, roomId: roomIds.first!, categoryId: categoryIds.first!, subcategoryId: subcategoryIds.first!)
            try await seedNotifications(createdBy: systemId)

            print("✅ Database seeding completed successfully!")
        } catch {
            print("❌ Seeding failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Counters (for autonumbering)
    private static func seedCounters() async throws {
        let collection = db.collection("Counters")

        try await collection.document("requests").setData([
            "lastNumber": 0,
            "format": "REQ-%05d"
        ])

        try await collection.document("requestHistories").setData([
            "lastNumber": 0,
            "format": "HIS-%05d"
        ])

        try await collection.document("requestFeedbacks").setData([
            "lastNumber": 0,
            "format": "FBK-%05d"
        ])

        print("  ✓ Seeded 3 counters")
    }

    // MARK: - Locations (Buildings & Rooms)
    private static func seedLocations(createdBy: String) async throws -> ([UUID], [UUID]) {
        let buildingCollection = db.collection("Building")
        let roomCollection = db.collection("Room")
        let now = Timestamp(date: Date())

        var buildingIds: [UUID] = []
        var roomIds: [UUID] = []

        // Buildings
        let buildingData = ["19", "36", "5"]
        for buildingNo in buildingData {
            let id = UUID()
            try await buildingCollection.document(id.uuidString).setData([
                "id": id.uuidString,
                "buildingNo": buildingNo,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            buildingIds.append(id)
        }

        // Rooms for first building
        let roomData = ["101", "102", "103", "201", "202"]
        for roomNo in roomData {
            let id = UUID()
            try await roomCollection.document(id.uuidString).setData([
                "id": id.uuidString,
                "roomNo": roomNo,
                "buildingRef": buildingIds[0].uuidString,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            roomIds.append(id)
        }

        print("  ✓ Seeded 3 buildings and 5 rooms")
        return (buildingIds, roomIds)
    }

    // MARK: - Request Categories
    private static func seedRequestCategories(createdBy: String) async throws -> ([UUID], [UUID]) {
        let collection = db.collection("RequestCategory")
        let now = Timestamp(date: Date())

        var categoryIds: [UUID] = []
        var subcategoryIds: [UUID] = []

        // Parent categories: IT, Electrical, HVAC
        let parentCategories = ["IT", "Electrical", "HVAC"]
        for name in parentCategories {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "isParent": true,
                "parentCategoryRef": NSNull(),
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            categoryIds.append(id)
        }

        // Subcategories for IT
        let itSubs = ["Hardware", "Software", "Network"]
        for name in itSubs {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "isParent": false,
                "parentCategoryRef": categoryIds[0].uuidString,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            subcategoryIds.append(id)
        }

        // Subcategories for Electrical
        let electricalSubs = ["Lighting", "Power Outlet", "Wiring"]
        for name in electricalSubs {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "isParent": false,
                "parentCategoryRef": categoryIds[1].uuidString,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            subcategoryIds.append(id)
        }

        // Subcategories for HVAC
        let hvacSubs = ["Heating", "Ventilation", "Air Conditioning"]
        for name in hvacSubs {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "isParent": false,
                "parentCategoryRef": categoryIds[2].uuidString,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            subcategoryIds.append(id)
        }

        print("  ✓ Seeded 3 request categories and 9 subcategories")
        return (categoryIds, subcategoryIds)
    }

    // MARK: - Item Categories
    private static func seedItemCategories(createdBy: String) async throws -> ([UUID], [UUID]) {
        let collection = db.collection("ItemCategory")
        let now = Timestamp(date: Date())

        var categoryIds: [UUID] = []
        var subcategoryIds: [UUID] = []

        // Parent categories
        let parentCategories = ["Tools", "Parts", "Supplies"]
        for name in parentCategories {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "isParent": true,
                "parentCategoryRef": NSNull(),
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            categoryIds.append(id)
        }

        // Subcategories for Tools
        let toolSubs = ["Hand Tools", "Power Tools"]
        for name in toolSubs {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "isParent": false,
                "parentCategoryRef": categoryIds[0].uuidString,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
            subcategoryIds.append(id)
        }

        print("  ✓ Seeded 3 item categories and 2 subcategories")
        return (categoryIds, subcategoryIds)
    }

    // MARK: - Items
    private static func seedItems(createdBy: String, categoryId: UUID, subcategoryId: UUID) async throws {
        let collection = db.collection("Item")
        let now = Timestamp(date: Date())

        let items: [(String, String, Double, String, Int)] = [
            ("Screwdriver Set", "TL-001", 25.99, "ToolMart", 10),
            ("Pipe Wrench", "TL-002", 35.50, "PlumbSupply", 5),
            ("LED Light Bulb 10W", "PT-001", 8.99, "ElectroShop", 50)
        ]

        for (name, partNo, cost, vendor, qty) in items {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "name": name,
                "partNo": partNo,
                "unitCost": cost,
                "vendor": vendor,
                "itemCategoryRef": categoryId.uuidString,
                "itemSubcategoryRef": subcategoryId.uuidString,
                "quantity": qty,
                "description": "Sample \(name) for maintenance",
                "usage": "General maintenance",
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
        }

        print("  ✓ Seeded 3 items")
    }

    // MARK: - FAQs
    private static func seedFAQs(createdBy: String) async throws {
        let collection = db.collection("Faq")
        let now = Timestamp(date: Date())

        let faqs = [
            ("How do I submit a maintenance request?", "Navigate to the 'Submit Request' section, fill in the required details including location, category, and description, then tap Submit."),
            ("How long does it take to process a request?", "Standard requests are typically processed within 24-48 hours. Emergency requests are prioritized and handled as soon as possible."),
            ("Can I track the status of my request?", "Yes, you can view all your submitted requests and their current status in the 'My Requests' section.")
        ]

        for (question, answer) in faqs {
            let id = UUID()
            try await collection.document(id.uuidString).setData([
                "id": id.uuidString,
                "question": question,
                "answer": answer,
                "createdOn": now,
                "createdBy": createdBy,
                "modifiedOn": NSNull(),
                "modifiedBy": NSNull(),
                "inactive": false
            ])
        }

        print("  ✓ Seeded 3 FAQs")
    }

    // MARK: - Requests
    private static func seedRequests(createdBy: String, buildingId: UUID, roomId: UUID, categoryId: UUID, subcategoryId: UUID) async throws {
        let requestCollection = db.collection("Request")
        let historyCollection = db.collection("RequestHistory")
        let feedbackCollection = db.collection("RequestFeedback")
        let now = Date()
        let nowTimestamp = Timestamp(date: now)

        // Request 1: Submitted
        let request1Id = UUID()
        try await requestCollection.document(request1Id.uuidString).setData([
            "id": request1Id.uuidString,
            "requestNo": "REQ-00001",
            "requesterRef": createdBy,
            "requestCategoryRef": categoryId.uuidString,
            "requestSubcategoryRef": subcategoryId.uuidString,
            "buildingRef": buildingId.uuidString,
            "roomRef": roomId.uuidString,
            "description": "Light fixture in room 101 is flickering and needs replacement.",
            "images": NSNull(),
            "priority": Priority.moderate.rawValue,
            "status": Status.submitted.rawValue,
            "servicerRef": NSNull(),
            "estimatedStartDate": NSNull(),
            "estimatedEndDate": NSNull(),
            "actualStartDate": NSNull(),
            "actualEndDate": NSNull(),
            "ownerId": createdBy,
            "createdOn": nowTimestamp,
            "createdBy": createdBy,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])

        // History for Request 1
        let history1Id = UUID()
        try await historyCollection.document(history1Id.uuidString).setData([
            "id": history1Id.uuidString,
            "historyNo": "HIS-00001",
            "requestRef": request1Id.uuidString,
            "action": Action.submitted.rawValue,
            "sentBackReason": NSNull(),
            "reassignReason": NSNull(),
            "createdOn": nowTimestamp,
            "createdBy": createdBy,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])

        // Request 2: In Progress
        let request2Id = UUID()
        let yesterdayTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: -1, to: now)!)
        let twoDaysLaterTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: 2, to: now)!)

        try await requestCollection.document(request2Id.uuidString).setData([
            "id": request2Id.uuidString,
            "requestNo": "REQ-00002",
            "requesterRef": createdBy,
            "requestCategoryRef": categoryId.uuidString,
            "requestSubcategoryRef": subcategoryId.uuidString,
            "buildingRef": buildingId.uuidString,
            "roomRef": roomId.uuidString,
            "description": "Power outlet near the window is not working.",
            "images": NSNull(),
            "priority": Priority.high.rawValue,
            "status": Status.inProgress.rawValue,
            "servicerRef": createdBy,
            "estimatedStartDate": nowTimestamp,
            "estimatedEndDate": twoDaysLaterTimestamp,
            "actualStartDate": nowTimestamp,
            "actualEndDate": NSNull(),
            "ownerId": createdBy,
            "createdOn": yesterdayTimestamp,
            "createdBy": createdBy,
            "modifiedOn": nowTimestamp,
            "modifiedBy": createdBy,
            "inactive": false
        ])

        // Request 3: Completed with Feedback
        let request3Id = UUID()
        let sevenDaysAgoTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: -7, to: now)!)
        let fiveDaysAgoTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: -5, to: now)!)
        let threeDaysAgoTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: -3, to: now)!)

        try await requestCollection.document(request3Id.uuidString).setData([
            "id": request3Id.uuidString,
            "requestNo": "REQ-00003",
            "requesterRef": createdBy,
            "requestCategoryRef": categoryId.uuidString,
            "requestSubcategoryRef": subcategoryId.uuidString,
            "buildingRef": buildingId.uuidString,
            "roomRef": roomId.uuidString,
            "description": "AC unit making unusual noise.",
            "images": NSNull(),
            "priority": Priority.low.rawValue,
            "status": Status.completed.rawValue,
            "servicerRef": createdBy,
            "estimatedStartDate": fiveDaysAgoTimestamp,
            "estimatedEndDate": threeDaysAgoTimestamp,
            "actualStartDate": fiveDaysAgoTimestamp,
            "actualEndDate": threeDaysAgoTimestamp,
            "ownerId": createdBy,
            "createdOn": sevenDaysAgoTimestamp,
            "createdBy": createdBy,
            "modifiedOn": threeDaysAgoTimestamp,
            "modifiedBy": createdBy,
            "inactive": false
        ])

        // Feedback for Request 3
        let feedbackId = UUID()
        try await feedbackCollection.document(feedbackId.uuidString).setData([
            "id": feedbackId.uuidString,
            "feedbackNo": "FBK-00001",
            "requestRef": request3Id.uuidString,
            "requesterRef": createdBy,
            "servicerRef": createdBy,
            "starRating": 5,
            "feedbackText": "Excellent service! The issue was resolved quickly and professionally.",
            "createdOn": threeDaysAgoTimestamp,
            "createdBy": createdBy,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])

        print("  ✓ Seeded 3 requests, 1 history record, and 1 feedback")
    }

    // MARK: - Notifications
    private static func seedNotifications(createdBy: String) async throws {
        let collection = db.collection("Notification")
        let now = Timestamp(date: Date())

        // Announcement
        let announcementId = UUID()
        try await collection.document(announcementId.uuidString).setData([
            "id": announcementId.uuidString,
            "title": "System Maintenance Scheduled",
            "description": "The CRMS system will undergo maintenance on Friday from 10 PM to 2 AM. Please save your work before this time.",
            "toWho": [] as [String],
            "type": NotiType.announcement.rawValue,
            "requestRef": NSNull(),
            "createdOn": now,
            "createdBy": createdBy,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])

        // Notification
        let notificationId = UUID()
        try await collection.document(notificationId.uuidString).setData([
            "id": notificationId.uuidString,
            "title": "Request Status Update",
            "description": "Your request REQ-002 has been assigned to a servicer.",
            "toWho": [createdBy],
            "type": NotiType.notification.rawValue,
            "requestRef": NSNull(),
            "createdOn": now,
            "createdBy": createdBy,
            "modifiedOn": NSNull(),
            "modifiedBy": NSNull(),
            "inactive": false
        ])

        print("  ✓ Seeded 2 notifications")
    }
}

// MARK: - Usage Example
/*
 To seed the database, call this from AppDelegate or a button action:

 Task {
     await SeedData.seedAllCollections()
 }

 DELETE THIS FILE after seeding is complete to avoid accidental re-seeding.
*/
