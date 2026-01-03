//
//  CategoryViewControllers.swift
//  CRMS
//
//  Merged Category-related view controllers
//

import UIKit

// MARK: - View Model for hierarchical display

/// View model that groups a parent category with its subcategories for UI display
struct CategoryDisplayModel {
    let parent: RequestCategory
    var subcategories: [RequestCategory]
    var isExpanded: Bool = false
}

// MARK: - Category Management

final class CategoryManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // Display models for hierarchical view
    var displayModels: [CategoryDisplayModel] = []
    var filteredDisplayModels: [CategoryDisplayModel] = []

    var isSearching: Bool {
        return !searchBar.text!.isEmpty
    }
    var isEditMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupTableView()
        Task { await reloadCategories() }

        // Removes the outer border/background
        searchBar.backgroundImage = UIImage()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.register(SubCategoryCell.self, forCellReuseIdentifier: "SubCategoryCell")
        tableView.separatorStyle = .none
    }

    @MainActor
    private func reloadCategories() async {
        do {
            let allCategories = try await CategoryController.shared.getAllCategories()

            // Build hierarchical display models from flat data
            let parents = allCategories.filter { $0.isParent }
            displayModels = parents.map { parent in
                let subs = allCategories.filter { $0.parentCategoryRef == parent.id }
                return CategoryDisplayModel(parent: parent, subcategories: subs, isExpanded: false)
            }

            tableView.reloadData()
        } catch {
            print("❌ reloadCategories failed:", error)
        }
    }

    // MARK: - Actions
    @IBAction func editButtonTapped(_ sender: UIButton) {
        isEditMode.toggle()
        titleLabel.text = isEditMode ? "Edit Categories" : "Category Management"
        tableView.reloadData()
    }

    @IBAction func addSubCategoryTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Category", message: "Choose a category to add a sub-item to", preferredStyle: .actionSheet)

        let dataSource = isSearching ? filteredDisplayModels : displayModels
        for model in dataSource {
            let action = UIAlertAction(title: model.parent.name, style: .default) { [weak self] _ in
                self?.showAddSubPopup(parentId: model.parent.id)
            }
            actionSheet.addAction(action)
        }

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        present(actionSheet, animated: true)
    }

    private func showAddSubPopup(parentId: UUID) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddSubCategoryViewController") as? AddSubCategoryViewController else { return }

        vc.targetParentId = parentId

        vc.onSubCategoryAdded = { [weak self] in
            Task {
                await self?.reloadCategories()
                self?.presentSuccessScreen()
            }
        }

        let popup = DraggablePopupViewController(contentVC: vc, height: 450)
        present(popup, animated: false) { popup.presentPopup() }
    }

    private func presentSuccessScreen() {
        if let successVC = storyboard?.instantiateViewController(withIdentifier: "SubCategorySuccess") as? SubCategorySuccess {
            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve
            self.present(successVC, animated: true)
        }
    }

    @IBAction func addCategoryTapped(_ sender: UIButton) {
        guard let addVC = storyboard?.instantiateViewController(
                withIdentifier: "AddCategoryViewController"
            ) as? AddCategoryViewController else { return }

            addVC.onCategoryAdded = { [weak self] in
                Task { await self?.reloadCategories() }
            }

            let popup = DraggablePopupViewController(
                contentVC: addVC,
                height: 450
            )

            present(popup, animated: false) {
                popup.presentPopup()
            }
    }
}

// MARK: - UITableView Delegate & DataSource
extension CategoryManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? filteredDisplayModels.count : displayModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = isSearching ? filteredDisplayModels : displayModels
        let model = dataSource[section]
        return model.isExpanded ? (model.subcategories.count + 1) : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = isSearching ? filteredDisplayModels : displayModels
        let model = dataSource[indexPath.section]

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.configure(with: model.parent.name, isExpanded: model.isExpanded)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
        let idx = indexPath.row - 1
        let sub = model.subcategories[idx]

        // Note: inactive logic is inverted - inactive=false means active
        cell.configure(with: sub.name, isActive: !sub.inactive, isEditMode: isEditMode)

        cell.onToggleChanged = { [weak self] (isOn: Bool) in
            guard let self = self else { return }

            // Update local state
            if let originalIndex = self.displayModels.firstIndex(where: { $0.parent.id == model.parent.id }) {
                self.displayModels[originalIndex].subcategories[idx].inactive = !isOn
            }

            // Update Firestore
            Task {
                do {
                    let userId = try SessionManager.shared.requireUserId()
                    try await CategoryController.shared.updateCategoryStatus(
                        categoryId: sub.id,
                        inactive: !isOn,
                        modifiedBy: userId
                    )
                } catch {
                    print("❌ Failed to update subcategory status:", error)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 else { return }

        if isSearching {
            filteredDisplayModels[indexPath.section].isExpanded.toggle()
        } else {
            displayModels[indexPath.section].isExpanded.toggle()
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

}

// MARK: - Custom Cells

class CategoryCell: UITableViewCell {
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let arrowImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = AppColors.chartContainerBackground
        containerView.layer.cornerRadius = AppSize.cornerRadius
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        nameLabel.font = AppTypography.headline
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)

        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 50),

            arrowImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),

            nameLabel.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func configure(with name: String, isExpanded: Bool) {
        nameLabel.text = name
        arrowImageView.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")

        // Configure accessibility
        isAccessibilityElement = true
        accessibilityLabel = "Category: \(name)"
        accessibilityValue = isExpanded ? "Expanded" : "Collapsed"
        accessibilityHint = isExpanded ? "Double tap to collapse" : "Double tap to expand"
        accessibilityTraits = .button
    }
}

class SubCategoryCell: UITableViewCell {
    var onToggleChanged: ((Bool) -> Void)?
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let toggleSwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = AppColors.inputBackground
        containerView.layer.cornerRadius = AppSize.cornerRadius
        containerView.layer.borderWidth = AppSize.borderWidth
        containerView.layer.borderColor = AppColors.inputBorder.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        nameLabel.font = AppTypography.body
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)

        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        containerView.addSubview(toggleSwitch)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            containerView.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        onToggleChanged?(sender.isOn)
    }

    /// Configures the cell with subcategory data
    /// - Parameters:
    ///   - name: The subcategory name
    ///   - isActive: Whether the subcategory is active (not inactive)
    ///   - isEditMode: Whether edit mode is enabled
    func configure(with name: String, isActive: Bool, isEditMode: Bool) {
        nameLabel.text = name
        toggleSwitch.isOn = isActive
        toggleSwitch.isHidden = !isEditMode

        // Configure accessibility
        isAccessibilityElement = true
        accessibilityLabel = "Subcategory: \(name)"
        if isEditMode {
            accessibilityValue = isActive ? "Active" : "Inactive"
            accessibilityHint = "Double tap to toggle status"
        } else {
            accessibilityValue = nil
            accessibilityHint = nil
        }
    }
}

extension CategoryManagementViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredDisplayModels = []
        } else {
            filteredDisplayModels = displayModels.filter { model in
                let categoryMatch = model.parent.name.lowercased().contains(searchText.lowercased())

                let subMatch = model.subcategories.contains { sub in
                    sub.name.lowercased().contains(searchText.lowercased())
                }

                return categoryMatch || subMatch
            }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Add Category

/// View controller for adding a new parent category
class AddCategoryViewController: UIViewController {

    var onCategoryAdded: (() -> Void)?

    @IBOutlet weak var nameTextView: InspectableTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {

        let name = nameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let confirmVC = sb.instantiateViewController(
            withIdentifier: "ConfirmAddCategory"
            )as! ConfirmAddCategory

        confirmVC.name = name

        confirmVC.onCategoryAdded = onCategoryAdded

        confirmVC.modalPresentationStyle = .overFullScreen
        confirmVC.modalTransitionStyle = .crossDissolve
        present(confirmVC, animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {

        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CancelAddCategory") as! CancelAddCategory

          vc.modalPresentationStyle = .overFullScreen
          vc.modalTransitionStyle = .crossDissolve

          present(vc, animated: true)
    }

}

// MARK: - Add SubCategory

/// View controller for adding a subcategory under a parent category
final class AddSubCategoryViewController: UIViewController {

    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!

    var targetParentId: UUID?

    var onSubCategoryAdded: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextView.becomeFirstResponder()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissPopup()
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        let subName = nameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !subName.isEmpty, let parentId = targetParentId else { return }

        sender.isEnabled = false

        Task {
            do {
                let userId = try SessionManager.shared.requireUserId()
                try await CategoryController.shared.addSubCategory(
                    name: subName,
                    parentId: parentId,
                    createdBy: userId
                )
                await MainActor.run { [weak self] in
                    self?.onSubCategoryAdded?()
                    self?.dismissPopup()
                }
            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("❌ Backend Error:", error)
            }
        }
    }

    private func dismissPopup() {
            if let popup = parent as? DraggablePopupViewController {
                popup.dismiss(animated: true)
            } else {
                dismiss(animated: true)
            }
        }

}

// MARK: - Confirm Add Category

class ConfirmAddCategory: UIViewController {

    var name:String?
    var onCategoryAdded: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }


    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false

        let name = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            sender.isEnabled = true
            return
        }

        Task {
            do {
                let userId = try SessionManager.shared.requireUserId()
                try await CategoryController.shared.addCategory(name: name, createdBy: userId)

                await MainActor.run { [weak self] in
                    self?.showSuccessThenCloseAll()
                }

            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("❌ add category failed:", error)
            }
        }
    }

    @IBAction func cancelbuttonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    private func showSuccessThenCloseAll() {
            let sb = UIStoryboard(name: "Faq", bundle: nil)
            let successVC = sb.instantiateViewController(
                withIdentifier: "CategoryAddSuccess"
            ) as! CategoryAddSuccess

            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve

            let addVC = presentingViewController

            dismiss(animated: false) {
                if let add = addVC,
                   let popup = add.parent as? DraggablePopupViewController {

                    popup.dismiss(animated: false) {
                        self.onCategoryAdded?()

                        popup.presentingViewController?.present(successVC, animated: true)
                    }
                } else {
                    self.onCategoryAdded?()
                    addVC?.present(successVC, animated: true)
                }
            }
        }

}

// MARK: - Cancel Add Category

class CancelAddCategory: UIViewController {

    var name:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }


    @IBAction func yesButtonTapped(_ sender: Any) {

        guard let presentingVC = self.presentingViewController else {
            self.dismiss(animated: true)
            return
        }

        self.dismiss(animated: false) {

            if let popup = presentingVC as? DraggablePopupViewController {
                popup.dismissPopup()
            } else if let popup = presentingVC.parent as? DraggablePopupViewController {
                popup.dismissPopup()
            } else {
                presentingVC.dismiss(animated: true)
            }
        }
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)

    }

}

// MARK: - Success View Controllers

class CategoryAddSuccess: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}

class SubCategorySuccess: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
        }
    }
}
