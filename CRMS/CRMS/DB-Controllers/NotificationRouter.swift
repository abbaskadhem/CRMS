//
//  NotificationRouter.swift
//  CRMS
//
//  Created by Reem Janahi on 03/01/2026.
//

import Foundation

import UIKit

enum NotificationRouter {

    // MARK: - Navigation helpers

    private static func pushNotificationDetails(
        notificationID: String,
        navigationController: UINavigationController?
    ) {
        guard let navigationController else { return }

        let storyboard = UIStoryboard(name: "Notifications", bundle: nil)

        guard let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "NotifDetailViewController"
        ) as? NotifDetailViewController else {
            return
        }

        detailsVC.notificationID = notificationID

        navigationController.popToRootViewController(animated: false)
        navigationController.pushViewController(detailsVC, animated: true)
    }

    static func openNotification(id: String) {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow }),
            let nav = window.rootViewController as? UINavigationController
        else { return }

        pushNotificationDetails(notificationID: id, navigationController: nav)
    }

   
}
