//
//  RequestsViewController.swift
//  CRMS
//
//  Created by  on 23/12/2025.
//

import UIKit
import SwiftUI

final class TechRequestsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = RequestsListView()
        let host = UIHostingController(rootView: root)

        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        print("✅ TechRequestsViewController (SERVICER) LOADED")
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        host.didMove(toParent: self)
    }
}
