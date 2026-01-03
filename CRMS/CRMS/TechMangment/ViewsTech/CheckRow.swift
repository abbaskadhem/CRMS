//
//  Untitled.swift
//  CRMS
//

//
//  CheckRow.swift
//  CRMS
//
//  A reusable row view that displays a title with a checkmark.
//  The checkmark changes based on the `isChecked` state,
//  and triggers an action when the row is tapped.
//

import SwiftUI

struct CheckRow: View {
    /// The text displayed next to the checkmark
    let title: String
    
    /// Indicates whether the row is checked or not
    let isChecked: Bool
    
    /// Action executed when the row is tapped
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Shows a filled checkmark when checked, otherwise an empty square
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                
                // Row title
                Text(title)
                
                Spacer()
            }
        }
        // Removes the default button styling
        .buttonStyle(.plain)
    }
}
