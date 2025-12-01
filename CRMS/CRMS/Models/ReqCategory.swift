//
//  ReqCategories.swift
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

import Foundation

struct RequestCategory: Codable, Identifiable {
    var id: UUID                     // UUID
    var name: String                 // Name
    var isParent: Bool               // Is Parent?
    var parentCategoryRef: UUID?     // Parent Category Ref.

    // Default Common Fields
    var createdOn: Date              // Created on
    var createdBy: UUID              // Created by
    var modifiedOn: Date?            // Modified on
    var modifiedBy: UUID?            // Modified by
    var inactive: Bool               // Inactive
}

