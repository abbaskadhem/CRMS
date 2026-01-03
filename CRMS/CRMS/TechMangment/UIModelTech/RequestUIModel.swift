//
//  Untitled.swift
//  TechRequestMangment
//
//  Created by Zinab Zooba on 17/12/2025.
//


import SwiftUI
struct RequestUIModel: Identifiable, Hashable {
    let id: String
    let requestNo: String
    let description: String
    let imageURLs: [String]   // مؤقتًا حطي رابط واحد من الإنترنت
    var statusText: String { "\(status)" }   // مؤقت
    var priorityText: String { "\(priority)" } // مؤقت
    // البيانات المعالجة (التي تم جلبها)
    let buildingName: String // هنا سنضع الاسم وليس الـ ID
    let roomName: String
    
    let mainCategoryName: String
    let subCategoryName: String

    // مشتق (computed)
    var categoryText: String {
        "\(mainCategoryName) - \(subCategoryName)"
    }

    let priority: Priority
    let status: Status
    let createdOn: Date
    
    // MARK: - تنسيقات للعرض (Formatting Logic)
    
    // 1. تحويل التاريخ إلى نص مقروء
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // تنسيق مثل: 12/12/2025
        return formatter.string(from: createdOn)
    }
    
}
