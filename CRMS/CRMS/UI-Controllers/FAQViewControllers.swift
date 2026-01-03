//
//  FAQViewControllers.swift
//  CRMS
//
//  Merged FAQ-related view controllers (push-or-present safe)
//

import UIKit

// MARK: - Helpers (Push-or-present + Pop-or-dismiss)

extension UIViewController {

    func showPushOrPresent(_ vc: UIViewController, animated: Bool = true) {
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: animated)
        } else {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: animated)
        }
    }

    func popOrDismiss(animated: Bool = true) {
        if let nav = self.navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated)
        }
    }
}

// MARK: - FAQ Management

final class FAQManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var faqList: [FAQ] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self

        Task { try await getData() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { try await getData() }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        popOrDismiss(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NewFAQViewController") as! NewFAQViewController
        showPushOrPresent(vc, animated: true)
    }

    func getData() async throws {
        faqList = try await FaqController.shared.getFaqs()
        tableView.reloadData()
    }
}

extension FAQManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        faqList.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FAQManagementTableViewCell",
            for: indexPath
        ) as! FAQManagementTableViewCell

        let item = faqList[indexPath.row]
        cell.configure(with: item)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let selectedItem = faqList[indexPath.row]
        print("selected:", selectedItem.answer)

        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FAQDetailsViewController") as! FAQDetailsViewController

        vc.answer = selectedItem.answer
        vc.question = selectedItem.question
        vc.id = selectedItem.id

        showPushOrPresent(vc, animated: true)
    }
}

// MARK: - FAQ Details

final class FAQDetailsViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!

    var id: UUID?
    var question: String?
    var answer: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answer
        questionLabel.text = question
    }

    @IBAction func backButtonAction(_ sender: Any) {
        popOrDismiss(animated: true)
    }

    @IBAction func deleteButtonAction(_ sender: Any) {
        showConfirmDelete()
    }

    private func showConfirmDelete() {
        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConfirmDeleteViewController") as! ConfirmDeleteViewController

        vc.id = id

        vc.onDeleted = { [weak self] in
            self?.popOrDismiss(animated: true)
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFaqSegue" {
            let vc = segue.destination as! EditFAQViewController
            vc.id = id
            vc.question = question
            vc.answer = answer
        }
    }
}

// MARK: - New FAQ

final class NewFAQViewController: UIViewController {

    @IBOutlet weak var answerTextView: InspectableTextView!
    @IBOutlet weak var questionTextView: InspectableTextView!

    @IBAction func cancelButtonAction(_ sender: Any) {
        view.endEditing(true)

        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CancelAddingConfirmationViewController") as! CancelAddingConfirmationViewController

        vc.onConfirmCancel = { [weak self] in
            self?.popOrDismiss(animated: true)
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    @IBAction func addButtonAction(_ sender: Any) {
        showAddConfirmationScreen()
    }

    private func showAddConfirmationScreen() {
        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FAQConfirmationViewController") as! FAQConfirmationViewController

        vc.answer = answerTextView.text
        vc.question = questionTextView.text

        vc.onSaveSuccess = { [weak self] in
            self?.popOrDismiss(animated: true)
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        popOrDismiss(animated: true)
    }
}

// MARK: - Edit FAQ

final class EditFAQViewController: UIViewController {

    @IBOutlet weak var questionTextView: InspectableTextView!
    @IBOutlet weak var answerTextView: InspectableTextView!

    var id: UUID?
    var question: String?
    var answer: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        questionTextView.text = question
        answerTextView.text = answer
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        showConfirmEditAlert()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }


    private func showConfirmEditAlert() {
        let sb = UIStoryboard(name: "Faq", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConfirmEditAlertViewController") as! ConfirmEditAlertViewController

        vc.id = id
        vc.question = questionTextView.text
        vc.answer = answerTextView.text

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}

// MARK: - FAQ Confirmation (Add)

final class FAQConfirmationViewController: UIViewController {

    var question: String?
    var answer: String?

    var onSaveSuccess: (() -> Void)?

    @IBOutlet weak var yesButton: UIButton?
    @IBOutlet weak var noButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    @IBAction func yesTapped(_ sender: Any) {
        yesButton?.isEnabled = false
        noButton?.isEnabled = false

        let presenter = self.presentingViewController

        Task {
            do {
                try await createFAQ()

                await MainActor.run { [weak self] in
                    guard let self else { return }

                    self.dismiss(animated: false) {
                        self.onSaveSuccess?()

                        let sb = UIStoryboard(name: "Faq", bundle: nil)
                        let successVC = sb.instantiateViewController(withIdentifier: "FAQSuccessViewController") as! FAQSuccessViewController
                        successVC.modalPresentationStyle = .overFullScreen
                        successVC.modalTransitionStyle = .crossDissolve
                        presenter?.present(successVC, animated: true)
                    }
                }

            } catch {
                await MainActor.run { [weak self] in
                    self?.yesButton?.isEnabled = true
                    self?.noButton?.isEnabled = true
                }
                print("Failed to create FAQ:", error)
            }
        }
    }

    @IBAction func noTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    private func createFAQ() async throws {
        let newFaq = FAQ(id: UUID(), question: question ?? "", answer: answer ?? "")
        try await FaqController.shared.addFaq(newFaq)
    }
}

// MARK: - Confirm Edit Alert

final class ConfirmEditAlertViewController: UIViewController {

    var id: UUID?
    var question: String?
    var answer: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    @IBAction func saveButton(_ sender: UIButton) {
        sender.isEnabled = false

        guard let id = id else {
            sender.isEnabled = true
            return
        }

        let q = question ?? ""
        let a = answer ?? ""

        let presenter = self.presentingViewController

        Task {
            do {
                try await FaqController.shared.editFaq(faq: FAQ(id: id, question: q, answer: a))

                await MainActor.run { [weak self] in
                    guard let self else { return }

                    self.dismiss(animated: false) {
                        let sb = UIStoryboard(name: "Faq", bundle: nil)
                        let successVC = sb.instantiateViewController(withIdentifier: "FAQEditSuccessViewController") as! FAQEditSuccessViewController
                        successVC.modalPresentationStyle = .overFullScreen
                        successVC.modalTransitionStyle = .crossDissolve
                        presenter?.present(successVC, animated: true)
                    }
                }

            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("Edit failed:", error)
            }
        }
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Confirm Delete

final class ConfirmDeleteViewController: UIViewController {

    var id: UUID?
    var onDeleted: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false

        guard let id = id else {
            print("❌ Cannot delete: FAQ id is missing")
            sender.isEnabled = true
            return
        }

        let presenter = self.presentingViewController

        Task {
            do {
                try await FaqController.shared.deleteFaq(withId: id)

                await MainActor.run { [weak self] in
                    guard let self else { return }

                    self.onDeleted?()

                    self.dismiss(animated: false) {
                        let sb = UIStoryboard(name: "Faq", bundle: nil)
                        let successVC = sb.instantiateViewController(withIdentifier: "DeleteSuccessViewController") as! DeleteSuccessViewController
                        successVC.modalPresentationStyle = .overFullScreen
                        successVC.modalTransitionStyle = .crossDissolve
                        presenter?.present(successVC, animated: true)
                    }
                }

            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("Delete failed:", error)
            }
        }
    }
}

// MARK: - Cancel Adding Confirmation

final class CancelAddingConfirmationViewController: UIViewController {

    var onConfirmCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = view.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blur, at: 0)
    }

    @IBAction func noButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func yesButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onConfirmCancel?()
        }
    }
}

// MARK: - Success View Controllers

final class FAQSuccessViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}

final class FAQEditSuccessViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}

final class DeleteSuccessViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}
