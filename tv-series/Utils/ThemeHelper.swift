//
//  ThemeHelper.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import UIKit

enum Theme: String, CaseIterable {
    case system
    case dark
    case light
    
    var title: String {
        switch self {
        case .system: return "System default"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
}

struct ThemeHelper {
    
    private struct Consts {
        static let themeKey = "theme"
    }

    // MARK: Properties
    
    let userDefaults: UserDefaults

    // MARK: Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: Public method

    /// Sets the app theme.
    func setTheme(_ theme: Theme) {
        self.userDefaults.set(theme.rawValue, forKey: Consts.themeKey)
        NotificationCenter.default.post(name: .themeUpdated, object: nil)
    }
    
    /// Returns current theme.
    func currentTheme() -> Theme {
        guard let theme = self.userDefaults.string(forKey: Consts.themeKey) else {
            return .system
        }

        return Theme(rawValue: theme) ?? .system
    }

}

