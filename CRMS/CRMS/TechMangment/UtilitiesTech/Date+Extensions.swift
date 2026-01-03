//
//  Untitled.swift
//  TechRequestMangment
//
//

import Foundation

extension DataManager {
    
    // دالة تأخذ ID وترجع اسم المبنى
    func getBuildingName(by id: UUID) -> String {
        // نبحث في مصفوفة المباني عن هذا الـ ID
        if let building = buildings.first(where: { $0.id == id }) {
            return building.buildingNo // وجدنا الاسم!
        }
        return "Unknown Building" // لم نجد المبنى
    }
    
    // دالة تأخذ ID وترجع اسم الغرفة
    func getRoomName(by id: UUID) -> String {
        
        if let room = rooms.first(where: { $0.id == id }) {
            return room.roomNo
        }
        return "Unknown Room"
    }
    func getCategoryName(by id: UUID) -> String {
        categories.first(where: { $0.id == id })?.name ?? "Unknown Category"
    }
    func getMainCategoryName(by id: UUID) -> String { getCategoryName(by: id) }
    func getSubCategoryName(by id: UUID) -> String { getCategoryName(by: id) }
    func getMainAndSubCategory(mainId: UUID, subId: UUID) -> String {
        "\(getCategoryName(by: mainId)) - \(getCategoryName(by: subId))"
    }

    
        
}
