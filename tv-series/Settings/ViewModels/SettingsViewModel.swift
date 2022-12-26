//
//  SettingsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation
import Combine

enum SettingsEvent {
    case reload
}

class SettingsViewModel {

    enum Settings: Int, CaseIterable {
        case pin
        case theme
        case appVersion
        
        var title: String {
            switch self {
            case .pin: return "PIN"
            case .theme: return "Theme"
            case .appVersion:
                let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
                let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "0"
                return "App version: \(bundleVersion) (\(build))"
            }
        }
        
        var subtitle: String? {
            switch self {
            case .pin: return nil
            case .theme: return ThemeHelper().currentTheme().title
            case .appVersion: return nil
            }
        }

        var canSelect: Bool {
            switch self {
            case .pin: return true
            case .theme: return true
            case .appVersion: return false
            }
        }

    }
    
    // MARK: Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private let eventSubject = PassthroughSubject<SettingsEvent, Never>()
    
    var eventPublisher: AnyPublisher<SettingsEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initializations
    
    init() {
        self.setupNotifications()
    }

    // MARK: Public methods
    
    /// Returns all settings.
    func settings() -> [ Settings ] {
        return Settings.allCases
    }
    
    /// Returns the settings at the given index.
    func settings(at index: Int) -> Settings {
        return Settings.allCases[index]
    }

    // MARK: Helpers
    
    private func setupNotifications() {
        NotificationCenter.default
                .publisher(for: .themeUpdated)
                .sink { [ weak self ] _ in self?.eventSubject.send(.reload) }
                .store(in: &self.cancellables)
    }

}
