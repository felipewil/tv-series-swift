//
//  TabsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation
import UIKit

class TabsViewModel {

    // MARK: Properties
    
    let pinHelper: PinHelper
    @Published private(set) var isLocked = true
    
    // MARK: Initialization
    
    init(pinHelper: PinHelper = PinHelper()) {
        self.pinHelper = pinHelper
    }
    
    // MARK: Public methods
    
    /// Lock was unlocked.
    func checkIsLocked() {
        guard self.isLocked else { return }

        self.isLocked = self.pinHelper.isPinEnabled()
    }
    
    /// Lock was unlocked.
    func unlocked() {
        self.isLocked = false
    }
    
    /// Locks the `UIViewController` behind a PIN.
    func lock(viewControlelr: UIViewController) {
        self.pinHelper.lock(viewController: viewControlelr) { [ weak self ] status in
            self?.isLocked = status != .unlocked
        }
    }

}
