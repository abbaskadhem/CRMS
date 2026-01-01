//
//  RequesterTabBarController.swift
//  CRMS
//
//  Tab bar controller for Requester role
//

import UIKit

final class RequesterTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
    }

    private func setupTabBarAppearance() {
        // Set tab bar background color
        tabBar.backgroundColor = AppColors.background
        tabBar.barTintColor = AppColors.background
        tabBar.tintColor = AppColors.primary
        tabBar.unselectedItemTintColor = AppColors.secondary

        // Remove top border line
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()

        // For iOS 15+, use UITabBarAppearance
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = AppColors.background
            appearance.shadowColor = .clear

            // Configure item appearance
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = AppColors.secondary
            itemAppearance.selected.iconColor = AppColors.primary

            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
