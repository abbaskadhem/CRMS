//
//  NotificationFilterViewController.swift
//  CRMS
//
//  Created by Reem Janahi on 03/01/2026.
//

import Foundation
import UIKit

final class NotificationFilterViewController: UIViewController {

    var onApply: ((_ from: Date?, _ to: Date?) -> Void)?
    var onClear: (() -> Void)?

    private let fromPicker = UIDatePicker()
    private let toPicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Filter"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center

        // MARK: Date Pickers
        fromPicker.datePickerMode = .date
        toPicker.datePickerMode = .date

        let today = Date()
        fromPicker.maximumDate = today
        toPicker.maximumDate = today

        fromPicker.addTarget(self, action: #selector(fromDateChanged), for: .valueChanged)

        let fromLabel = UILabel()
        fromLabel.text = "From"

        let toLabel = UILabel()
        toLabel.text = "To"
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear Filter", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16)
        clearButton.backgroundColor = AppColors.primary
        clearButton.tintColor = .white
        clearButton.layer.cornerRadius = 12
        clearButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Filter", for: .normal)
        applyButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        applyButton.backgroundColor = AppColors.primary
        applyButton.tintColor = .white
        applyButton.layer.cornerRadius = 12
        applyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            fromLabel,
            fromPicker,
            toLabel,
            toPicker,
            applyButton,
            clearButton
        ])


        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
    }
    
    @objc private func fromDateChanged() {
        toPicker.minimumDate = fromPicker.date

        if toPicker.date < fromPicker.date {
            toPicker.date = fromPicker.date
        }
    }

    @objc private func applyTapped() {
        onApply?(fromPicker.date, toPicker.date)
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        onClear?()
        dismiss(animated: true)
    }

}
