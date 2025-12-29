//
//  AddCategoryViewController.swift
//  Inventory
//
//  Created by BP-36-201-11 on 25/12/2025.
//

import UIKit

class AddCategoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        // Example content
        let label = UILabel()
        label.text = "Add Category"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
print("Popover AddCategoryViewController!!")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
