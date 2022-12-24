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
    var genres: [ String ]? { self.show.genres }
    var mediumImageUrl: String? { self.show.image?.medium }
    var time: String? { self.show.schedule?.time }
    var days: [ String ]? { self.show.schedule?.days }
    var summary: String? { self.show.summary }
    
    // MARK: Initialization
    
    init(show: Show) {
        self.show = show
    }

}
