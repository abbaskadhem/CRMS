//
//  AddSubCatogryViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

import UIKit

class AddSubCatogryViewController: UIViewController {

    @IBOutlet weak var dropDownView: DropDownView!
    override func viewDidLoad() {
        super.viewDidLoad()

        dropDownView.configure(
               title: "Select option",
               items: ["One", "Two", "Three"]
           )

           dropDownView.onSelect = { value in
               print("Selected:", value)
           }
    }
    

   
}
