//
//  ImageRowView.swift
//  TechRequestMangment
//
//  Created by Zinab Zooba on 18/12/2025.
//

import SwiftUI
import FirebaseFirestore

struct ImageRowView: View {
    let urlString: String
    let fileName: String
    
    var onPreview: (() -> Void)? = nil
    var onDownload: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            
            // اسم الملف داخل صندوق صغير
            Text(fileName)
                .font(.subheadline)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 30)
                .padding(.vertical, 8)
                .frame(minWidth: 180, alignment: .leading)  
                .background(Color(.systemGray6))
                .cornerRadius(6)
            
            Spacer()
            
            Button {
                onPreview?()
            } label: {
                Image(systemName: "eye")
            }
            
            Button {
                onDownload?()
            } label: {
                Image(systemName: "arrow.down")
            }
            
        }.onAppear {
            Firestore.firestore().collection("test").addDocument(data: [
                "ok": true
            ])
        }

        .foregroundColor(.gray)
    }
}
