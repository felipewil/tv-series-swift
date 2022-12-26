//
//  ThemeSettingsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import Combine

struct ThemeSettingsViewModel {
    
    private struct Consts {
        static let themeKey = "themeKey"
    }

    enum Options: Int, CaseIterable {
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
    
    // MARK: Properties

    private let themeHelper: ThemeHelper
    private(set) var options: [ Options ] = []
    private let eventSubject = PassthroughSubject<PinSettingsEvent, Never>()
    
    var eventPublisher: AnyPublisher<PinSettingsEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }

    // MARK: Initialization

    init(themeHelper: ThemeHelper = ThemeHelper()) {
        self.themeHelper = themeHelper
    }
    
    // MARK: Public methods

    /// Returns all themes.
    func allThemes() -> [ Theme ] {
        return Theme.allCases
    }

    /// Returns the app current theme.
    func currentTheme() -> Theme {
        return self.themeHelper.currentTheme()
    }

    /// Sets PIN enabled status.
    func themeSelected(at index: Int) {
        let theme = Theme.allCases[index]
        self.themeHelper.setTheme(theme)
    }
    
    /// Returns the theme at the given index.
    func theme(at index: Int) -> Theme {
        return Theme.allCases[index]
    }

    func isCurrentTheme(_ theme: Theme) -> Bool {
        return theme == self.themeHelper.currentTheme()
    }
}

