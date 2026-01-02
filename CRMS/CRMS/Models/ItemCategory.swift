//
//  ReqCategory.swift
//  Inventory
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation
import UIKit

struct ItemCategoryModel: Codable, Identifiable {
    var id: String
    var name: String
    var isParent: Bool
    var parentCategoryRef: String?
    var createdOn: Date
    var createdBy: String
    var modifiedOn: Date?
    var modifiedBy: String?
    var inactive: Bool
    
    // UI state
    var isExpanded: Bool = true
}
