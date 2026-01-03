import SwiftUI

// Main screen that displays the list of technician requests
struct RequestsListView: View {

    // Currently selected request
    @State private var selectedRequest: RequestUIModel?

    // Controls filter sheet visibility
    @State private var showFilterSheet = false

    // View model that provides request data
    @StateObject private var vm = RequestListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

                // Background color
                Color(red: 0.97, green: 0.95, blue: 0.93)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {

                        // Search bar and filter button
                        HStack(spacing: 10) {
                            TextField("Search", text: $vm.searchText)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )

                            Button {
                                showFilterSheet = true
                            } label: {
                                Image("Filter1")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(red: 87/255, green: 104/255, blue: 125/255))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 2)

                        // List of request cards
                        VStack(spacing: 14) {
                            ForEach(vm.filteredRequests) { item in
                                Button {
                                    selectedRequest = item
                                } label: {
                                    RequestRowView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            // Navigate to request details
            .navigationDestination(item: $selectedRequest) { item in
                RequestDetailView(item: item)
            }
            // Filter sheet
            .sheet(isPresented: $showFilterSheet) {
                RequestFilterSheet(filter: $vm.filter)
            }
        }
    }
}
