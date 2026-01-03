import SwiftUI

// A sheet view that lets the user filter requests by date range and status
struct RequestFilterSheet: View {

    // The filter model that will be updated from this sheet
    @Binding var filter: RequestFilter

    // Used to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    // Background color used across the sheet
    private let bg = Color(red: 0.97, green: 0.95, blue: 0.93)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {

                // Sheet title
                Text("Filter")
                    .font(.headline)
                    .padding(.vertical, 16)

                Divider().opacity(0.4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Date filtering section
                        sectionHeader("By Dates:")

                        // From date picker row
                        dateRow(title: "From", field: .from, date: $filter.fromDate)

                        // To date picker row
                        dateRow(title: "To", field: .to, date: $filter.toDate)

                        Divider().opacity(0.25)

                        // Status filtering section
                        sectionHeader("By Status:")

                        // Multi select list of statuses
                        ForEach(Status.allCases, id: \.self) { st in
                            checkboxRow(
                                title: st.displayName,
                                isOn: Binding(
                                    get: { filter.statuses.contains(st) },
                                    set: { value in
                                        if value {
                                            filter.statuses.insert(st)
                                        } else {
                                            filter.statuses.remove(st)
                                        }
                                    }
                                )
                            )
                        }
                    }
                    .padding(18)
                }

                // Apply button closes the sheet and keeps selected values in the binding
                Button {
                    dismiss()
                } label: {
                    Text("Filter")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(Color(red: 0.34, green: 0.40, blue: 0.48))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 6)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
        .presentationDetents([.medium, .large])
    }

    // Builds a styled section header with a thin line under it
    private func sectionHeader(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(Color(red: 0.45, green: 0.63, blue: 0.80))

            Rectangle()
                .fill(Color(red: 0.45, green: 0.63, blue: 0.80).opacity(0.45))
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Builds a single date row with a custom label and a hidden DatePicker on top
    private func dateRow(title: String, field: DateField, date: Binding<Date?>) -> some View {

        // Display text based on whether a date is selected
        let labelText = (date.wrappedValue == nil)
        ? "Select a date"
        : date.wrappedValue!.formatted(date: .abbreviated, time: .omitted)

        return HStack {
            Text(title).font(.system(size: 18))
            Spacer()

            ZStack {
                // The actual DatePicker is nearly invisible but still receives taps
                DatePicker(
                    "",
                    selection: Binding(
                        get: { date.wrappedValue ?? Date() },
                        set: { newValue in
                            date.wrappedValue = newValue
                            normalizeDates()
                        }
                    ),
                    in: allowedRange(for: field),
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .opacity(0.02)

                // The visible label shown to the user
                Text(labelText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.45, green: 0.63, blue: 0.80).opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .allowsHitTesting(false)
            }
        }
    }

    // Builds a checkbox row used for multi selecting request statuses
    private func checkboxRow(title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray.opacity(0.6), lineWidth: 1)
                    .frame(width: 22, height: 22)
                    .overlay {
                        if isOn.wrappedValue {
                            Image(systemName: "checkmark")
                        }
                    }

                Text(title)
                    .font(.system(size: 18))

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    // Ensures the To date is not earlier than the From date
    private func normalizeDates() {
        if let from = filter.fromDate, let to = filter.toDate, to < from {
            filter.toDate = from
        }
    }

    // Limits date selection based on the other selected date
    private func allowedRange(for field: DateField) -> ClosedRange<Date> {
        let min = Date.distantPast
        let max = Date.distantFuture

        switch field {
        case .from:
            if let to = filter.toDate { return min...to }
            return min...max
        case .to:
            if let from = filter.fromDate { return from...max }
            return min...max
        }
    }

    // Identifies which date picker is being edited
    private enum DateField { case from, to }
}
