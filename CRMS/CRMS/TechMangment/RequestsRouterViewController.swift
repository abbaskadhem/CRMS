import UIKit
import SwiftUI

final class RequestsRouterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        routeToProperRequestsScreen()
    }

    private func routeToProperRequestsScreen() {
        Task {
            do {
                let role = try await SessionManager.shared.getUserType()

                await MainActor.run {
                    if role == UserType.servicer.rawValue {
                        let rootView = RequestsListView()
                        let host = UIHostingController(rootView: rootView)
                        self.embedChild(host)
                    } else {
                        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "RequestsViewController")
                        self.embedChild(vc)
                    }
                }
            } catch {
                // fallback to UIKit screen if session fails
                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Admin", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "RequestsViewController")
                    self.embedChild(vc)
                }
            }
        }
    }

    private func embedChild(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        child.didMove(toParent: self)
    }
}
