//
//  SubmitRequestViewController.swift
//  CRMS
//
//  Submit Request form for Requesters
//

import UIKit

final class SubmitRequestViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mainCategoryButton: UIButton!
    @IBOutlet weak var subCategoryButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var selectImagesButton: UIButton!
    @IBOutlet weak var imagesStackView: UIStackView!  // Stack view for image action buttons
    @IBOutlet weak var buildingButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // Image action buttons (created programmatically if not in storyboard)
    private var previewButton: UIButton!
    private var deleteButton: UIButton!

    // MARK: - Data
    private var mainCategories: [RequestCategory] = []
    private var subCategories: [RequestCategory] = []
    private var buildings: [Building] = []
    private var rooms: [Room] = []
    private var selectedImages: [UIImage] = []

    private var selectedMainCategory: RequestCategory?
    private var selectedSubCategory: RequestCategory?
    private var selectedBuilding: Building?
    private var selectedRoom: Room?

    private let placeholderText = "Please describe the problem as detailed as you can..."

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchInitialData()
    }

    // MARK: - Setup

    private func setupUI() {
        // Set background color
        view.backgroundColor = AppColors.background

        // Setup text view delegate for placeholder
        descriptionTextView.delegate = self

        // Style all dropdown buttons
        styleDropdownButton(mainCategoryButton)
        styleDropdownButton(subCategoryButton)
        styleDropdownButton(buildingButton)
        styleDropdownButton(roomButton)

        // Style description text view
        styleTextView(descriptionTextView)

        // Style select images button (outlined style)
        styleOutlinedButton(selectImagesButton)

        // Setup image action buttons
        setupImageActionButtons()

        // Style submit button (filled style)
        styleFilledButton(submitButton)

        // Initially disable dependent dropdowns
        subCategoryButton.isEnabled = false
        subCategoryButton.alpha = 0.5
        roomButton.isEnabled = false
        roomButton.alpha = 0.5

        // Hide activity indicator
        activityIndicator.hidesWhenStopped = true

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Styling Methods

    private func styleDropdownButton(_ button: UIButton) {
        button.backgroundColor = AppColors.inputBackground
        button.setTitleColor(AppColors.placeholder, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.inputBorder.cgColor

        // Add dropdown arrow
        if let chevronImage = UIImage(systemName: "chevron.down") {
            button.setImage(chevronImage.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = AppColors.placeholder
            button.semanticContentAttribute = .forceRightToLeft
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
    }

    private func styleTextView(_ textView: UITextView) {
        textView.backgroundColor = AppColors.inputBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = AppColors.inputBorder.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = placeholderText
        textView.textColor = AppColors.placeholder
    }

    private func styleOutlinedButton(_ button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(AppColors.text, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.inputBorder.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }

    private func styleFilledButton(_ button: UIButton) {
        button.backgroundColor = AppColors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    private func setupImageActionButtons() {
        // Create preview button
        previewButton = UIButton(type: .system)
        previewButton.setImage(UIImage(systemName: "eye"), for: .normal)
        previewButton.tintColor = AppColors.text
        previewButton.addTarget(self, action: #selector(previewImagesTapped), for: .touchUpInside)
        previewButton.isHidden = true

        // Create delete button
        deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = AppColors.error
        deleteButton.addTarget(self, action: #selector(deleteImagesTapped), for: .touchUpInside)
        deleteButton.isHidden = true

        // Add buttons next to select images button
        if let stackView = imagesStackView {
            stackView.addArrangedSubview(previewButton)
            stackView.addArrangedSubview(deleteButton)
        } else {
            // If no stack view in storyboard, add buttons programmatically next to selectImagesButton
            let stackView = UIStackView(arrangedSubviews: [previewButton, deleteButton])
            stackView.axis = .horizontal
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false

            if let superview = selectImagesButton.superview {
                superview.addSubview(stackView)
                NSLayoutConstraint.activate([
                    stackView.centerYAnchor.constraint(equalTo: selectImagesButton.centerYAnchor),
                    stackView.leadingAnchor.constraint(equalTo: selectImagesButton.trailingAnchor, constant: 16)
                ])
            }
        }
    }

    private func updateImageButtons() {
        let hasImages = !selectedImages.isEmpty
        previewButton.isHidden = !hasImages
        deleteButton.isHidden = !hasImages

        if hasImages {
            selectImagesButton.setTitle("Selected: \(selectedImages.count)", for: .normal)
        } else {
            selectImagesButton.setTitle("Select Images", for: .normal)
        }
    }

    @objc private func previewImagesTapped() {
        guard !selectedImages.isEmpty else { return }

        // Show image preview in action sheet or image viewer
        let alert = UIAlertController(title: "Selected Images", message: "\(selectedImages.count) image(s) selected", preferredStyle: .actionSheet)

        for (index, _) in selectedImages.enumerated() {
            alert.addAction(UIAlertAction(title: "View Image \(index + 1)", style: .default) { [weak self] _ in
                self?.showImagePreview(at: index)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = previewButton
            popover.sourceRect = previewButton.bounds
        }

        present(alert, animated: true)
    }

    private func showImagePreview(at index: Int) {
        guard index < selectedImages.count else { return }

        let imageVC = UIViewController()
        imageVC.view.backgroundColor = .black

        let imageView = UIImageView(image: selectedImages[index])
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageVC.view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageVC.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageVC.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageVC.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageVC.view.trailingAnchor)
        ])

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(imageVC, action: #selector(UIViewController.dismissSelf), for: .touchUpInside)
        imageVC.view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: imageVC.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: imageVC.view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        imageVC.modalPresentationStyle = .fullScreen
        present(imageVC, animated: true)
    }

    @objc private func deleteImagesTapped() {
        guard !selectedImages.isEmpty else { return }

        let alert = UIAlertController(
            title: "Delete Images",
            message: "Are you sure you want to remove all \(selectedImages.count) selected image(s)?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
            self?.selectedImages.removeAll()
            self?.updateImageButtons()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    // MARK: - Data Fetching

    private func fetchInitialData() {
        Task {
            do {
                async let categoriesTask = CategoryController.shared.getParentCategories()
                async let buildingsTask = LocationController.shared.getActiveBuildings()

                let (categories, fetchedBuildings) = try await (categoriesTask, buildingsTask)

                await MainActor.run {
                    self.mainCategories = categories
                    self.buildings = fetchedBuildings
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - IBActions

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func mainCategoryTapped(_ sender: Any) {
        showSelectionSheet(title: "Select Main Category", items: mainCategories.map { $0.name }) { [weak self] index in
            guard let self = self else { return }
            self.selectedMainCategory = self.mainCategories[index]
            self.mainCategoryButton.setTitle(self.mainCategories[index].name, for: .normal)
            self.mainCategoryButton.setTitleColor(AppColors.text, for: .normal)

            // Reset sub category
            self.selectedSubCategory = nil
            self.subCategoryButton.setTitle("Select Sub-Category", for: .normal)
            self.subCategoryButton.setTitleColor(AppColors.placeholder, for: .normal)

            // Fetch subcategories
            self.fetchSubcategories(for: self.mainCategories[index].id)
        }
    }

    private func fetchSubcategories(for parentId: UUID) {
        Task {
            do {
                let subcats = try await CategoryController.shared.getSubcategories(forParentId: parentId)
                await MainActor.run {
                    self.subCategories = subcats
                    self.subCategoryButton.isEnabled = true
                    self.subCategoryButton.alpha = 1.0
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func subCategoryTapped(_ sender: Any) {
        showSelectionSheet(title: "Select Sub-Category", items: subCategories.map { $0.name }) { [weak self] index in
            guard let self = self else { return }
            self.selectedSubCategory = self.subCategories[index]
            self.subCategoryButton.setTitle(self.subCategories[index].name, for: .normal)
            self.subCategoryButton.setTitleColor(AppColors.text, for: .normal)
        }
    }

    @IBAction func selectImagesTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }

    @IBAction func buildingTapped(_ sender: Any) {
        showSelectionSheet(title: "Select Building", items: buildings.map { $0.buildingNo }) { [weak self] index in
            guard let self = self else { return }
            self.selectedBuilding = self.buildings[index]
            self.buildingButton.setTitle(self.buildings[index].buildingNo, for: .normal)
            self.buildingButton.setTitleColor(AppColors.text, for: .normal)

            // Reset room
            self.selectedRoom = nil
            self.roomButton.setTitle("Select Room", for: .normal)
            self.roomButton.setTitleColor(AppColors.placeholder, for: .normal)

            // Fetch rooms
            self.fetchRooms(for: self.buildings[index].id)
        }
    }

    private func fetchRooms(for buildingId: UUID) {
        Task {
            do {
                let fetchedRooms = try await LocationController.shared.getActiveRooms(forBuildingId: buildingId)
                await MainActor.run {
                    self.rooms = fetchedRooms
                    self.roomButton.isEnabled = true
                    self.roomButton.alpha = 1.0
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func roomTapped(_ sender: Any) {
        showSelectionSheet(title: "Select Room", items: rooms.map { $0.roomNo }) { [weak self] index in
            guard let self = self else { return }
            self.selectedRoom = self.rooms[index]
            self.roomButton.setTitle(self.rooms[index].roomNo, for: .normal)
            self.roomButton.setTitleColor(AppColors.text, for: .normal)
        }
    }

    @IBAction func submitTapped(_ sender: Any) {
        // Validate required fields
        guard let mainCategory = selectedMainCategory else {
            showAlert(title: "Required Field", message: "Please select a Main Category.")
            return
        }

        guard let subCategory = selectedSubCategory else {
            showAlert(title: "Required Field", message: "Please select a Sub-Category.")
            return
        }

        let description = descriptionTextView.text ?? ""
        if description.isEmpty || description == placeholderText {
            showAlert(title: "Required Field", message: "Please enter a description of the problem.")
            return
        }

        guard let building = selectedBuilding else {
            showAlert(title: "Required Field", message: "Please select a Building.")
            return
        }

        guard let room = selectedRoom else {
            showAlert(title: "Required Field", message: "Please select a Room.")
            return
        }

        // Show loading
        activityIndicator.startAnimating()
        submitButton.isEnabled = false

        Task {
            do {
                // Upload images first if any using RequestController
                var imageURLs: [String] = []
                if !selectedImages.isEmpty {
                    imageURLs = try await RequestController.shared.uploadImages(selectedImages)
                }

                // Submit request using shared RequestController
                try await RequestController.shared.submitRequest(
                    requestCategoryRef: mainCategory.id,
                    requestSubcategoryRef: subCategory.id,
                    buildingRef: building.id,
                    roomRef: room.id,
                    description: description,
                    images: imageURLs
                )

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Your request has been submitted successfully.") { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.submitButton.isEnabled = true
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helper Methods

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Alerts

    private func showSelectionSheet(title: String, items: [String], completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        for (index, item) in items.enumerated() {
            alert.addAction(UIAlertAction(title: item, style: .default) { _ in
                completion(index)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension SubmitRequestViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = AppColors.text
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = AppColors.placeholder
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SubmitRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            selectedImages.append(image)
            updateImageButtons()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
}
