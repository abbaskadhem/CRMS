import SwiftUI

// View shown after a request is successfully sent back to the admin
struct SendBackSuccessView: View {

    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.97, green: 0.95, blue: 0.93)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Title
                Text("Send Request Back to Admin")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                Divider()

                Spacer()

                // Success illustration
                Image("Check circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)

                // Success message
                Text("Request sent back to Admin successfully")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 30)

                Spacer()
            }
            .padding()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
