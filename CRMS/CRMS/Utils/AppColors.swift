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
}
