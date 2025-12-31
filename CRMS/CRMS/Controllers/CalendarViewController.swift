//
//  CalendarViewController.swift
//  CRMS
//
//  Created by Maryam Abdulla
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController,
                              FSCalendarDelegate,
                              FSCalendarDataSource,
                              UITableViewDelegate,
                              UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!

    // MARK: - Properties

    private var calendar: FSCalendar!
    private var tasksForSelectedDate: [String] = []

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()

    private let primaryColor = UIColor(hex: "#53697F")
    private let dateLabelColor = UIColor(hex: "#8AA7BC")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSelectedDateLabel()
        setupCalendar()
        setupTableView()
    }

    // MARK: - Selected Date Label

    private func setupSelectedDateLabel() {
        selectedDateLabel.text = "Select a date"
        selectedDateLabel.textAlignment = .left
        selectedDateLabel.textColor = .white
        selectedDateLabel.backgroundColor = dateLabelColor
        selectedDateLabel.layer.cornerRadius = 10
        selectedDateLabel.clipsToBounds = true

        // Make it compact like a button
        selectedDateLabel.setContentHuggingPriority(.required, for: .horizontal)
        selectedDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        selectedDateLabel.textInsets(top: 6, left: 12, bottom: 6, right: 12)
    }

    // MARK: - Calendar Setup

    private func setupCalendar() {
        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false

        calendar.delegate = self
        calendar.dataSource = self

        // Interaction
        calendar.scope = .month
        calendar.scrollDirection = .horizontal
        calendar.scrollEnabled = true
        calendar.pagingEnabled = true

        // Appearance
        calendar.backgroundColor = .clear

        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleColor = primaryColor
        calendar.appearance.weekdayTextColor = primaryColor
        calendar.appearance.titleDefaultColor = primaryColor
        calendar.appearance.titleSelectionColor = primaryColor

        // Restore default TODAY look
        calendar.appearance.todayColor = UIColor.systemGray5
        calendar.appearance.todaySelectionColor = UIColor.systemGray4

        // Selected date highlight (rounded)
        calendar.appearance.selectionColor = UIColor.systemGray4

        calendar.appearance.titleFont = .systemFont(ofSize: 15, weight: .medium)
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 18, weight: .semibold)

        calendarContainerView.addSubview(calendar)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendar.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor),
            calendar.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor)
        ])
    }

    // MARK: - TableView Setup

    private func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.separatorStyle = .none
        tasksTableView.backgroundColor = .clear
        tasksTableView.rowHeight = 60
    }

    // MARK: - FSCalendar Delegate

    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {

        selectedDateLabel.text = dateFormatter.string(from: date)

        // Temporary mock tasks (Firebase later)
        tasksForSelectedDate = [
            "Fix AC in Room 204",
            "Check projector",
            "Replace light bulb"
        ]

        tasksTableView.reloadData()
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tasksForSelectedDate.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TaskCell",
            for: indexPath
        )

        cell.textLabel?.text = tasksForSelectedDate[indexPath.row]
        cell.textLabel?.textColor = .label
        cell.backgroundColor = UIColor(named: "primcolorsec")
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true
        cell.selectionStyle = .none

        return cell
    }
}

// MARK: - UILabel Padding Helper

extension UILabel {
    func textInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        let inset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        //let label = PaddingLabel()
        //label.insets = inset
    }
}

// MARK: - UIColor HEX Helper

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
