import SwiftUI

// Detail screen that shows a single request info and lets the technician perform actions
struct RequestDetailView: View {

    // Controls start confirmation alert
    @State private var showStartConfirm = false

    // Controls complete confirmation alert
    @State private var showCompleteConfirm = false

    // The selected request UI model passed from the list
    let item: RequestUIModel

    // View model that loads request data and performs updates
    @StateObject private var vm: RequestDetailViewModel

    // Timer used to periodically refresh the request and auto update status
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    // Defines which sheet is currently presented
    private enum ActiveSheet: Identifiable {
        case schedule
        case scheduleSuccess
        case sendBack
        case sendBackSuccess
        var id: Int { hashValue }
    }

    // Initializes the view model using the request id converted to UUID
    init(item: RequestUIModel) {
        self.item = item

        guard let reqUUID = UUID(uuidString: item.id) else {
            _vm = StateObject(
                wrappedValue: RequestDetailViewModel(
                    requestId: UUID(),
                    initialStatus: item.status,
                    repo: FirestoreRequestRepository(currentUserId: SessionManager.shared.currentUserId ?? ""),
                    modifiedBy: SessionManager.shared.currentUserId ?? ""
                )
            )
            return
        }

        _vm = StateObject(
            wrappedValue: RequestDetailViewModel(
                requestId: reqUUID,
                initialStatus: item.status,
                repo: FirestoreRequestRepository(currentUserId: SessionManager.shared.currentUserId ?? ""),
                modifiedBy: SessionManager.shared.currentUserId ?? ""
            )
        )
    }

    // Displayed technician name
    let technicianName: String = "Yumna almubarak"

    // Local copies of estimated dates used to control the UI
    @State private var estimatedFrom: Date? = nil
    @State private var estimatedTo: Date? = nil

    // Controls description preview sheet
    @State private var showDescriptionPreview = false

    // Controls image preview overlay
    @State private var showImagePreview = false
    @State private var selectedImageURL: String? = nil

    // Active sheet state
    @State private var activeSheet: ActiveSheet?

    // Determines the main action button title based on current status and scheduling state
    private var actionTitle: String {
        switch vm.status {
        case .completed:
            return "Completed"
        case .inProgress, .delayed:
            return "Completed"
        case .onHold, .cancelled:
            return "Schedule"
        default:
            if estimatedFrom != nil, estimatedTo != nil { return "Start" }
            return "Schedule"
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.95, blue: 0.93)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    Divider()

                    // Status section with a colored indicator
                    HStack(spacing: 0) {
                        Text("Status:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Circle()
                            .fill(vm.status.color)
                            .frame(width: 12, height: 12)

                        Text("\(vm.status)")
                            .font(.subheadline)
                    }

                    Divider()

                    // Priority label and colored value
                    (
                        Text("Priority: ").foregroundColor(.secondary)
                        + Text("\(item.priority)").foregroundColor(item.priority.color)
                    )
                    .font(.subheadline)

                    Divider()

                    // Technician section
                    HStack {
                        Text("Technician:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(technicianName)
                            .font(.subheadline)
                    }

                    // Estimated time section shown only when dates are available
                    if let from = estimatedFrom, let to = estimatedTo {
                        Divider()

                        Text("Estimated Time:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Divider()

                        HStack {
                            Text("From").font(.subheadline)
                            Spacer()
                            dateChip(date: from)
                        }

                        HStack {
                            Text("To").font(.subheadline)
                            Spacer()
                            dateChip(date: to)
                        }
                    }

                    Divider()

                    // Problem section
                    Text("Problem")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Divider()

                    Text("Main Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    boxedField(text: item.mainCategoryName)

                    Text("Sub-Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    boxedField(text: item.subCategoryName)

                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Description box with preview button
                    ZStack(alignment: .bottomTrailing) {
                        Text(item.description)
                            .font(.subheadline)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))

                        Button { showDescriptionPreview = true } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(10)
                        }
                    }
                    .sheet(isPresented: $showDescriptionPreview) {
                        DescriptionPreviewSheet(text: item.description)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }

                    // Images section
                    Text("Images")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(item.imageURLs, id: \.self) { url in
                        ImageRowView(
                            urlString: url,
                            fileName: fileName(from: url),
                            onPreview: {
                                selectedImageURL = url
                                withAnimation(.easeInOut) { showImagePreview = true }
                            },
                            onDownload: {
                                ImageDownloader.downloadAndSaveImage(from: url)
                            }
                        )
                    }

                    // Location section
                    Text("Location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Divider()

                    Text("Building No")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    boxedField(text: item.buildingName)

                    Text("Room No")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    boxedField(text: item.roomName)

                    // Actions section
                    HStack(spacing: 16) {
                        Button {
                            switch actionTitle {
                            case "Schedule": activeSheet = .schedule
                            case "Start": showStartConfirm = true
                            case "Completed": showCompleteConfirm = true
                            default: break
                            }
                        } label: {
                            Text(actionTitle)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    vm.status == .completed
                                    ? Color.gray.opacity(0.4)
                                    : Color(red: 87/255, green: 104/255, blue: 125/255)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(vm.status == .completed)

                        Button {
                            activeSheet = .sendBack
                        } label: {
                            Text("Send Back")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 87/255, green: 104/255, blue: 125/255))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }

            // Full screen image overlay when preview is active
            if showImagePreview,
               let urlString = selectedImageURL,
               let url = URL(string: urlString) {
                imageOverlay(url: url)
                    .zIndex(10)
                    .transition(.opacity)
            }
        }
        // Initial load when the view appears
        .task {
            await vm.load()
            estimatedFrom = vm.estimatedFrom
            estimatedTo = vm.estimatedTo
        }
        // Periodic refresh and automatic status update
        .onReceive(timer) { _ in
            Task {
                await vm.load()
                await vm.autoUpdateStatusIfNeeded()
            }
        }
        .animation(.easeInOut, value: showImagePreview)
        .navigationTitle(item.requestNo)
        .navigationBarTitleDisplayMode(.inline)
        // Sheets for scheduling and send back flows
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .schedule:
                ScheduleView { from, to in
                    Task {
                        await vm.schedule(from: from, to: to)
                        estimatedFrom = vm.estimatedFrom
                        estimatedTo = vm.estimatedTo
                        activeSheet = .scheduleSuccess
                    }
                }
            case .scheduleSuccess:
                VStack(spacing: 16) {
                    Text("Data saved successfully")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)

            case .sendBack:
                SendBackView(vm: vm) {
                    activeSheet = .sendBackSuccess
                }

            case .sendBackSuccess:
                SendBackSuccessView()
            }
        }
        // Confirmation alert for starting work
        .alert("Confirmation", isPresented: $showStartConfirm) {
            Button("Yes") {
                showStartConfirm = false
                Task {
                    await vm.startWork()
                    await vm.load()
                    estimatedFrom = vm.estimatedFrom
                    estimatedTo = vm.estimatedTo
                }
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("Are you sure you want to start the request?")
        }
        // Confirmation alert for completing work
        .alert("Confirmation", isPresented: $showCompleteConfirm) {
            Button("Yes") {
                showCompleteConfirm = false
                Task {
                    await vm.completeWork()
                    await vm.load()
                    estimatedFrom = vm.estimatedFrom
                    estimatedTo = vm.estimatedTo
                }
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("Are you sure you want to mark this request as completed?")
        }
    }

    // Displays a modal overlay with the selected image
    private func imageOverlay(url: URL) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showImagePreview = false
                    selectedImageURL = nil
                }

            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320, maxHeight: 420)
                    .background(Color.white)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture { }
            } placeholder: {
                ProgressView()
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
    }
}

private extension RequestDetailView {

    // Creates a small chip style date label
    func dateChip(date: Date) -> some View {
        Text(date.formatted(date: .numeric, time: .omitted))
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .cornerRadius(6)
    }

    // Creates a bordered text box for single line values
    func boxedField(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }

    // Extracts a readable file name from a URL string
    func fileName(from url: String) -> String {
        URL(string: url)?.lastPathComponent.isEmpty == false
        ? (URL(string: url)!.lastPathComponent)
        : "Example.png"
    }
}

// Sheet that shows the full description text with a Done button
struct DescriptionPreviewSheet: View {
    let text: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Description")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
