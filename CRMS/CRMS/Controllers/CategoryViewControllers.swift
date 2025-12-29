//
//  CategoryViewControllers.swift
//  CRMS
//
//  Merged Category-related view controllers
//

import UIKit

// MARK: - Category Management

final class CategoryManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    var filteredCategories: [Category] = []
    var isSearching: Bool {
        return !searchBar.text!.isEmpty
    }
    var categories: [Category] = []
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
            categories = try await CategoryController.shared.getAllCategories()
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

        for category in categories {
            let action = UIAlertAction(title: category.name, style: .default) { [weak self] _ in
                self?.showAddSubPopup(categoryId: category.id)
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

    private func showAddSubPopup(categoryId: String) {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddSubCatogryViewController") as? AddSubCatogryViewController else { return }

            vc.targetCategoryId = categoryId

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
                withIdentifier: "AddCatogryViewController"
            ) as? AddCatogryViewController else { return }

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
        return isSearching ? filteredCategories.count : categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cat = categories[section]
        return cat.isExpanded ? (cat.subCategories.count + 1) : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = isSearching ? filteredCategories : categories
        let cat = dataSource[indexPath.section]

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.configure(with: cat.name, isExpanded: cat.isExpanded)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
        let idx = indexPath.row - 1
        let sub = cat.subCategories[idx]

        cell.configure(with: sub, isEditMode: isEditMode)

        cell.onToggleChanged = { [weak self] (isOn: Bool) in
            guard let self = self else { return }

            if let originalIndex = self.categories.firstIndex(where: { $0.id == cat.id }) {
                self.categories[originalIndex].subCategories[idx].isActive = isOn
            }

            Task {
                try? await CategoryController.shared.updateSubCategories(
                    categoryId: cat.id,
                    subCategories: cat.subCategories
                )
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 else { return }

        if isSearching {
            filteredCategories[indexPath.section].isExpanded.toggle()
        } else {
            categories[indexPath.section].isExpanded.toggle()
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

        containerView.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 0.85, alpha: 1.0)
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        nameLabel.font = UIFont.systemFont(ofSize: 15)
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

    func configure(with sub: SubCategory, isEditMode: Bool) {
        nameLabel.text = sub.name
        toggleSwitch.isOn = sub.isActive
        toggleSwitch.isHidden = !isEditMode
    }
}

extension CategoryManagementViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCategories = []
        } else {
            filteredCategories = categories.filter { category in
                let categoryMatch = category.name.lowercased().contains(searchText.lowercased())

                let subMatch = category.subCategories.contains { sub in
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

class AddCatogryViewController: UIViewController {

    var onCategoryAdded: (() -> Void)?

    @IBOutlet weak var nameTextView: InspectableTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {

        let name = nameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let sb = UIStoryboard(name: "Main", bundle: nil)
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

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CancelAddCategory") as! CancelAddCategory

          vc.modalPresentationStyle = .overFullScreen
          vc.modalTransitionStyle = .crossDissolve

          present(vc, animated: true)
    }

}

// MARK: - Add SubCategory

final class AddSubCatogryViewController: UIViewController {

    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!

    var targetCategoryId: String?
    var categories: [Category] = []

    private var selectedCategoryId: String?
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
                guard !subName.isEmpty, let categoryId = targetCategoryId else { return }

                sender.isEnabled = false
                let sub = SubCategory(name: subName, isActive: true)

                Task {
                    do {
                        try await CategoryController.shared.addSubCategory(categoryId: categoryId, subCategory: sub)
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
                try await CategoryController.shared.addCategory(name: name)

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
            let sb = UIStoryboard(name: "Main", bundle: nil)
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
