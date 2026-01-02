//
//  AdminRequestsViewController.swift
//  CRMS
//
//  Admin view for managing all requests
//

import UIKit

final class AdminRequestsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    private var allRequests: [RequestDisplayModel] = []
    private var filteredRequests: [RequestDisplayModel] = []
    private var isSearching = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRequests()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppColors.background

        // Setup search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 18
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.layer.borderWidth = 1
        searchBar.searchTextField.layer.borderColor = AppColors.inputBorder.cgColor

        // Setup filter button
        filterButton.tintColor = AppColors.text

        // Setup activity indicator
        activityIndicator.hidesWhenStopped = true
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.contentInset = AppSpacing.contentInsets

        // Enable automatic cell sizing for dynamic content
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160

        // Register custom cell
        tableView.register(RequestCardCell.self, forCellReuseIdentifier: RequestCardCell.identifier)
    }

    // MARK: - Data Fetching

    private func fetchRequests() {
        activityIndicator.startAnimating()

        Task {
            do {
                let requests = try await RequestController.shared.getAllRequestsForDisplay()
                await MainActor.run {
                    self.allRequests = requests
                    self.filteredRequests = requests
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                // Print full error to console (includes Firestore index creation link)
                print("🔴 Firestore Error: \(error)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func filterButtonTapped(_ sender: Any) {
        showFilterOptions()
    }

    private func showFilterOptions() {
        let alert = UIAlertController(title: "Filter by Status", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "All", style: .default) { [weak self] _ in
            self?.filterByStatus(nil)
        })

        alert.addAction(UIAlertAction(title: "Submitted", style: .default) { [weak self] _ in
            self?.filterByStatus(.submitted)
        })

        alert.addAction(UIAlertAction(title: "Assigned", style: .default) { [weak self] _ in
            self?.filterByStatus(.assigned)
        })

        alert.addAction(UIAlertAction(title: "In Progress", style: .default) { [weak self] _ in
            self?.filterByStatus(.inProgress)
        })

        alert.addAction(UIAlertAction(title: "On-Hold", style: .default) { [weak self] _ in
            self?.filterByStatus(.onHold)
        })

        alert.addAction(UIAlertAction(title: "Completed", style: .default) { [weak self] _ in
            self?.filterByStatus(.completed)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = filterButton
            popover.sourceRect = filterButton.bounds
        }

        present(alert, animated: true)
    }

    private func filterByStatus(_ status: Status?) {
        if let status = status {
            filteredRequests = allRequests.filter { $0.status == status }
        } else {
            filteredRequests = allRequests
        }
        tableView.reloadData()
    }

    private func filterRequests(with searchText: String) {
        if searchText.isEmpty {
            filteredRequests = allRequests
            isSearching = false
        } else {
            isSearching = true
            filteredRequests = allRequests.filter { request in
                request.requestNo.lowercased().contains(searchText.lowercased()) ||
                request.categoryString.lowercased().contains(searchText.lowercased()) ||
                request.locationString.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension AdminRequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RequestCardCell.identifier, for: indexPath) as? RequestCardCell else {
            return UITableViewCell()
        }

        let request = filteredRequests[indexPath.row]
        cell.configure(with: request)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let request = filteredRequests[indexPath.row]

        let storyboard = UIStoryboard(name: "AdminRequests", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailViewController") as? RequestDetailViewController {
            detailVC.requestId = request.request.id
            detailVC.modalPresentationStyle = .fullScreen
            present(detailVC, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate

extension AdminRequestsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterRequests(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterRequests(with: "")
        searchBar.resignFirstResponder()
    }
}
