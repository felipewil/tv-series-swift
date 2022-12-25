//
//  ShowCellViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import Foundation
import Combine
import UIKit

struct ShowCellViewModel {

    // MARK: Properties
    
    private let showsManager: ShowsManager
    private let show: Show
    private(set) var canFavorite: Bool
    var name: String { self.show.name }
    var mediumImageUrl: String? { self.show.image?.medium }
    
    // MARK: Initializers

    init(show: Show, canFavorite: Bool = true, showsManager: ShowsManager = .shared) {
        self.show = show
        self.canFavorite = canFavorite
        self.showsManager = showsManager
    }
    
    // MARK: Public methods
    
    /// Whether this show is a favorite.
    func isFavorite() -> Bool {
        return self.showsManager.isFavorite(self.show)
    }

}
