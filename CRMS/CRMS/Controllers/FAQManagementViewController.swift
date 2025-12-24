//
//  FAQManagementViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class FAQManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let faqList: [FAQItem] = [
        FAQItem(
            question: "What is this app for?",
            answer: "This app allows students, faculty, and staff to report maintenance and repair issues across campus."
        ),
        FAQItem(
            question: "Who can use the app?",
            answer: "Anyone with a valid university email address can sign up and submit maintenance requests."
        ),
        FAQItem(
            question: "What if I submitted the wrong information?",
            answer: "You can edit or cancel your request before it's assigned to a technician."
        ),
        FAQItem(
            question: "Will I be notified when the issue is resolved?",
            answer: "Absolutely. You'll receive a push notification and email once the request is resolved."
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
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

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
