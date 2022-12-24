//
//  ShowDetailsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation

class ShowDetailsViewModel {
    
    // MARK: Properties
    
    let show: Show
    var name: String { self.show.name }
    
    // MARK: Initialization
    
    init(show: Show) {
        self.show = show
    }

}
