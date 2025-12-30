//
//  SubmitRequestViewController.swift
//  CRMS
//
//  Submit Request form for Requesters
//

import UIKit
import FirebaseStorage

final class SubmitRequestViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mainCategoryButton: UIButton!
    @IBOutlet weak var subCategoryButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var selectImagesButton: UIButton!
    @IBOutlet weak var buildingButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Colors
    private let primaryColor = UIColor(red: 15/255, green: 25/255, blue: 42/255, alpha: 1)

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
        // Setup text view delegate for placeholder
        descriptionTextView.delegate = self

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
            self.mainCategoryButton.setTitleColor(self.primaryColor, for: .normal)

            // Reset sub category
            self.selectedSubCategory = nil
            self.subCategoryButton.setTitle("Select Sub-Category", for: .normal)
            self.subCategoryButton.setTitleColor(.lightGray, for: .normal)

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
            self.subCategoryButton.setTitleColor(self.primaryColor, for: .normal)
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
            self.buildingButton.setTitleColor(self.primaryColor, for: .normal)

            // Reset room
            self.selectedRoom = nil
            self.roomButton.setTitle("Select Room", for: .normal)
            self.roomButton.setTitleColor(.lightGray, for: .normal)

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
            self.roomButton.setTitleColor(self.primaryColor, for: .normal)
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
                // Upload images first if any
                var imageURLs: [String] = []
                if !selectedImages.isEmpty {
                    imageURLs = try await uploadImages()
                }

                // Submit request
                let requestController = RequestController()
                try await requestController.submitRequest(
                    requestCategoryRef: mainCategory.id,
                    requestSubcategoryRef: subCategory.id,
                    buildingRef: building.id,
                    roomRef: room.id,
                    description: description,
                    images: imageURLs
                )

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showSuccessAlert()
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

    private func uploadImages() async throws -> [String] {
        var urls: [String] = []
        let storage = Storage.storage()

        for (index, image) in selectedImages.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }

            let imageName = "\(UUID().uuidString)_\(index).jpg"
            let storageRef = storage.reference().child("request_images/\(imageName)")

            _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()
            urls.append(downloadURL.absoluteString)
        }

        return urls
    }

    // MARK: - Alerts

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Your request has been submitted successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

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
            textView.textColor = primaryColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SubmitRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            selectedImages.append(image)
            // Update button to show count
            selectImagesButton.setTitle("Selected: \(selectedImages.count)", for: .normal)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
