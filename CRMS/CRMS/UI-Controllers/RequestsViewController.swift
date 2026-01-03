//
//  RequestsViewController.swift
//  CRMS
//
//  Requests tab view controller for requesters
//

import UIKit

class RequestsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    private var requests: [RequestDisplayModel] = []

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
        addButton.tintColor = .white
        addButton.clipsToBounds = true
        activityIndicator.hidesWhenStopped = true
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        // Only add vertical content insets, no horizontal to prevent horizontal scrolling
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)

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
                // getAllRequestsForDisplay automatically filters by user type
                // For requesters, it returns only their submitted requests
                let userRequests = try await RequestController.shared.getAllRequestsForDisplay()
                await MainActor.run {
                    self.requests = userRequests
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("🔴 Firestore Error: \(error)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - IBActions

    @IBAction func addButtonTapped(_ sender: Any) {
        // Use BaseRequestFormViewController in create mode
        let submitVC = BaseRequestFormViewController(mode: .create)
        submitVC.modalPresentationStyle = .fullScreen
        present(submitVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension RequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RequestCardCell.identifier, for: indexPath) as? RequestCardCell else {
            return UITableViewCell()
        }

        let request = requests[indexPath.row]
        cell.configure(with: request)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let request = requests[indexPath.row]

        // Use BaseRequestFormViewController in view mode
        let detailVC = BaseRequestFormViewController(mode: .view(requestId: request.request.id))
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
    }
}
