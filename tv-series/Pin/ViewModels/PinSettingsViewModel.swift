//
//  PinSettingsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation
import LocalAuthentication
import Combine

enum PinSettingsEvent {
    case setupPin
}

struct PinSettingsViewModel {
    
    private struct Consts {
        static let pinEnabledKey = "pinEnabled"
    }

    enum Options: Int, CaseIterable {
        case pin
        case fingerprint
        
        var title: String {
            switch self {
            case .pin: return "Enable PIN"
            case .fingerprint:
                let context = LAContext()

                if #available(iOS 11, *), context.biometryType == .faceID {
                    return "Use Face ID"
                }

                return "Use Touch ID"
            }
        }

    }
    
    // MARK: Properties

    private let pinHelper: PinHelper
    private(set) var options: [ Options ] = []
    private let eventSubject = PassthroughSubject<PinSettingsEvent, Never>()
    
    var eventPublisher: AnyPublisher<PinSettingsEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }

    // MARK: Initialization

    init(pinHelper: PinHelper = PinHelper()) {
        self.pinHelper = pinHelper
        self.prepareOptions()
    }
    
    // MARK: Public methods

    /// Whether PIN is enabled in the app.
    func isPinEnabled() -> Bool {
        return self.pinHelper.isPinEnabled()
    }

    /// Sets PIN enabled status.
    func pinEnabled(_ isEnabled: Bool) {
        if isEnabled {
            self.eventSubject.send(.setupPin)
        } else {
            self.pinHelper.setPinEnabled(isEnabled)
        }
    }
    
    /// Confirms PIN is enabled.
    func confirmPinEnabled() {
        self.pinHelper.setPinEnabled(true)
    }
    
    // MARK: Helpers
    
    private mutating func prepareOptions() {
        var options: [ Options ] = [ .pin ]
        
        if self.hasFingerprint() {
            options.append(.fingerprint)
        }
        
        self.options = options
    }
    
    private func hasFingerprint() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

}
