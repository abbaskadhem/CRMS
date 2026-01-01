import UIKit
import FSCalendar
import FirebaseFirestore
import FirebaseAuth


class CalendarViewController: UIViewController,
                              FSCalendarDelegate,
                              FSCalendarDataSource,
                              UITableViewDelegate,
                              UITableViewDataSource {
    
  

    // MARK: - Outlets
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!

    // MARK: - FSCalendar
    private let fsCalendar = FSCalendar()

    private let selectedDateContainer = UIView()
    // MARK: - Header controls
    private let monthLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let headerStack = UIStackView()

    // MARK: - Data
    private var requests: [Request] = []
    //private let db = Firestore.firestore()

    private func loadDummyRequests(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        // Only show cards if selected date is 30 Dec 2025
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let testDate = formatter.date(from: "2025-12-30")!

        guard calendar.isDate(startOfDay, inSameDayAs: testDate) else {
            requests = []
            requests.append(contentsOf: requests)
            tasksTableView.reloadData()
            return
        }

        requests = [
            Request(
                id: UUID(),
                requestNo: "REQ-00030",
                requesterRef: UUID(),
                requestCategoryRef: UUID(),
                requestSubcategoryRef: UUID(),
                buildingRef: UUID(),
                roomRef: UUID(),
                description: "Air conditioner leaking water",
                images: nil,
                priority: .high,
                status: .inProgress,
                servicerRef: UUID(),
                estimatedStartDate: nil,
                estimatedEndDate: nil,
                actualStartDate: nil,
                actualEndDate: nil,
                ownerId: UUID(),
                createdOn: testDate,
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false
            ),

            Request(
                id: UUID(),
                requestNo: "REQ-00031",
                requesterRef: UUID(),
                requestCategoryRef: UUID(),
                requestSubcategoryRef: UUID(),
                buildingRef: UUID(),
                roomRef: UUID(),
                description: "Projector not powering on",
                images: nil,
                priority: .moderate,
                status: .completed,
                servicerRef: UUID(),
                estimatedStartDate: nil,
                estimatedEndDate: nil,
                actualStartDate: nil,
                actualEndDate: nil,
                ownerId: UUID(),
                createdOn: testDate,
                createdBy: UUID(),
                modifiedOn: nil,
                modifiedBy: nil,
                inactive: false
            )
        ]

        tasksTableView.reloadData()
    }
    // MARK: - Formatters
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d/MM/yyyy"
        return df
    }()

    private let monthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCalendar()
        setupCalendarHeader()
        setupSelectedDateLabel()
        setupTableView()
        updateMonthLabel()
        tasksTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
    }

    // MARK: - Calendar Setup (UIView + FSCalendar)
    private func setupCalendar() {

        fsCalendar.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(fsCalendar)

        NSLayoutConstraint.activate([
            fsCalendar.topAnchor.constraint(equalTo: calendarView.topAnchor),
            fsCalendar.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor),
            fsCalendar.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            fsCalendar.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor)
        ])

        fsCalendar.delegate = self
        fsCalendar.dataSource = self

        fsCalendar.scope = .month
        fsCalendar.scrollDirection = .horizontal
        fsCalendar.scrollEnabled = true
        fsCalendar.swipeToChooseGesture.isEnabled = true
        
        calendarView.backgroundColor = .clear
        fsCalendar.backgroundColor = .clear
        fsCalendar.calendarWeekdayView.backgroundColor = .clear
        fsCalendar.calendarHeaderView.backgroundColor = .clear
        fsCalendar.appearance.headerDateFormat = ""

        fsCalendar.appearance.weekdayTextColor =
            UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)

        fsCalendar.appearance.titleDefaultColor =
            UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)

        fsCalendar.appearance.todayColor = .clear
        fsCalendar.appearance.titleTodayColor =
            fsCalendar.appearance.titleDefaultColor

        fsCalendar.appearance.selectionColor = .systemGray4
        fsCalendar.appearance.titleSelectionColor =
            UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)
        
        fsCalendar.headerHeight = 0
        fsCalendar.weekdayHeight = 30
    }

    // MARK: - Calendar Header
    private func setupCalendarHeader() {

        monthLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        monthLabel.textColor =
            UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)

        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        prevButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)

        let headerColor = UIColor(
            red: 83/255,
            green: 105/255,
            blue: 127/255,
            alpha: 1
        )
        monthLabel.tintColor = headerColor
        prevButton.tintColor = headerColor
        nextButton.tintColor = headerColor
        
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing

        headerStack.addArrangedSubview(prevButton)
        headerStack.addArrangedSubview(monthLabel)
        headerStack.addArrangedSubview(nextButton)

        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.bottomAnchor.constraint(equalTo: calendarView.topAnchor, constant: -8),
            headerStack.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 8),
            headerStack.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -8),
            headerStack.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func previousMonth() {
        let prev = Calendar.current.date(byAdding: .month, value: -1, to: fsCalendar.currentPage)!
        fsCalendar.setCurrentPage(prev, animated: true)
        updateMonthLabel()
    }

    @objc private func nextMonth() {
        let next = Calendar.current.date(byAdding: .month, value: 1, to: fsCalendar.currentPage)!
        fsCalendar.setCurrentPage(next, animated: true)
        updateMonthLabel()
    }

    private func updateMonthLabel() {
        monthLabel.text = monthFormatter.string(from: fsCalendar.currentPage)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
    }

    // MARK: - Selected Date Label
    private func setupSelectedDateLabel() {

        // Container (pill)
        selectedDateContainer.backgroundColor = UIColor(
            red: 138/255,
            green: 167/255,
            blue: 188/255,
            alpha: 1
        )
        selectedDateContainer.layer.cornerRadius = 14
        selectedDateContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(selectedDateContainer)

        // Label
        selectedDateLabel.text = "Select a date"
        selectedDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        selectedDateLabel.textColor = .white
        selectedDateLabel.textAlignment = .left
        selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false

        selectedDateContainer.addSubview(selectedDateLabel)

        // Constraints (pill size + left padding)
        NSLayoutConstraint.activate([
            selectedDateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedDateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedDateContainer.topAnchor.constraint(equalTo: tasksTableView.topAnchor, constant: -44),
            selectedDateContainer.heightAnchor.constraint(equalToConstant: 32),

            selectedDateLabel.leadingAnchor.constraint(equalTo: selectedDateContainer.leadingAnchor, constant: 12),
            selectedDateLabel.trailingAnchor.constraint(equalTo: selectedDateContainer.trailingAnchor, constant: -12),
            selectedDateLabel.centerYAnchor.constraint(equalTo: selectedDateContainer.centerYAnchor)
        ])
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.separatorStyle = .none
        tasksTableView.backgroundColor = .clear
        tasksTableView.isScrollEnabled = true
        tasksTableView.alwaysBounceVertical = true

        tasksTableView.register(
            TaskCardCell.self,
            forCellReuseIdentifier: TaskCardCell.identifier
        )
    }

    // MARK: - Calendar Selection
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {

        selectedDateLabel.text = dateFormatter.string(from: date)
        loadDummyRequests(for: date)
        //fetchRequests(for: date)
    }
    //db
    /**private func fetchRequests(for date: Date) {
a
        Task {
            guard await hasInternetConnection() else {
                print("No internet connection")
                return
            }

            guard let currentUserId = getCurrentUserId() else {
                print("No logged-in user")
                return
            }

            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            do {
                let snapshot = try await db.collection("requests")
                    .whereField("servicerRef", isEqualTo: currentUserId)
                    .whereField("createdOn", isGreaterThanOrEqualTo: startOfDay)
                    .whereField("createdOn", isLessThan: endOfDay)
                    .getDocuments()

                self.requests = snapshot.documents.compactMap {
                    try? $0.data(as: Request.self)
                }

                print("Fetched requests:", self.requests.count)

                DispatchQueue.main.async {
                    self.tasksTableView.reloadData()
                }

            } catch {
                print("Server unavailable:", error.localizedDescription)
            }
        }
    }
**/
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskCardCell.identifier,
            for: indexPath
        ) as! TaskCardCell

        cell.configure(with: requests[indexPath.row])
        return cell
    }
}
