//
//  CalendarViewController.swift
//  CRMS
//
//Created by Maryam Abdulla
//fetches and displays requests assigned to the logged-in servicer
//
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
    ///container view for FSCalendar instance
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
        //Configure UI Components
        setupCalendar()
        setupCalendarHeader()
        setupSelectedDateLabel()
        setupTableView()
        updateMonthLabel()
        
        //enable dynamic row heights for request cards
        tasksTableView.rowHeight = UITableView.automaticDimension
        tasksTableView.estimatedRowHeight = 140
    }

    // MARK: - Calendar setup
    ///configure and embeds FSCalendar inside its container view
    private func setupCalendar() {
        fsCalendar.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(fsCalendar)
        //Pin calendar to container edges
        NSLayoutConstraint.activate([
            fsCalendar.topAnchor.constraint(equalTo: calendarView.topAnchor),
            fsCalendar.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor),
            fsCalendar.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            fsCalendar.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor)
        ])
        //Assign delegates
        fsCalendar.delegate = self
        fsCalendar.dataSource = self
        fsCalendar.scope = .month
        fsCalendar.scrollDirection = .horizontal
        fsCalendar.appearance.headerDateFormat = ""
        fsCalendar.headerHeight = 0
        
        //Hide default header
        let textColor = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)
        fsCalendar.appearance.weekdayTextColor = textColor
        fsCalendar.appearance.titleDefaultColor = textColor
        fsCalendar.appearance.titleTodayColor = textColor
        fsCalendar.appearance.todayColor = .clear
        fsCalendar.appearance.selectionColor = .systemGray4
        fsCalendar.appearance.titleSelectionColor = textColor
    }

    // MARK: - Header
    ///Configure month label and navigation buttons
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
    
    //Navigate to perivous month
    @objc private func previousMonth() {
        let prev = Calendar.current.date(byAdding: .month, value: -1, to: fsCalendar.currentPage)!
        fsCalendar.setCurrentPage(prev, animated: true)
        updateMonthLabel()
    }

    //Navigate to next month
    @objc private func nextMonth() {
        let next = Calendar.current.date(byAdding: .month, value: 1, to: fsCalendar.currentPage)!
        fsCalendar.setCurrentPage(next, animated: true)
        updateMonthLabel()
    }
    
    
    //update month label when calendar page changes
    private func updateMonthLabel() {
        monthLabel.text = monthFormatter.string(from: fsCalendar.currentPage)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
    }

    // MARK: - Selected date pill
    ///Configure the pill-style selected date label
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
    ///Configure table view appearance and registers custom cell
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
    ///Trigged when a calendar date is selected
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        selectedDateLabel.text = dateFormatter.string(from: date)
        fetchRequests(for: date)
    }
    //MARK: - Data fetching Logic
    ///request assigned to the logged-in servicer are shown (not fully implemented)
    private func fetchRequests(for selectedDate: Date) {
        Task {
            do {
                guard await hasInternetConnection() else {
                    throw NetworkError.noInternet
                }

                let userId = try SessionManager.shared.requireUserId()
                let allModels = try await RequestController.shared.getAllRequestsForDisplay()
                let calendar = Calendar.current

                let filtered = allModels.filter { model in

                    guard model.request.servicerRef == userId else {
                        return false
                    }

                    let displayDate =
                        model.request.estimatedStartDate ??
                        model.request.actualStartDate ??
                        model.request.modifiedOn ??
                        model.request.createdOn

                    return calendar.isDate(displayDate, inSameDayAs: selectedDate)
                }

                await MainActor.run {
                    self.displayModels = filtered
                    self.tasksTableView.reloadData()
                }

            } catch {
                print("Calendar fetch error:", error)
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
