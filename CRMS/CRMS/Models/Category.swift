//
//  Category.swift
//  CRMS
//
//  Created by Macos on 28/12/2025.
//

struct Category {
    let id: String
    let name: String
    var isExpanded: Bool = false
    var subCategories: [SubCategory] = []
}

struct SubCategory {
    var name: String
    var isActive: Bool
}
