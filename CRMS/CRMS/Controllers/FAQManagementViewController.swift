//
//  FAQManagementViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

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
