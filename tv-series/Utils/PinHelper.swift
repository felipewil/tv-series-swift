//
//  PinHelper.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation

struct PinHelper {
    
    private struct Consts {
        static let pinEnabledKey = "pinEnabled"
        static let pinKey = "pin"
        static let pinLength = 4
    }

    // MARK: Properties
    
    let userDefaults: UserDefaults
    let keychainHelper: KeychainHelper

    // MARK: Initialization

    init(userDefaults: UserDefaults = .standard, keychainHelper: KeychainHelper = KeychainHelper()) {
        self.userDefaults = userDefaults
        self.keychainHelper = keychainHelper
    }

    // MARK: Public method

    /// Sets the PIN enabled status.
    func setPinEnabled(_ isEnabled: Bool) {
        self.userDefaults.set(isEnabled, forKey: Consts.pinEnabledKey)
    }
    
    /// Whether PIN is enabled in the app.
    func isPinEnabled() -> Bool {
        return self.userDefaults.bool(forKey: Consts.pinEnabledKey)
    }

    /// Whether given code is a valid PIN.
    func isValidPin(_ code: String) -> Bool {
        return code.count == Consts.pinLength
    }
    
    /// Whether the given code matches the stored PIN.
    func pinMatches(_ code: String) -> Bool {
        guard let data = self.keychainHelper.read(service: Consts.pinKey) else { return false }
        
        return code == String(data: data, encoding: .utf8)
    }
    
    /// Saves the given PIN.
    func savePin(_ code: String) {
        guard let data = code.data(using: .utf8) else { return }
        self.keychainHelper.save(data, service: Consts.pinKey)
    }

}
