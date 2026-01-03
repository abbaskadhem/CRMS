//
//  BaseRequestFormViewController.swift
//  CRMS
//
//  Base view controller for request forms with conditional rendering based on user type and status
//

import UIKit
import FirebaseFirestore

final class BaseRequestFormViewController: UIViewController {

    // MARK: - Mode Enum
    enum Mode {
        case create              // New request creation
        case view(requestId: UUID)   // View existing request (read-only with actions)
        case edit(requestId: UUID)   // Edit existing request (for requesters only when status = submitted)
    }

    // MARK: - Properties
    private var mode: Mode
    private var currentUserType: UserType?
    private var requestModel: RequestDisplayModel?

    // MARK: - UI Components - Navigation Bar
    private let navigationBar = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // MARK: - UI Components - Header (for view/edit modes)
    private let headerContainerView = UIView()
    private let requestNumberLabel = UILabel()
    private let statusContainerView = UIView()
    private let statusDot = UIView()
    private let statusLabel = UILabel()
    private let priorityLabel = UILabel()
    private let technicianLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    // MARK: - UI Components - Form
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Problem Section
    private let problemHeaderLabel = UILabel()
    private let mainCategoryLabel = UILabel()
    private let mainCategoryButton = UIButton(type: .system)
    private let subCategoryLabel = UILabel()
    private let subCategoryButton = UIButton(type: .system)
    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()

    // Images Section
    private let imagesLabel = UILabel()
    private let selectImagesButton = UIButton(type: .system)
    private let imagesStackView = UIStackView()
    private var previewButton: UIButton!
    private var downloadButton: UIButton!
    private var deleteImagesButton: UIButton!

    // Location Section
    private let locationHeaderLabel = UILabel()
    private let buildingLabel = UILabel()
    private let buildingButton = UIButton(type: .system)
    private let roomLabel = UILabel()
    private let roomButton = UIButton(type: .system)

    // Action Buttons
    private let actionButtonsStackView = UIStackView()

    // Activity Indicator
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Data
    private var mainCategories: [RequestCategory] = []
    private var subCategories: [RequestCategory] = []
    private var buildings: [Building] = []
    private var rooms: [Room] = []
    private var selectedImages: [UIImage] = []
    private var existingImageURLs: [String] = []

    private var selectedMainCategory: RequestCategory?
    private var selectedSubCategory: RequestCategory?
    private var selectedBuilding: Building?
    private var selectedRoom: Room?

    private let placeholderText = "Please describe the problem as detailed as you can..."

    // MARK: - Initializer
    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserType()

        switch mode {
        case .create:
            fetchInitialData()
        case .view(let requestId), .edit(let requestId):
            fetchRequestDetails(requestId: requestId)
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = AppColors.background

        // Setup navigation bar
        setupNavigationBar()

        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = AppColors.background
        scrollView.showsVerticalScrollIndicator = true

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Setup form components
        setupFormComponents()

        // Setup activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupNavigationBar() {
        navigationBar.backgroundColor = AppColors.background
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        // Close button
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = AppColors.text
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        navigationBar.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleText: String
        switch mode {
        case .create:
            titleText = "New Request"
        case .view:
            titleText = "Request Details"
        case .edit:
            titleText = "Edit Request"
        }
        titleLabel.text = titleText
        titleLabel.font = AppTypography.headline
        titleLabel.textColor = AppColors.text
        titleLabel.textAlignment = .center
        navigationBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44),

            closeButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: AppSpacing.md),
            closeButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    private func setupFormComponents() {
        var currentY: CGFloat = AppSpacing.lg

        // Setup header for view/edit modes
        if case .view = mode {
            setupHeaderSection()
            contentView.addSubview(headerContainerView)
            headerContainerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
                headerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
                headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg)
            ])
            currentY += 150 // Approximate height for header
        }

        // Problem Section Header
        setupLabel(problemHeaderLabel, text: "Problem", font: AppTypography.headline, color: AppColors.secondary)
        contentView.addSubview(problemHeaderLabel)
        problemHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        let problemHeaderTopAnchor: NSLayoutYAxisAnchor
        if case .view = mode {
            problemHeaderTopAnchor = headerContainerView.bottomAnchor
        } else {
            problemHeaderTopAnchor = contentView.topAnchor
        }
        NSLayoutConstraint.activate([
            problemHeaderLabel.topAnchor.constraint(equalTo: problemHeaderTopAnchor, constant: AppSpacing.lg),
            problemHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            problemHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg)
        ])

        // Main Category
        setupLabel(mainCategoryLabel, text: "Main Category *", font: AppTypography.callout, color: AppColors.text)
        contentView.addSubview(mainCategoryLabel)
        mainCategoryLabel.translatesAutoresizingMaskIntoConstraints = false

        styleDropdownButton(mainCategoryButton)
        mainCategoryButton.setTitle("Value", for: .normal)
        mainCategoryButton.addTarget(self, action: #selector(mainCategoryTapped), for: .touchUpInside)
        contentView.addSubview(mainCategoryButton)
        mainCategoryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainCategoryLabel.topAnchor.constraint(equalTo: problemHeaderLabel.bottomAnchor, constant: AppSpacing.md),
            mainCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            mainCategoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),

            mainCategoryButton.topAnchor.constraint(equalTo: mainCategoryLabel.bottomAnchor, constant: AppSpacing.xs),
            mainCategoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            mainCategoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
            mainCategoryButton.heightAnchor.constraint(equalToConstant: AppSize.textFieldHeight)
        ])

        // Sub Category
        setupLabel(subCategoryLabel, text: "Sub-Category *", font: AppTypography.callout, color: AppColors.text)
        contentView.addSubview(subCategoryLabel)
        subCategoryLabel.translatesAutoresizingMaskIntoConstraints = false

        styleDropdownButton(subCategoryButton)
        subCategoryButton.setTitle("Value", for: .normal)
        subCategoryButton.addTarget(self, action: #selector(subCategoryTapped), for: .touchUpInside)
        contentView.addSubview(subCategoryButton)
        subCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        subCategoryButton.isEnabled = false
        subCategoryButton.alpha = 0.5

        NSLayoutConstraint.activate([
            subCategoryLabel.topAnchor.constraint(equalTo: mainCategoryButton.bottomAnchor, constant: AppSpacing.md),
            subCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            subCategoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),

            subCategoryButton.topAnchor.constraint(equalTo: subCategoryLabel.bottomAnchor, constant: AppSpacing.xs),
            subCategoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            subCategoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
            subCategoryButton.heightAnchor.constraint(equalToConstant: AppSize.textFieldHeight)
        ])

        // Description
        setupLabel(descriptionLabel, text: "Description *", font: AppTypography.callout, color: AppColors.text)
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        styleTextView(descriptionTextView)
        descriptionTextView.delegate = self
        contentView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: subCategoryButton.bottomAnchor, constant: AppSpacing.md),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),

            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: AppSpacing.xs),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Images Section
        setupLabel(imagesLabel, text: "Images", font: AppTypography.callout, color: AppColors.text)
        contentView.addSubview(imagesLabel)
        imagesLabel.translatesAutoresizingMaskIntoConstraints = false

        styleOutlinedButton(selectImagesButton)
        selectImagesButton.setTitle("Select Images", for: .normal)
        selectImagesButton.addTarget(self, action: #selector(selectImagesTapped), for: .touchUpInside)
        contentView.addSubview(selectImagesButton)
        selectImagesButton.translatesAutoresizingMaskIntoConstraints = false

        // Image action buttons
        setupImageActionButtons()
        contentView.addSubview(imagesStackView)
        imagesStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imagesLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: AppSpacing.md),
            imagesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            imagesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),

            selectImagesButton.topAnchor.constraint(equalTo: imagesLabel.bottomAnchor, constant: AppSpacing.xs),
            selectImagesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            selectImagesButton.widthAnchor.constraint(equalToConstant: 150),
            selectImagesButton.heightAnchor.constraint(equalToConstant: 40),

            imagesStackView.centerYAnchor.constraint(equalTo: selectImagesButton.centerYAnchor),
            imagesStackView.leadingAnchor.constraint(equalTo: selectImagesButton.trailingAnchor, constant: AppSpacing.lg),
            imagesStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -AppSpacing.lg)
        ])

        // Location Section Header
        setupLabel(locationHeaderLabel, text: "Location", font: AppTypography.headline, color: AppColors.secondary)
        contentView.addSubview(locationHeaderLabel)
        locationHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationHeaderLabel.topAnchor.constraint(equalTo: selectImagesButton.bottomAnchor, constant: AppSpacing.lg),
            locationHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            locationHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg)
        ])

        // Building
        setupLabel(buildingLabel, text: "Building No. *", font: AppTypography.callout, color: AppColors.text)
        contentView.addSubview(buildingLabel)
        buildingLabel.translatesAutoresizingMaskIntoConstraints = false

        styleDropdownButton(buildingButton)
        buildingButton.setTitle("Value", for: .normal)
        buildingButton.addTarget(self, action: #selector(buildingTapped), for: .touchUpInside)
        contentView.addSubview(buildingButton)
        buildingButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buildingLabel.topAnchor.constraint(equalTo: locationHeaderLabel.bottomAnchor, constant: AppSpacing.md),
            buildingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            buildingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),

            buildingButton.topAnchor.constraint(equalTo: buildingLabel.bottomAnchor, constant: AppSpacing.xs),
            buildingButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            buildingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
            buildingButton.heightAnchor.constraint(equalToConstant: AppSize.textFieldHeight)
        ])

        // Room
        setupLabel(roomLabel, text: "Room No. *", font: AppTypography.callout, color: AppColors.text)
        contentView.addSubview(roomLabel)
        roomLabel.translatesAutoresizingMaskIntoConstraints = false

        styleDropdownButton(roomButton)
        roomButton.setTitle("Value", for: .normal)
        roomButton.addTarget(self, action: #selector(roomTapped), for: .touchUpInside)
        contentView.addSubview(roomButton)
        roomButton.translatesAutoresizingMaskIntoConstraints = false
        roomButton.isEnabled = false
        roomButton.alpha = 0.5

        NSLayoutConstraint.activate([
            roomLabel.topAnchor.constraint(equalTo: buildingButton.bottomAnchor, constant: AppSpacing.md),
            roomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            roomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),

            roomButton.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: AppSpacing.xs),
            roomButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            roomButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
            roomButton.heightAnchor.constraint(equalToConstant: AppSize.textFieldHeight)
        ])

        // Action Buttons Stack View
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = AppSpacing.md
        actionButtonsStackView.distribution = .fillEqually
        contentView.addSubview(actionButtonsStackView)
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButtonsStackView.topAnchor.constraint(equalTo: roomButton.bottomAnchor, constant: AppSpacing.xl),
            actionButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppSpacing.lg),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppSpacing.lg),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppSpacing.xl)
        ])
    }

    private func setupHeaderSection() {
        // Request Number
        requestNumberLabel.font = AppTypography.title2
        requestNumberLabel.textColor = AppColors.text
        requestNumberLabel.textAlignment = .center
        headerContainerView.addSubview(requestNumberLabel)
        requestNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        // Status Container
        statusContainerView.addSubview(statusDot)
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.layer.cornerRadius = AppSize.statusDot / 2

        statusLabel.font = AppTypography.callout
        statusLabel.textColor = AppColors.text
        statusContainerView.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        headerContainerView.addSubview(statusContainerView)
        statusContainerView.translatesAutoresizingMaskIntoConstraints = false

        // Priority Label
        priorityLabel.font = AppTypography.callout
        priorityLabel.textColor = AppColors.text
        headerContainerView.addSubview(priorityLabel)
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false

        // Technician Label
        technicianLabel.font = AppTypography.callout
        technicianLabel.textColor = AppColors.text
        headerContainerView.addSubview(technicianLabel)
        technicianLabel.translatesAutoresizingMaskIntoConstraints = false

        // Delete Button
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = AppColors.text
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        headerContainerView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            requestNumberLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            requestNumberLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            requestNumberLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -AppSpacing.md),

            deleteButton.centerYAnchor.constraint(equalTo: requestNumberLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: AppSize.icon),
            deleteButton.heightAnchor.constraint(equalToConstant: AppSize.icon),

            statusContainerView.topAnchor.constraint(equalTo: requestNumberLabel.bottomAnchor, constant: AppSpacing.md),
            statusContainerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            statusContainerView.heightAnchor.constraint(equalToConstant: 30),

            statusDot.centerYAnchor.constraint(equalTo: statusContainerView.centerYAnchor),
            statusDot.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: AppSize.statusDot),
            statusDot.heightAnchor.constraint(equalToConstant: AppSize.statusDot),

            statusLabel.centerYAnchor.constraint(equalTo: statusContainerView.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: AppSpacing.xs),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor),

            priorityLabel.topAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: AppSpacing.sm),
            priorityLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            priorityLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),

            technicianLabel.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: AppSpacing.sm),
            technicianLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            technicianLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            technicianLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])
    }

    private func setupLabel(_ label: UILabel, text: String, font: UIFont, color: UIColor) {
        label.text = text
        label.font = font
        label.textColor = color
    }

    private func styleDropdownButton(_ button: UIButton) {
        button.backgroundColor = AppColors.inputBackground
        button.setTitleColor(AppColors.placeholder, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.layer.cornerRadius = AppSize.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.inputBorder.cgColor

        if let chevronImage = UIImage(systemName: "chevron.down") {
            button.setImage(chevronImage.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = AppColors.placeholder
            button.semanticContentAttribute = .forceRightToLeft
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
    }

    private func styleTextView(_ textView: UITextView) {
        textView.backgroundColor = AppColors.inputBackground
        textView.layer.cornerRadius = AppSize.cornerRadius
        textView.layer.borderWidth = 1
        textView.layer.borderColor = AppColors.inputBorder.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.font = AppTypography.body
        textView.text = placeholderText
        textView.textColor = AppColors.placeholder
    }

    private func styleOutlinedButton(_ button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(AppColors.text, for: .normal)
        button.layer.cornerRadius = AppSize.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.inputBorder.cgColor
        button.titleLabel?.font = AppTypography.callout
    }

    private func styleFilledButton(_ button: UIButton) {
        button.backgroundColor = AppColors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = AppSize.cornerRadius
        button.titleLabel?.font = AppTypography.headline
    }

    private func setupImageActionButtons() {
        imagesStackView.axis = .horizontal
        imagesStackView.spacing = AppSpacing.lg
        imagesStackView.distribution = .fillEqually

        // Preview button
        previewButton = UIButton(type: .system)
        previewButton.setImage(UIImage(systemName: "eye"), for: .normal)
        previewButton.tintColor = AppColors.text
        previewButton.addTarget(self, action: #selector(previewImagesTapped), for: .touchUpInside)
        previewButton.isHidden = true

        // Download button (for viewing existing images)
        downloadButton = UIButton(type: .system)
        downloadButton.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        downloadButton.tintColor = AppColors.text
        downloadButton.addTarget(self, action: #selector(downloadImagesTapped), for: .touchUpInside)
        downloadButton.isHidden = true

        // Delete images button
        deleteImagesButton = UIButton(type: .system)
        deleteImagesButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteImagesButton.tintColor = AppColors.error
        deleteImagesButton.addTarget(self, action: #selector(deleteImagesTapped), for: .touchUpInside)
        deleteImagesButton.isHidden = true

        imagesStackView.addArrangedSubview(previewButton)
        imagesStackView.addArrangedSubview(downloadButton)
        imagesStackView.addArrangedSubview(deleteImagesButton)
    }

    private func updateImageButtons() {
        let hasNewImages = !selectedImages.isEmpty
        let hasExistingImages = !existingImageURLs.isEmpty

        previewButton.isHidden = !hasNewImages && !hasExistingImages
        downloadButton.isHidden = !hasExistingImages
        deleteImagesButton.isHidden = !hasNewImages

        let totalCount = selectedImages.count + existingImageURLs.count
        if totalCount > 0 {
            selectImagesButton.setTitle("Selected: \(totalCount)", for: .normal)
        } else {
            selectImagesButton.setTitle("Select Images", for: .normal)
        }
    }

    // MARK: - Data Fetching
    private func fetchUserType() {
        Task {
            do {
                let userTypeRaw = try await SessionManager.shared.getUserType()
                if let userType = UserType(rawValue: userTypeRaw) {
                    await MainActor.run {
                        self.currentUserType = userType

                        // For create mode, setup action buttons after user type is fetched
                        if case .create = self.mode {
                            self.setupActionButtons(for: userType, status: .submitted)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

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

    private func fetchRequestDetails(requestId: UUID) {
        activityIndicator.startAnimating()

        Task {
            do {
                // Fetch request and reference data
                async let requestTask = RequestController.shared.getRequestForDisplay(requestId: requestId)
                async let categoriesTask = CategoryController.shared.getParentCategories()
                async let buildingsTask = LocationController.shared.getActiveBuildings()

                let (model, categories, fetchedBuildings) = try await (requestTask, categoriesTask, buildingsTask)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    if let model = model {
                        self.requestModel = model
                        self.mainCategories = categories
                        self.buildings = fetchedBuildings
                        self.populateData(with: model)
                        self.configureUIForMode()
                    } else {
                        self.showAlert(title: "Error", message: "Request not found") { [weak self] in
                            self?.dismiss(animated: true)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription) { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
            }
        }
    }

    private func populateData(with model: RequestDisplayModel) {
        // Populate header (for view mode)
        if case .view = mode {
            requestNumberLabel.text = model.requestNo

            statusLabel.text = "Status: \(model.status.displayString)"
            statusDot.backgroundColor = model.status.displayColor

            let priorityText = NSMutableAttributedString(string: "Priority: ", attributes: [
                .foregroundColor: AppColors.text,
                .font: AppTypography.callout
            ])
            let priorityColor = model.priority?.displayColor ?? AppColors.secondary
            let priorityString = model.priority?.displayString ?? "Not Set"
            let priorityValue = NSAttributedString(string: priorityString, attributes: [
                .foregroundColor: priorityColor,
                .font: AppTypography.callout
            ])
            priorityText.append(priorityValue)
            priorityLabel.attributedText = priorityText

            // Fetch and display technician name
            fetchServicerName(servicerId: model.request.servicerRef)
        }

        // Populate form fields
        mainCategoryButton.setTitle(model.categoryName, for: .normal)
        mainCategoryButton.setTitleColor(AppColors.text, for: .normal)

        subCategoryButton.setTitle(model.subcategoryName, for: .normal)
        subCategoryButton.setTitleColor(AppColors.text, for: .normal)

        descriptionTextView.text = model.description
        descriptionTextView.textColor = AppColors.text

        buildingButton.setTitle(model.buildingNo, for: .normal)
        buildingButton.setTitleColor(AppColors.text, for: .normal)

        roomButton.setTitle(model.roomNo, for: .normal)
        roomButton.setTitleColor(AppColors.text, for: .normal)

        // Store existing images
        if let images = model.images {
            existingImageURLs = images
            updateImageButtons()
        }

        // Fetch subcategories and rooms for the selected items
        Task {
            do {
                async let subcatsTask = CategoryController.shared.getSubcategories(forParentId: model.request.requestCategoryRef)
                async let roomsTask = LocationController.shared.getActiveRooms(forBuildingId: model.request.buildingRef)

                let (subcats, fetchedRooms) = try await (subcatsTask, roomsTask)

                await MainActor.run {
                    self.subCategories = subcats
                    self.rooms = fetchedRooms

                    // Set selected items
                    self.selectedMainCategory = self.mainCategories.first { $0.id == model.request.requestCategoryRef }
                    self.selectedSubCategory = subcats.first { $0.id == model.request.requestSubcategoryRef }
                    self.selectedBuilding = self.buildings.first { $0.id == model.request.buildingRef }
                    self.selectedRoom = fetchedRooms.first { $0.id == model.request.roomRef }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func fetchServicerName(servicerId: String?) {
        guard let servicerId = servicerId, !servicerId.isEmpty else {
            technicianLabel.text = "Technician: Not Assigned Yet"
            return
        }

        Task {
            do {
                let db = Firestore.firestore()
                let doc = try await db.collection("User").document(servicerId).getDocument()

                await MainActor.run {
                    if let fullName = doc.data()?["fullName"] as? String {
                        self.technicianLabel.text = "Technician: \(fullName)"
                    } else {
                        self.technicianLabel.text = "Technician: Unknown"
                    }
                }
            } catch {
                await MainActor.run {
                    self.technicianLabel.text = "Technician: Error loading"
                }
            }
        }
    }

    private func configureUIForMode() {
        guard let model = requestModel, let userType = currentUserType else { return }

        let isReadOnly: Bool

        switch mode {
        case .create:
            isReadOnly = false
            deleteButton.isHidden = true
        case .view:
            isReadOnly = true
            // Delete button visibility based on user type (only for admin)
            deleteButton.isHidden = userType != .admin
        case .edit:
            // Edit mode - only for requesters when status is submitted
            isReadOnly = false
            deleteButton.isHidden = false // Show delete for requester
        }

        // Set form fields to read-only if needed
        mainCategoryButton.isEnabled = !isReadOnly
        mainCategoryButton.alpha = isReadOnly ? 0.7 : 1.0

        subCategoryButton.isEnabled = !isReadOnly && selectedMainCategory != nil
        subCategoryButton.alpha = (!isReadOnly && selectedMainCategory != nil) ? 1.0 : 0.7

        descriptionTextView.isEditable = !isReadOnly
        descriptionTextView.alpha = isReadOnly ? 0.7 : 1.0

        buildingButton.isEnabled = !isReadOnly
        buildingButton.alpha = isReadOnly ? 0.7 : 1.0

        roomButton.isEnabled = !isReadOnly && selectedBuilding != nil
        roomButton.alpha = (!isReadOnly && selectedBuilding != nil) ? 1.0 : 0.7

        selectImagesButton.isEnabled = !isReadOnly
        selectImagesButton.alpha = isReadOnly ? 0.7 : 1.0

        // Setup action buttons based on user type and status
        setupActionButtons(for: userType, status: model.status)
    }

    private func setupActionButtons(for userType: UserType, status: Status) {
        // Clear existing buttons
        actionButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let model = requestModel else {
            // Create mode - show submit button
            let submitButton = UIButton(type: .system)
            styleFilledButton(submitButton)
            submitButton.setTitle("Submit", for: .normal)
            submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
            submitButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
            actionButtonsStackView.addArrangedSubview(submitButton)
            return
        }

        switch userType {
        case .admin:
            setupAdminActions(for: status)
        case .requester:
            setupRequesterActions(for: status)
        case .servicer:
            setupServicerActions(for: status)
        }
    }

    private func setupAdminActions(for status: Status) {
        switch status {
        case .submitted:
            guard let model = requestModel else { return }

            if model.request.priority == nil {
                // Priority not set - show "Assign Priority" button ONLY
                addPriorityButton()
            } else if model.request.servicerRef == nil || model.request.servicerRef?.isEmpty == true {
                // Priority set but servicer not assigned - show "Assign Servicer" button ONLY
                let assignButton = UIButton(type: .system)
                styleFilledButton(assignButton)
                assignButton.setTitle("Assign Servicer", for: .normal)
                assignButton.addTarget(self, action: #selector(assignServicerButtonTapped), for: .touchUpInside)
                assignButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
                actionButtonsStackView.addArrangedSubview(assignButton)
            }

        case .assigned, .onHold, .delayed:
            // Show "Reassign" button
            let reassignButton = UIButton(type: .system)
            styleFilledButton(reassignButton)
            reassignButton.setTitle("Reassign", for: .normal)
            reassignButton.addTarget(self, action: #selector(reassignButtonTapped), for: .touchUpInside)
            reassignButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
            actionButtonsStackView.addArrangedSubview(reassignButton)

        default:
            break
        }
    }

    private func addPriorityButton() {
        let priorityButton = UIButton(type: .system)
        styleFilledButton(priorityButton)
        priorityButton.setTitle("Assign Priority", for: .normal)
        priorityButton.addTarget(self, action: #selector(assignPriorityButtonTapped), for: .touchUpInside)
        priorityButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
        actionButtonsStackView.addArrangedSubview(priorityButton)
    }

    private func setupRequesterActions(for status: Status) {
        if status == .completed {
            // Show "Submit Feedback" button
            let feedbackButton = UIButton(type: .system)
            styleFilledButton(feedbackButton)
            feedbackButton.setTitle("Submit Feedback", for: .normal)
            feedbackButton.addTarget(self, action: #selector(submitFeedbackButtonTapped), for: .touchUpInside)
            feedbackButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
            actionButtonsStackView.addArrangedSubview(feedbackButton)
        }
    }

    private func setupServicerActions(for status: Status) {
        guard let model = requestModel,
              let currentUserId = try? SessionManager.shared.requireUserId(),
              model.request.servicerRef == currentUserId else {
            return
        }

        // "Send Back" button - always shown when request is assigned to servicer
        if status == .assigned || status == .inProgress {
            let sendBackButton = UIButton(type: .system)
            styleOutlinedButton(sendBackButton)
            sendBackButton.setTitleColor(AppColors.error, for: .normal)
            sendBackButton.setTitle("Send Back", for: .normal)
            sendBackButton.addTarget(self, action: #selector(sendBackButtonTapped), for: .touchUpInside)
            sendBackButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
            actionButtonsStackView.addArrangedSubview(sendBackButton)
        }

        // Status-specific buttons
        switch status {
        case .assigned:
            // Show "Schedule" button if not yet scheduled
            if model.request.estimatedStartDate == nil {
                let scheduleButton = UIButton(type: .system)
                styleFilledButton(scheduleButton)
                scheduleButton.setTitle("Schedule", for: .normal)
                scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
                scheduleButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
                actionButtonsStackView.addArrangedSubview(scheduleButton)
            } else {
                // Show "Start" button if scheduled
                let startButton = UIButton(type: .system)
                styleFilledButton(startButton)
                startButton.setTitle("Start", for: .normal)
                startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
                startButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
                actionButtonsStackView.addArrangedSubview(startButton)
            }

        case .inProgress:
            // Show "Complete" button
            let completeButton = UIButton(type: .system)
            styleFilledButton(completeButton)
            completeButton.setTitle("Complete", for: .normal)
            completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
            completeButton.heightAnchor.constraint(equalToConstant: AppSize.buttonHeight).isActive = true
            actionButtonsStackView.addArrangedSubview(completeButton)

        default:
            break
        }
    }

    // MARK: - Actions
    @objc private func mainCategoryTapped() {
        showSelectionSheet(title: "Select Main Category", items: mainCategories.map { $0.name }) { [weak self] index in
            guard let self = self else { return }
            self.selectedMainCategory = self.mainCategories[index]
            self.mainCategoryButton.setTitle(self.mainCategories[index].name, for: .normal)
            self.mainCategoryButton.setTitleColor(AppColors.text, for: .normal)

            // Reset sub category
            self.selectedSubCategory = nil
            self.subCategoryButton.setTitle("Value", for: .normal)
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

    @objc private func subCategoryTapped() {
        showSelectionSheet(title: "Select Sub-Category", items: subCategories.map { $0.name }) { [weak self] index in
            guard let self = self else { return }
            self.selectedSubCategory = self.subCategories[index]
            self.subCategoryButton.setTitle(self.subCategories[index].name, for: .normal)
            self.subCategoryButton.setTitleColor(AppColors.text, for: .normal)
        }
    }

    @objc private func selectImagesTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }

    @objc private func previewImagesTapped() {
        // Preview selected images or existing images
        guard !selectedImages.isEmpty || !existingImageURLs.isEmpty else { return }

        let alert = UIAlertController(title: "Images", message: nil, preferredStyle: .actionSheet)

        for (index, _) in selectedImages.enumerated() {
            alert.addAction(UIAlertAction(title: "View New Image \(index + 1)", style: .default) { [weak self] _ in
                self?.showImagePreview(image: self?.selectedImages[index])
            })
        }

        for (index, url) in existingImageURLs.enumerated() {
            alert.addAction(UIAlertAction(title: "View Existing Image \(index + 1)", style: .default) { [weak self] _ in
                self?.showImagePreview(url: url)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = previewButton
            popover.sourceRect = previewButton.bounds
        }

        present(alert, animated: true)
    }

    private func showImagePreview(image: UIImage? = nil, url: String? = nil) {
        let imageVC = UIViewController()
        imageVC.view.backgroundColor = .black

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageVC.view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageVC.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageVC.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageVC.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageVC.view.trailingAnchor)
        ])

        if let image = image {
            imageView.image = image
        } else if let url = url, let imageURL = URL(string: url) {
            // Load image from URL
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data, let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = downloadedImage
                    }
                }
            }.resume()
        }

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

    @objc private func downloadImagesTapped() {
        // Implement download functionality if needed
        showAlert(title: "Info", message: "Image download functionality to be implemented")
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

    @objc private func buildingTapped() {
        showSelectionSheet(title: "Select Building", items: buildings.map { $0.buildingNo }) { [weak self] index in
            guard let self = self else { return }
            self.selectedBuilding = self.buildings[index]
            self.buildingButton.setTitle(self.buildings[index].buildingNo, for: .normal)
            self.buildingButton.setTitleColor(AppColors.text, for: .normal)

            // Reset room
            self.selectedRoom = nil
            self.roomButton.setTitle("Value", for: .normal)
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

    @objc private func roomTapped() {
        showSelectionSheet(title: "Select Room", items: rooms.map { $0.roomNo }) { [weak self] index in
            guard let self = self else { return }
            self.selectedRoom = self.rooms[index]
            self.roomButton.setTitle(self.rooms[index].roomNo, for: .normal)
            self.roomButton.setTitleColor(AppColors.text, for: .normal)
        }
    }

    @objc private func submitButtonTapped() {
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

        Task {
            do {
                // Upload images first if any
                var imageURLs: [String] = []
                if !selectedImages.isEmpty {
                    imageURLs = try await RequestController.shared.uploadImages(selectedImages)
                }

                // Submit request
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
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func deleteButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        showConfirmationAlert(
            title: "Cancel Request",
            message: "Are you sure you want to cancel this request? This action cannot be undone."
        ) { [weak self] in
            self?.cancelRequest(requestId: requestId)
        }
    }

    private func cancelRequest(requestId: UUID) {
        activityIndicator.startAnimating()

        Task {
            do {
                let userId = try SessionManager.shared.requireUserId()
                let db = Firestore.firestore()

                // Update status to cancelled
                try await db.collection("Request").document(requestId.uuidString).updateData([
                    "status": Status.cancelled.rawValue,
                    "modifiedOn": Timestamp(date: Date()),
                    "modifiedBy": userId
                ])

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Request has been cancelled.") { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func assignServicerButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        activityIndicator.startAnimating()

        Task {
            do {
                let servicers = try await RequestController.shared.getServicers()

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showServicerSelection(servicers: servicers, mode: .assign, requestId: requestId)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func reassignButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        activityIndicator.startAnimating()

        Task {
            do {
                let servicers = try await RequestController.shared.getServicers()

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showServicerSelection(servicers: servicers, mode: .reassign, requestId: requestId)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func assignPriorityButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }
        showPrioritySelection(requestId: requestId)
    }

    private func showPrioritySelection(requestId: UUID) {
        let title = "Select Priority"
        let priorities: [Priority] = [.low, .moderate, .high]
        let priorityNames = priorities.map { $0.displayString }

        showSelectionSheet(title: title, items: priorityNames) { [weak self] index in
            let selectedPriority = priorities[index]
            self?.performPriorityAssignment(requestId: requestId, priority: selectedPriority)
        }
    }

    private func performPriorityAssignment(requestId: UUID, priority: Priority) {
        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.assignPriority(requestId: requestId, priority: priority)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Priority has been set to \(priority.displayString).") { [weak self] in
                        // Refresh the request details to show updated priority
                        self?.fetchRequestDetails(requestId: requestId)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private enum ServicerSelectionMode {
        case assign
        case reassign
    }

    private func showServicerSelection(servicers: [User], mode: ServicerSelectionMode, requestId: UUID) {
        let title = mode == .assign ? "Select Servicer" : "Reassign to Servicer"
        showSelectionSheet(title: title, items: servicers.map { $0.fullName }) { [weak self] index in
            let selectedServicer = servicers[index]

            if mode == .reassign {
                // Prompt for reason
                self?.promptForReason(title: "Reassign Reason", message: "Please provide a reason for reassignment:") { reason in
                    self?.performReassign(requestId: requestId, servicerId: selectedServicer.id, reason: reason)
                }
            } else {
                // Direct assignment
                self?.performAssignment(requestId: requestId, servicerId: selectedServicer.id)
            }
        }
    }

    private func performAssignment(requestId: UUID, servicerId: String) {
        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.assignNewRequest(requestId: requestId, servicerId: servicerId)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Servicer has been assigned successfully.") { [weak self] in
                        // Refresh the request details
                        self?.fetchRequestDetails(requestId: requestId)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func performReassign(requestId: UUID, servicerId: String, reason: String) {
        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.reassignRequest(requestId: requestId, newServicerId: servicerId, reason: reason)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Request has been reassigned successfully.") { [weak self] in
                        // Refresh the request details
                        self?.fetchRequestDetails(requestId: requestId)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func sendBackButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        promptForReason(title: "Send Back Reason", message: "Please provide a reason for sending back this request:") { [weak self] reason in
            self?.performSendBack(requestId: requestId, reason: reason)
        }
    }

    private func performSendBack(requestId: UUID, reason: String) {
        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.sendBackRequest(requestId: requestId, reason: reason)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Request has been sent back.") { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func scheduleButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        // Show date pickers for start and end dates
        showDatePickersAlert(requestId: requestId)
    }

    private func showDatePickersAlert(requestId: UUID) {
        let alert = UIAlertController(title: "Schedule Request", message: "Select estimated start and end dates", preferredStyle: .alert)

        // Create date pickers
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.minimumDate = Date()
        startDatePicker.preferredDatePickerStyle = .wheels

        let endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .date
        endDatePicker.minimumDate = Date()
        endDatePicker.preferredDatePickerStyle = .wheels

        // Create container for pickers
        let pickerContainer = UIStackView()
        pickerContainer.axis = .vertical
        pickerContainer.spacing = 8

        let startLabel = UILabel()
        startLabel.text = "Start Date:"
        startLabel.font = AppTypography.callout

        let endLabel = UILabel()
        endLabel.text = "End Date:"
        endLabel.font = AppTypography.callout

        pickerContainer.addArrangedSubview(startLabel)
        pickerContainer.addArrangedSubview(startDatePicker)
        pickerContainer.addArrangedSubview(endLabel)
        pickerContainer.addArrangedSubview(endDatePicker)

        alert.view.addSubview(pickerContainer)
        pickerContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerContainer.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            pickerContainer.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
            pickerContainer.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
            pickerContainer.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60)
        ])

        alert.addAction(UIAlertAction(title: "Schedule", style: .default) { [weak self] _ in
            self?.performSchedule(requestId: requestId, startDate: startDatePicker.date, endDate: endDatePicker.date)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 450)
        alert.view.addConstraint(height)

        present(alert, animated: true)
    }

    private func performSchedule(requestId: UUID, startDate: Date, endDate: Date) {
        guard endDate >= startDate else {
            showAlert(title: "Invalid Dates", message: "End date must be after or equal to start date.")
            return
        }

        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.scheduleRequest(requestId: requestId, estimatedStartDate: startDate, estimatedEndDate: endDate)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Request has been scheduled successfully.") { [weak self] in
                        // Refresh the request details
                        self?.fetchRequestDetails(requestId: requestId)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func startButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        showConfirmationAlert(title: "Start Request", message: "Are you ready to start working on this request?") { [weak self] in
            self?.performStart(requestId: requestId)
        }
    }

    private func performStart(requestId: UUID) {
        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.startRequest(requestId: requestId)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Request has been started.") { [weak self] in
                        // Refresh the request details
                        self?.fetchRequestDetails(requestId: requestId)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func completeButtonTapped() {
        guard let requestId = requestModel?.request.id else { return }

        showConfirmationAlert(title: "Complete Request", message: "Are you sure you want to mark this request as completed?") { [weak self] in
            self?.performComplete(requestId: requestId)
        }
    }

    private func performComplete(requestId: UUID) {
        activityIndicator.startAnimating()

        Task {
            do {
                try await RequestController.shared.completeRequest(requestId: requestId)

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Success", message: "Request has been completed.") { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func submitFeedbackButtonTapped() {
        // Implement feedback submission
        showAlert(title: "Info", message: "Feedback submission to be implemented")
    }

    // MARK: - Helper Methods
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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

    private func promptForReason(title: String, message: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Enter reason"
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            if let reason = alert.textFields?.first?.text, !reason.isEmpty {
                completion(reason)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension BaseRequestFormViewController: UITextViewDelegate {
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
extension BaseRequestFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
