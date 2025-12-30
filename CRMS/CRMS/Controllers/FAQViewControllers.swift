//
//  FAQViewControllers.swift
//  CRMS
//
//  Merged FAQ-related view controllers
//

import UIKit

// MARK: - FAQ Management

class FAQManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let faqVC = sb.instantiateViewController(withIdentifier: "NewFAQViewController") as? NewFAQViewController else { return }

            self.navigationController?.pushViewController(faqVC, animated: true)
    }
    var faqList: [FAQ] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        Task{
            try await getData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task{
            try await getData()
        }
    }

    func getData() async throws{

        faqList = try await FaqController.shared.getFaqs()
        tableView.reloadData()
    }

}

extension FAQManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqList.count
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
        print(selectedItem.question)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
             withIdentifier: "FAQDetailsViewController"

         ) as! FAQDetailsViewController
        vc.answer = selectedItem.answer
        vc.question = selectedItem.question
        vc.id = selectedItem.id
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - FAQ Details

class FAQDetailsViewController: UIViewController {

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

    func showConfirmDelete() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConfirmDeleteViewController") as! ConfirmDeleteViewController

        vc.id = id

        vc.onDeleted = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }


    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


    @IBAction func deleteButtonAction(_ sender: Any) {
        showConfirmDelete()
    }

    func handleDelete() async throws {
        guard let id = id else { return }
        try await FaqController.shared.deleteFaq(withId: id)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFaqSegue"{
            let vc = segue.destination as! EditFAQViewController
            vc.id = id
            vc.question = question
            vc.answer = answer
        }
    }


}

// MARK: - New FAQ

class NewFAQViewController: UIViewController {

    @IBOutlet weak var answerTextView: InspectableTextView!
    @IBOutlet weak var questionTextView: InspectableTextView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func showAddConfirmationScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)

        let vc = sb.instantiateViewController(
            withIdentifier: "FAQConfirmationViewController"
        ) as! FAQConfirmationViewController

        vc.answer = answerTextView.text
        vc.question = questionTextView.text

        // --- ADD THIS BLOCK ---
        // When the confirmation screen finishes saving successfully, pop this view controller
        vc.onSaveSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        // ----------------------

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }



    @IBAction func cancelButtonAction(_ sender: Any) {
        view.endEditing(true)

            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "CancelAddingConfirmationViewController") as! CancelAddingConfirmationViewController

            // Set the closure here
            vc.onConfirmCancel = { [weak self] in
                // This code runs in the parent after the popup is gone
                self?.navigationController?.popViewController(animated: true)
            }

            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve

            self.present(vc, animated: true)
    }

    @IBAction func addButtonAction(_ sender: Any) {
        showAddConfirmationScreen()
    }




}

// MARK: - Edit FAQ

class EditFAQViewController: UIViewController {

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
        self.navigationController?.popViewController(animated:true)
    }

    func showConfirmEditAlert() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "ConfirmEditAlertViewController"
        ) as! ConfirmEditAlertViewController

        vc.id = self.id
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

        Task {
            do {
                try await createFAQ()
                await MainActor.run { [weak self] in
                    self?.showSuccessAndCloseConfirmation()
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
        let newFaq = FAQ(id:UUID(),question: question ?? "", answer: answer ?? "" )
        try await FaqController.shared.addFaq(newFaq)
    }


    private func showSuccessAndCloseConfirmation() {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let successVC = sb.instantiateViewController(
                withIdentifier: "FAQSuccessViewController"
            ) as! FAQSuccessViewController

            successVC.modalPresentationStyle = .overFullScreen
            successVC.modalTransitionStyle = .crossDissolve

            // Capture the NewFAQViewController
            let presenter = self.presentingViewController

            dismiss(animated: false) {
                // Tell the parent the save was successful before showing success screen
                self.onSaveSuccess?()
                presenter?.present(successVC, animated: true)
            }
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

        Task {
            do {
                try await FaqController.shared.editFaq(faq: FAQ(id: id, question: q, answer: a))

                await MainActor.run { [weak self] in
                    self?.showSuccessAndClose()
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

    private func showSuccessAndClose() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let successVC = sb.instantiateViewController(
            withIdentifier: "FAQEditSuccessViewController"
        ) as! FAQEditSuccessViewController

        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve

        let presenter = presentingViewController

        dismiss(animated: false) {
            presenter?.present(successVC, animated: true)
        }
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
        print("cancel")
        dismiss(animated: true)
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        print("confirm")
        sender.isEnabled = false

        guard let id = id else {
            print("❌ Cannot delete: FAQ id is missing")
            sender.isEnabled = true
            return
        }

        Task {
            do {
                try await FaqController.shared.deleteFaq(withId: id)

                await MainActor.run { [weak self] in
                    self?.onDeleted?()
                    self?.showDeleteSuccessAndClose()
                }
            } catch {
                await MainActor.run { sender.isEnabled = true }
                print("Delete failed:", error)
            }
        }
    }

    private func showDeleteSuccessAndClose() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let raw = sb.instantiateViewController(withIdentifier: "DeleteSuccessViewController")
        print("Loaded type:", type(of: raw))

        let successVC = sb.instantiateViewController(
            withIdentifier: "DeleteSuccessViewController"
        ) as! DeleteSuccessViewController

        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve

        let presenter = presentingViewController

        dismiss(animated: false) {
            presenter?.present(successVC, animated: true)
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
        view.insertSubview(blur, at: 0)    }

    @IBAction func noButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func yesButtonTapped(_ sender: UIButton) {
        // Dismiss the popup first
                self.dismiss(animated: true) {
                    // After dismissal is complete, tell the parent to execute the code
                    self.onConfirmCancel?()
        }
    }
}

// MARK: - Success View Controllers

class FAQSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}

class FAQEditSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
}

class DeleteSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
        }
    }
}
