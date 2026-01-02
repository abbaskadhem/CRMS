//
//  AppTypography.swift
//  CRMS
//
//  Centralized typography definitions for consistent font usage across the app
//

import UIKit

/// Centralized typography system following Apple HIG with Dynamic Type support
struct AppTypography {

    // MARK: - Font Weights

    /// Standard font weights used throughout the app
    enum Weight {
        case regular
        case medium
        case semibold
        case bold

        var uiWeight: UIFont.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }

    // MARK: - Static Fonts (Fixed Size)

    /// Large title - 28pt bold (for main screen titles)
    static let largeTitle = UIFont.systemFont(ofSize: 28, weight: .bold)

    /// Title 1 - 22pt bold (for section headers)
    static let title1 = UIFont.systemFont(ofSize: 22, weight: .bold)

    /// Title 2 - 18pt semibold (for card titles, important labels)
    static let title2 = UIFont.systemFont(ofSize: 18, weight: .semibold)

    /// Title 3 - 16pt semibold (for smaller titles)
    static let title3 = UIFont.systemFont(ofSize: 16, weight: .semibold)

    /// Headline - 16pt semibold (for emphasized body text)
    static let headline = UIFont.systemFont(ofSize: 16, weight: .semibold)

    /// Body - 16pt regular (for main content text)
    static let body = UIFont.systemFont(ofSize: 16, weight: .regular)

    /// Callout - 14pt regular (for secondary content)
    static let callout = UIFont.systemFont(ofSize: 14, weight: .regular)

    /// Subheadline - 14pt regular (for supporting text)
    static let subheadline = UIFont.systemFont(ofSize: 14, weight: .regular)

    /// Footnote - 12pt regular (for timestamps, metadata)
    static let footnote = UIFont.systemFont(ofSize: 12, weight: .regular)

    /// Caption 1 - 11pt regular (for labels, badges)
    static let caption1 = UIFont.systemFont(ofSize: 11, weight: .regular)

    /// Caption 2 - 11pt medium (for emphasized captions)
    static let caption2 = UIFont.systemFont(ofSize: 11, weight: .medium)

    // MARK: - Dynamic Type Fonts (Accessibility Support)

    /// Returns a font that scales with user's Dynamic Type settings
    /// - Parameters:
    ///   - style: The text style to use for scaling
    ///   - weight: The font weight (optional, uses style default if nil)
    /// - Returns: A font that respects Dynamic Type settings
    static func scaledFont(for style: UIFont.TextStyle, weight: Weight? = nil) -> UIFont {
        let baseFont = UIFont.preferredFont(forTextStyle: style)

        if let weight = weight {
            let descriptor = baseFont.fontDescriptor.addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: weight.uiWeight]
            ])
            return UIFont(descriptor: descriptor, size: 0)
        }

        return baseFont
    }

    // MARK: - Convenience Dynamic Type Fonts

    /// Dynamic large title that scales with accessibility settings
    static var dynamicLargeTitle: UIFont {
        scaledFont(for: .largeTitle, weight: .bold)
    }

    /// Dynamic title 1 that scales with accessibility settings
    static var dynamicTitle1: UIFont {
        scaledFont(for: .title1, weight: .bold)
    }

    /// Dynamic title 2 that scales with accessibility settings
    static var dynamicTitle2: UIFont {
        scaledFont(for: .title2, weight: .semibold)
    }

    /// Dynamic title 3 that scales with accessibility settings
    static var dynamicTitle3: UIFont {
        scaledFont(for: .title3, weight: .semibold)
    }

    /// Dynamic headline that scales with accessibility settings
    static var dynamicHeadline: UIFont {
        scaledFont(for: .headline)
    }

    /// Dynamic body that scales with accessibility settings
    static var dynamicBody: UIFont {
        scaledFont(for: .body)
    }

    /// Dynamic callout that scales with accessibility settings
    static var dynamicCallout: UIFont {
        scaledFont(for: .callout)
    }

    /// Dynamic subheadline that scales with accessibility settings
    static var dynamicSubheadline: UIFont {
        scaledFont(for: .subheadline)
    }

    /// Dynamic footnote that scales with accessibility settings
    static var dynamicFootnote: UIFont {
        scaledFont(for: .footnote)
    }

    /// Dynamic caption 1 that scales with accessibility settings
    static var dynamicCaption1: UIFont {
        scaledFont(for: .caption1)
    }

    /// Dynamic caption 2 that scales with accessibility settings
    static var dynamicCaption2: UIFont {
        scaledFont(for: .caption2, weight: .medium)
    }
}
