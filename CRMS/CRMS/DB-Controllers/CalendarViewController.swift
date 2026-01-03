import UIKit
import FSCalendar

final class CalendarViewController: UIViewController,
                                    FSCalendarDelegate,
                                    FSCalendarDataSource,
                                    UITableViewDelegate,
                                    UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!

    // MARK: - Calendar
    private let fsCalendar = FSCalendar()

    // MARK: - Calendar Header
    private let monthLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let headerStack = UIStackView()

    // MARK: - Selected date pill
    private let selectedDateContainer = UIView()

    // MARK: - Data
    private var displayModels: [RequestDisplayModel] = []

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
    }

    // MARK: - Calendar setup
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
        fsCalendar.appearance.headerDateFormat = ""
        fsCalendar.headerHeight = 0

        let textColor = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)
        fsCalendar.appearance.weekdayTextColor = textColor
        fsCalendar.appearance.titleDefaultColor = textColor
        fsCalendar.appearance.titleTodayColor = textColor
        fsCalendar.appearance.todayColor = .clear
        fsCalendar.appearance.selectionColor = .systemGray4
        fsCalendar.appearance.titleSelectionColor = textColor
    }

    // MARK: - Header
    private func setupCalendarHeader() {
        let color = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)

        monthLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        monthLabel.textColor = color

        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        prevButton.tintColor = color
        nextButton.tintColor = color

        prevButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)

        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center
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

    // MARK: - Selected date pill
    private func setupSelectedDateLabel() {
        selectedDateContainer.backgroundColor =
            UIColor(red: 138/255, green: 167/255, blue: 188/255, alpha: 1)
        selectedDateContainer.layer.cornerRadius = 14
        selectedDateContainer.translatesAutoresizingMaskIntoConstraints = false

        selectedDateLabel.text = "Select a date"
        selectedDateLabel.textColor = .white
        selectedDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(selectedDateContainer)
        selectedDateContainer.addSubview(selectedDateLabel)

        NSLayoutConstraint.activate([
            selectedDateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedDateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedDateContainer.topAnchor.constraint(equalTo: tasksTableView.topAnchor, constant: -44),
            selectedDateContainer.heightAnchor.constraint(equalToConstant: 32),
            selectedDateLabel.leadingAnchor.constraint(equalTo: selectedDateContainer.leadingAnchor, constant: 12),
            selectedDateLabel.centerYAnchor.constraint(equalTo: selectedDateContainer.centerYAnchor)
        ])
    }

    // MARK: - TableView
    private func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.separatorStyle = .none
        tasksTableView.backgroundColor = .clear

        tasksTableView.register(
            RequestCardCell.self,
            forCellReuseIdentifier: RequestCardCell.identifier
        )
    }

    // MARK: - Calendar selection
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        selectedDateLabel.text = dateFormatter.string(from: date)
        fetchRequests(for: date)
    }

    // MARK: - Fetch requests (OPTION A)
    private func fetchRequests(for date: Date) {
        Task {
            do {
                guard await hasInternetConnection() else {
                    throw NetworkError.noInternet
                }

                let allModels = try await RequestController.shared
                    .getAllRequestsForDisplay()

                let calendar = Calendar.current
                let filtered = allModels.filter { model in
                    guard let startDate = model.request.estimatedStartDate else {
                        return false
                    }
                    return calendar.isDate(startDate, inSameDayAs: date)
                }

                await MainActor.run {
                    self.displayModels = filtered
                    self.tasksTableView.reloadData()
                }

            } catch {
                print("Calendar fetch error:", error.localizedDescription)
                await MainActor.run {
                    self.displayModels = []
                    self.tasksTableView.reloadData()
                }
            }
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        displayModels.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RequestCardCell.identifier,
            for: indexPath
        ) as! RequestCardCell
        cell.configure(with: displayModels[indexPath.row])
        return cell
    }
}
