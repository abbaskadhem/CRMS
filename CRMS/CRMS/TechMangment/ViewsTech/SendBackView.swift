import SwiftUI

// View used to send a request back to the admin with a required reason
struct SendBackView: View {

    // Used to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    // Holds the reason text entered by the user
    @State private var reason: String = ""

    // View model that performs request actions
    let vm: RequestDetailViewModel

    // Callback triggered after successful send back
    let onSuccess: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 16) {

                // Screen title
                Text("Send Request Back to Admin")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                Divider()
                    .padding(.bottom, 50)

                // Instruction text
                Text("Please provide the reason of sending this request back to the admin")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

                // Text editor for entering the reason
                TextEditor(text: $reason)
                    .frame(height: 140)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                HStack(spacing: 16) {

                    // Cancel button closes the sheet
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .foregroundColor(.black)

                    // Send button submits the reason and updates the request
                    Button("Send") {
                        Task {
                            await vm.sendBack(reason: reason)
                            dismiss()
                            onSuccess()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.33, green: 0.41, blue: 0.50))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
            }
            .padding()
        }
        .background(Color(red: 0.97, green: 0.95, blue: 0.93))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
