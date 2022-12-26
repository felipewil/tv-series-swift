//
//  PinViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation

struct PinViewModel {

    // MARK: Properties
    
    let pinHelper: PinHelper
    let isSetup: Bool

    // MARK: Initialization

    init(isSetup: Bool, pinHelper: PinHelper = PinHelper()) {
        self.isSetup = isSetup
        self.pinHelper = pinHelper
    }

    // MARK: Public method
    
    func isValidPin(_ code: String) -> Bool {
        return self.pinHelper.isValidPin(code)
    }
    
    /// Whether the given code matches the stored PIN.
    func pinMatches(_ code: String) -> Bool {
        return self.pinHelper.pinMatches(code)
    }
    
    /// Saves the given PIN.
    func savePin(_ code: String) {
        self.pinHelper.savePin(code)
    }

}
