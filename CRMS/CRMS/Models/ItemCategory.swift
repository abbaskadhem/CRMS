//
//  ReqCategory.swift
//  Inventory
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation
import UIKit

struct ItemCategoryModel: Codable, Identifiable {
    var id: UUID
    var name: String
    var isParent: Bool
    var parentCategoryRef: UUID?
    var createdOn: Date
    var createdBy: UUID
    var modifiedOn: Date?
    var modifiedBy: UUID?
    var inactive: Bool
    
    // UI state
    var isExpanded: Bool = true
}
