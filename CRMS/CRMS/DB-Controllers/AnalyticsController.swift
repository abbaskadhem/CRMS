//
//  AnalyticsController.swift
//  CRMS
//
//  Created by Claude Code on 02/01/2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Analytics Data Models

/// Request status analytics data
struct RequestStatusAnalytics {
    let completed: Int
    let inProgress: Int
    let onHold: Int
    let cancelled: Int
}

/// Escalation analytics data
struct EscalationAnalytics {
    let totalRequests: Int
    let escalatedCount: Int
    let nonEscalatedCount: Int
}

/// Category analytics data
struct CategoryAnalytics {
    let topCategories: [(name: String, count: Int)]
    let topSubCategories: [(name: String, count: Int)]
}

/// Servicer time analytics data
struct ServicerTimeAnalytics {
    let servicerData: [(name: String, avgDays: Double)]
    let overallAvgDays: Double
}

// MARK: - Analytics Controller

final class AnalyticsController {

    static let shared = AnalyticsController()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Request Status Analytics

    /// Fetch request status analytics (completed, in progress, on hold, cancelled)
    /// - Returns: RequestStatusAnalytics containing counts for each status
    /// - Throws: NetworkError if connectivity fails or server is unavailable
    func fetchRequestStatusAnalytics() async throws -> RequestStatusAnalytics {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        do {
            let snapshot = try await db.collection("Request").getDocuments()

            var completed = 0
            var inProgress = 0
            var onHold = 0
            var cancelled = 0

            for doc in snapshot.documents {
                guard let statusValue = doc["status"] as? Int,
                      let status = Status(rawValue: statusValue) else {
                    continue
                }

                switch status {
                case .completed:
                    completed += 1
                case .onHold:
                    onHold += 1
                case .submitted, .assigned, .inProgress, .delayed:
                    inProgress += 1
                case .cancelled:
                    cancelled += 1
                }
            }

            return RequestStatusAnalytics(
                completed: completed,
                inProgress: inProgress,
                onHold: onHold,
                cancelled: cancelled
            )
        } catch {
            throw NetworkError.serverUnavailable
        }
    }

    // MARK: - Escalation Analytics

    /// Fetch escalation analytics (escalated vs non-escalated requests)
    /// - Returns: EscalationAnalytics containing escalation statistics
    /// - Throws: NetworkError if connectivity fails or server is unavailable
    func fetchEscalationAnalytics() async throws -> EscalationAnalytics {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        do {
            let requestSnap = try await db.collection("Request").getDocuments()
            let totalRequests = requestSnap.documents.count

            let historySnap = try await db.collection("RequestHistory").getDocuments()

            var escalatedRequests: Set<String> = []

            for doc in historySnap.documents {
                guard let requestRef = doc["requestRef"] as? String,
                      let actionValue = doc["action"] as? Int,
                      let action = Action(rawValue: actionValue) else {
                    continue
                }

                if action == .sentBack || action == .reassigned || action == .delayed {
                    escalatedRequests.insert(requestRef)
                }
            }

            let escalatedCount = escalatedRequests.count
            let nonEscalatedCount = totalRequests - escalatedCount

            return EscalationAnalytics(
                totalRequests: totalRequests,
                escalatedCount: escalatedCount,
                nonEscalatedCount: nonEscalatedCount
            )
        } catch {
            throw NetworkError.serverUnavailable
        }
    }

    // MARK: - Category Analytics

    /// Fetch top 5 categories and subcategories by request count
    /// - Returns: CategoryAnalytics containing top categories and subcategories
    /// - Throws: NetworkError if connectivity fails or server is unavailable
    func fetchCategoryAnalytics() async throws -> CategoryAnalytics {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        do {
            let requestSnap = try await db.collection("Request").getDocuments()
            let categorySnap = try await db.collection("RequestCategory").getDocuments()

            var categoryCount: [String: Int] = [:]
            var subCategoryCount: [String: Int] = [:]

            // Count requests per category/subcategory
            for doc in requestSnap.documents {
                if let catRef = doc["requestCategoryRef"] as? String {
                    categoryCount[catRef, default: 0] += 1
                }

                if let subRef = doc["requestSubcategoryRef"] as? String {
                    subCategoryCount[subRef, default: 0] += 1
                }
            }

            var categories: [(String, Int)] = []
            var subCategories: [(String, Int)] = []

            // Convert IDs to names
            for doc in categorySnap.documents {
                let id = doc.documentID
                let name = doc["name"] as? String ?? "Unknown"
                let isParent = doc["isParent"] as? Bool ?? false

                if isParent, let count = categoryCount[id] {
                    categories.append((name, count))
                }

                if !isParent, let count = subCategoryCount[id] {
                    subCategories.append((name, count))
                }
            }

            // Sort and take top 5
            let topCategories = Array(categories.sorted { $0.1 > $1.1 }.prefix(5))
            let topSubCategories = Array(subCategories.sorted { $0.1 > $1.1 }.prefix(5))

            return CategoryAnalytics(
                topCategories: topCategories,
                topSubCategories: topSubCategories
            )
        } catch {
            throw NetworkError.serverUnavailable
        }
    }

    // MARK: - Servicer Time Analytics

    /// Fetch average time to solve requests per servicer
    /// - Returns: ServicerTimeAnalytics containing servicer data and overall average
    /// - Throws: NetworkError if connectivity fails or server is unavailable
    func fetchServicerTimeAnalytics() async throws -> ServicerTimeAnalytics {
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        do {
            let snapshot = try await db.collection("Request").getDocuments()

            var serTimes: [String: [Double]] = [:]

            // Gather request durations per servicer
            for doc in snapshot.documents {
                guard let serId = doc["servicerRef"] as? String else {
                    continue
                }

                var days: Double = 0

                if let startTimestamp = doc["actualStartDate"] as? Timestamp,
                   let endTimestamp = doc["actualEndDate"] as? Timestamp {

                    let startDate = startTimestamp.dateValue()
                    let endDate = endTimestamp.dateValue()

                    let seconds = endDate.timeIntervalSince(startDate)
                    days = seconds / 86400.0
                }

                if days > 0 {
                    serTimes[serId, default: []].append(days)
                }
            }

            var results: [(String, Double)] = []

            // Fetch servicer names and calculate averages
            for (serId, daysArray) in serTimes {
                let avgDays = daysArray.reduce(0, +) / Double(daysArray.count)

                let serDoc = try await db.collection("User").document(serId).getDocument()
                let name = serDoc.get("fullName") as? String ?? "Unknown"

                results.append((name, avgDays))
            }

            // Calculate overall average
            let overallAvg = results.map { $0.1 }.reduce(0, +) / Double(max(results.count, 1))

            return ServicerTimeAnalytics(
                servicerData: results,
                overallAvgDays: overallAvg
            )
        } catch {
            throw NetworkError.serverUnavailable
        }
    }
}
