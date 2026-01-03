//
//  AppColors.swift
//  CRMS
//
//  Centralized color definitions for the app
//

import UIKit

struct AppColors {
    // Text color - #0f1929
    static let text = UIColor(red: 15/255, green: 25/255, blue: 41/255, alpha: 1)

    // Background color - #F5EFEB
    static let background = UIColor(red: 245/255, green: 239/255, blue: 235/255, alpha: 1)

    // Primary color - #53697f
    static let primary = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)

    // Secondary color - #8aa7bc
    static let secondary = UIColor(red: 138/255, green: 167/255, blue: 188/255, alpha: 1)

    // Accent color - #53697f
    static let accent = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)

    // Additional utility colors
    static let inputBackground = UIColor.white
    static let inputBorder = UIColor(white: 0.85, alpha: 1)
    static let placeholder = UIColor.lightGray
    static let error = UIColor.systemRed

    // Status colors
    static let statusSubmitted = UIColor(red: 242/255, green: 219/255, blue: 139/255, alpha: 1)  // #F2DB8B
    static let statusAssigned = UIColor(red: 242/255, green: 219/255, blue: 139/255, alpha: 1)   // #F2DB8B
    static let statusInProgress = UIColor(red: 242/255, green: 219/255, blue: 139/255, alpha: 1) // #F2DB8B
    static let statusOnHold = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)      // #53697F
    static let statusDelayed = UIColor(red: 83/255, green: 105/255, blue: 127/255, alpha: 1)     // #53697F
    static let statusCancelled = UIColor(red: 214/255, green: 150/255, blue: 145/255, alpha: 1)  // #D69691
    static let statusCompleted = UIColor(red: 146/255, green: 217/255, blue: 153/255, alpha: 1)  // #92D999

    // Chart colors (for analytics visualizations)
    static let chartNeutralLight = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1) // #D9D9D9
    static let chartNeutralDark = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1)  // #CECECE
    static let chartContainerBackground = UIColor(red: 0.7, green: 0.8, blue: 0.85, alpha: 1.0)   // Light blue-grey

    // Tab bar colors
    static let tabBarUnselected = UIColor(red: 100/255, green: 110/255, blue: 120/255, alpha: 1) // Darker grey for visibility
}
