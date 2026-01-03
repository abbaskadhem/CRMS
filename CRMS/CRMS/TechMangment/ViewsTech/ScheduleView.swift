import SwiftUI

// View used to schedule estimated start and end dates for a request
struct ScheduleView: View {

    // Used to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    // Selected start date
    @State private var startDate = Date()

    // Selected end date
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    // Callback triggered when the user confirms scheduling
    let onConfirm: (Date, Date) -> Void

    var body: some View {
        VStack(spacing: 0) {

            // Title
            Text("Schedule Maintenance")
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 20)

            Divider()
                .padding(.bottom, 50)

            // Section showing date pickers
            VStack(alignment: .leading, spacing: 8) {

                Text("Estimated Time")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)

                Divider()

                // Start date picker
                HStack {
                    Text("Start Date")
                    Spacer()
                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }

                // End date picker
                HStack {
                    Text("End Date")
                    Spacer()
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 18)

            // Submit button
            Button {
                onConfirm(startDate, endDate)
                dismiss()
            } label: {
                Text("Submit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.33, green: 0.41, blue: 0.50))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.97, green: 0.95, blue: 0.93))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
