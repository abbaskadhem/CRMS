import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SettingsViewController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource {

    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Switches
    private let notificationSwitch = UISwitch()
    private let appearanceSwitch = UISwitch()

    // MARK: - UserDefaults
    private let notificationsKey = "notificationsEnabled"
    private let darkModeKey = "darkModeEnabled"

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - User Data
    private var fullName = ""
    private var email = ""
    private var roleText = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.background

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.contentInset = UIEdgeInsets(
            top: AppSpacing.lg,
            left: 0,
            bottom: AppSpacing.xl,
            right: 0
        )

        setupSwitches()
        fetchUserProfile()
        // Style labels
        nameLabel?.textColor = AppColors.text
        emailLabel?.textColor = AppColors.secondary

        // Style logout button
        logoutButton?.backgroundColor = AppColors.error
        logoutButton?.setTitleColor(.white, for: .normal)
        logoutButton?.layer.cornerRadius = AppSize.cornerRadius
    }

    // MARK: - Switch Setup
    private func setupSwitches() {
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: notificationsKey)
        appearanceSwitch.isOn = UserDefaults.standard.bool(forKey: darkModeKey)

        notificationSwitch.onTintColor = AppColors.secondary
        appearanceSwitch.onTintColor = AppColors.secondary

        notificationSwitch.addTarget(self,
                                     action: #selector(notificationSwitchChanged),
                                     for: .valueChanged)

        appearanceSwitch.addTarget(self,
                                   action: #selector(appearanceSwitchChanged),
                                   for: .valueChanged)

        applyInterfaceStyle(dark: appearanceSwitch.isOn)
    }

    // MARK: - Fetch Profile
    private func fetchUserProfile() {
        Task {
            do {
                guard await hasInternetConnection() else {
                    throw NetworkError.noInternet
                }

                let uid = try SessionManager.shared.requireUserId()

                let snapshot = try await db
                    .collection("User")
                    .document(uid)
                    .getDocument()

                guard let data = snapshot.data() else { return }

                fullName = data["fullName"] as? String ?? ""
                email = data["email"] as? String ?? ""
                roleText = mapRole(from: data["type"] as? Int ?? -1)

                await MainActor.run {
                    self.tableView.reloadData()
                }

            } catch {
                print("Settings fetch error:", error.localizedDescription)
            }
        }
    }

    private func mapRole(from role: Int) -> String {
        switch role {
        case 1000: return "Admin"
        case 1001: return "Requester"
        case 1002: return "Servicer"
        default: return "Unknown"
        }
    }

    // MARK: - Sections
    func numberOfSections(in tableView: UITableView) -> Int { 4 }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        [1, 2, 2, 1][section]
    }

    // MARK: - Headers
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Profile"
        case 1: return "Preferences"
        case 2: return "Support"
        case 3: return "Logout"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = AppTypography.dynamicCaption2
            header.textLabel?.textColor = .secondaryLabel
        }
    }

    // MARK: - Cells
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell

        switch indexPath.section {

        // PROFILE
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath)
            configureProfileCell(cell)

        // PREFERENCES
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Preferences", for: indexPath)
            cell.textLabel?.font = AppTypography.body
            cell.textLabel?.textColor = AppColors.text

            if indexPath.row == 0 {
                cell.textLabel?.text = "Notifications"
                cell.imageView?.image = UIImage(systemName: "bell")
                cell.accessoryView = notificationSwitch
            } else {
                cell.textLabel?.text = "Dark / Light Mode"
                cell.imageView?.image = UIImage(systemName: "moon")
                cell.accessoryView = appearanceSwitch
            }

        // SUPPORT
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SupportInfo", for: indexPath)
            cell.textLabel?.text = indexPath.row == 0 ? "About App" : "FAQ"
            cell.textLabel?.font = AppTypography.body
            cell.imageView?.image = UIImage(systemName:
                indexPath.row == 0 ? "info.circle" : "questionmark.circle")
            cell.accessoryType = .disclosureIndicator

        // LOGOUT
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            cell.textLabel?.text = "Logout"
            cell.textLabel?.font = AppTypography.headline
            cell.imageView?.image = UIImage(systemName: "arrow.backward.square")
            cell.selectionStyle = .default   

        default:
            cell = UITableViewCell()
        }

        styleCell(cell)
        applyRoundedCorners(to: cell, at: indexPath)
        return cell
    }

    // MARK: - Profile Cell
    private func configureProfileCell(_ cell: UITableViewCell) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .white
        imageView.backgroundColor = .systemGray2
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = fullName
        nameLabel.font = AppTypography.dynamicTitle3
        nameLabel.textColor = AppColors.text

        let emailLabel = UILabel()
        emailLabel.text = email
        emailLabel.font = AppTypography.dynamicSubheadline
        emailLabel.textColor = .secondaryLabel

        let roleLabel = UILabel()
        roleLabel.text = roleText
        roleLabel.font = AppTypography.dynamicCaption1
        roleLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [nameLabel, emailLabel, roleLabel])
        stack.axis = .vertical
        stack.spacing = AppSpacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: AppSpacing.lg),
            imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            stack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: AppSpacing.lg),
            stack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -AppSpacing.lg),
            stack.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
    }

    // MARK: - Selection
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 3 {
            showLogoutPopup()
        }
    }

    // MARK: - Heights & Spacing
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 140 }
        if indexPath.section == 3 { return 70 }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        AppSpacing.xl
    }

    // MARK: - Styling
    private func styleCell(_ cell: UITableViewCell) {
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        let bg = UIView()
        bg.backgroundColor = AppColors.primary.withAlphaComponent(0.15)
        bg.layer.masksToBounds = true
        bg.isUserInteractionEnabled = false
        cell.backgroundView = bg

        cell.contentView.isUserInteractionEnabled = true
        cell.textLabel?.textColor = AppColors.text
        cell.imageView?.tintColor = AppColors.text
    }

    // MARK: - Toggles
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: notificationsKey)
    }

    @objc private func appearanceSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: darkModeKey)
        applyInterfaceStyle(dark: sender.isOn)
    }

    private func applyInterfaceStyle(dark: Bool) {
        let style: UIUserInterfaceStyle = dark ? .dark : .light
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }

    // MARK: - Logout
    private func showLogoutPopup() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("❌ Firebase sign out failed:", error.localizedDescription)
            return
        }

        navigateToLogin()
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    // MARK: - Rounded Corners
    private func applyRoundedCorners(to cell: UITableViewCell,
                                     at indexPath: IndexPath) {

        let rows = tableView.numberOfRows(inSection: indexPath.section)
        let radius = AppSize.cornerRadiusLarge

        cell.backgroundView?.layer.cornerRadius = 0
        cell.backgroundView?.layer.maskedCorners = []

        if rows == 1 {
            cell.backgroundView?.layer.cornerRadius = radius
            cell.backgroundView?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            cell.backgroundView?.layer.cornerRadius = radius
            cell.backgroundView?.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner
            ]
        } else if indexPath.row == rows - 1 {
            cell.backgroundView?.layer.cornerRadius = radius
            cell.backgroundView?.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
        }
    }
}
