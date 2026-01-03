//
//  Untitled.swift
//  CRMS
//
//  Created by Zinab Zooba on 03/01/2026.
//

import UIKit

final class ServicerTabBarController: UITabBarController {

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

        // iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = AppColors.background
            appearance.shadowColor = .clear

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
