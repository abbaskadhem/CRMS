import SwiftUI

struct RequestRowView: View {
    let item: RequestUIModel

    var body: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 10) {
                Spacer()

                // Top row
                HStack(alignment: .firstTextBaseline) {
                    
                    Text(item.requestNo)
                        .font(.system(size: 17, weight: .semibold)) 

                    Spacer()

                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.status.color)
                            .frame(width: 12, height: 12)

                        Text("\(item.status)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }

                // Priority
                (
                    Text("Priority: ")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)                    +
                    Text("\(item.priority)")
                        .foregroundColor(item.priority.color)
                )
                .font(.system(size: 14, weight: .regular))

                // Location
                Text("\(item.buildingName) - \(item.roomName)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                // Category
                Text(item.categoryText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                // Date
                Text(item.formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Bottom chevron
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)        //  عشان النص مايلزق بالحدود
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.clear)))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.gray), lineWidth: 2))
    }
}
