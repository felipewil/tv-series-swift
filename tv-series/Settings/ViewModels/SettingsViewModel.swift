//
//  SettingsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation

struct SettingsViewModel {

    enum Settings: Int, CaseIterable {
        case pin
        case appVersion
        
        var title: String {
            switch self {
            case .pin: return "PIN"
            case .appVersion:
                let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
                let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "0"
                return "App version: \(bundleVersion) (\(build))"
            }
        }

        var canSelect: Bool {
            switch self {
            case .pin: return true
            case .appVersion: return false
            }
        }

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

}
