//
//  AppSpacing.swift
//  CRMS
//
//  Centralized spacing and sizing constants for consistent layouts across the app
//

import UIKit

/// Centralized spacing system for consistent padding, margins, and dimensions
struct AppSpacing {

    // MARK: - Base Spacing Values

    /// Extra small spacing - 4pt (tight spacing between related elements)
    static let xs: CGFloat = 4

    /// Small spacing - 8pt (spacing within components)
    static let sm: CGFloat = 8

    /// Medium spacing - 12pt (standard internal padding)
    static let md: CGFloat = 12

    /// Large spacing - 16pt (standard external margins, section spacing)
    static let lg: CGFloat = 16

    /// Extra large spacing - 24pt (major section separators)
    static let xl: CGFloat = 24

    /// Double extra large spacing - 32pt (screen edge margins, large gaps)
    static let xxl: CGFloat = 32

    // MARK: - Component Specific Spacing

    /// Standard content insets for table views and scroll views
    static let contentInsets = UIEdgeInsets(top: sm, left: lg, bottom: sm, right: lg)

    /// Standard padding for card-style views
    static let cardPadding = UIEdgeInsets(top: md, left: lg, bottom: md, right: lg)

    /// Standard padding for buttons
    static let buttonPadding = UIEdgeInsets(top: md, left: lg, bottom: md, right: lg)

    /// Standard padding for text fields
    static let textFieldPadding = UIEdgeInsets(top: md, left: md, bottom: md, right: md)
}

/// Centralized sizing constants for UI components
struct AppSize {

    // MARK: - Corner Radius

    /// Small corner radius - 4pt (badges, small buttons)
    static let cornerRadiusSmall: CGFloat = 4

    /// Standard corner radius - 8pt (cards, inputs, buttons)
    static let cornerRadius: CGFloat = 8

    /// Medium corner radius - 12pt (larger cards, modals)
    static let cornerRadiusMedium: CGFloat = 12

    /// Large corner radius - 16pt (sheets, large containers)
    static let cornerRadiusLarge: CGFloat = 16

    /// Extra large corner radius - 20pt (bottom sheets)
    static let cornerRadiusXL: CGFloat = 20

    // MARK: - Icon Sizes

    /// Small icon size - 16x16pt
    static let iconSmall: CGFloat = 16

    /// Standard icon size - 24x24pt
    static let icon: CGFloat = 24

    /// Large icon size - 32x32pt
    static let iconLarge: CGFloat = 32

    // MARK: - Touch Targets

    /// Minimum touch target size per Apple HIG - 44x44pt
    static let minTouchTarget: CGFloat = 44

    // MARK: - Component Heights

    /// Standard button height - 44pt (meets minimum touch target)
    static let buttonHeight: CGFloat = 44

    /// Standard text field height - 44pt
    static let textFieldHeight: CGFloat = 44

    /// Standard navigation bar height - 44pt
    static let navBarHeight: CGFloat = 44

    /// Standard tab bar height - 49pt
    static let tabBarHeight: CGFloat = 49

    /// Dropdown/picker row height - 44pt
    static let dropdownRowHeight: CGFloat = 44

    // MARK: - Image Sizes

    /// Thumbnail image size - 60x60pt
    static let thumbnailSmall: CGFloat = 60

    /// Standard thumbnail size - 80x80pt
    static let thumbnail: CGFloat = 80

    /// Large thumbnail size - 120x120pt
    static let thumbnailLarge: CGFloat = 120

    // MARK: - Status Indicator

    /// Status dot size - 8pt diameter
    static let statusDot: CGFloat = 8

    /// Badge size - 20pt diameter
    static let badge: CGFloat = 20

    // MARK: - Borders

    /// Standard border width - 1pt
    static let borderWidth: CGFloat = 1

    /// Thick border width - 2pt
    static let borderWidthThick: CGFloat = 2

    // MARK: - Shadows

    /// Standard shadow radius - 4pt
    static let shadowRadius: CGFloat = 4

    /// Standard shadow opacity - 0.1
    static let shadowOpacity: Float = 0.1

    /// Standard shadow offset
    static let shadowOffset = CGSize(width: 0, height: 2)
}

/// Animation duration constants
struct AppAnimation {

    /// Quick animation - 0.15s (micro-interactions)
    static let quick: TimeInterval = 0.15

    /// Standard animation - 0.25s (most transitions)
    static let standard: TimeInterval = 0.25

    /// Slow animation - 0.35s (complex transitions)
    static let slow: TimeInterval = 0.35

    /// Spring damping for bouncy animations
    static let springDamping: CGFloat = 0.8

    /// Initial spring velocity
    static let springVelocity: CGFloat = 0.5
}
