//
//  RequestsViewController.swift
//  CRMS
//
//  Requests tab view controller
//

import UIKit

class RequestsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var addButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddButton()
    }

    // MARK: - Setup

    private func setupAddButton() {
        addButton.tintColor = .white
        addButton.clipsToBounds = true
    }

    // MARK: - IBActions

    @IBAction func addButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Requests", bundle: nil)
        let submitVC = storyboard.instantiateViewController(withIdentifier: "SubmitRequestViewController")

        submitVC.modalPresentationStyle = .fullScreen
        present(submitVC, animated: true)
    }
}
