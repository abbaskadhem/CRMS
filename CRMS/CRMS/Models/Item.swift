//
//  Item.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

struct ItemModel: Codable, Identifiable {
    var id: String                  // UUID
    var name: String              // Name
    var partNo: String?           // Part No.
    var unitCost: Double?         // Unit Cost
    var vendor: String?           // Vendor
    var itemCategoryRef: String?    // Item Category Ref.
    var itemSubcategoryRef: String? // Item Subcategory Ref.
    var quantity: Int?            // Quantity
    var description: String?      // Description
    var usage: String?            // Usage

    // Default Common Fields
    var createdOn: Date           // Created on
    var createdBy: String         // Created by (Firebase Auth UID)
    var modifiedOn: Date?         // Modified on
    var modifiedBy: String?       // Modified by (Firebase Auth UID)
    var inactive: Bool            // Inactive
}
