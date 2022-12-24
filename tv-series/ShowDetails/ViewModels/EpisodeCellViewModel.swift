//
//  EpisodeCellViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation

struct EpisodeCellViewModel {

    // MARK: Properties
    
    private let episode: Episode
    var name: String { self.episode.name }
    var mediumImageUrl: String? { self.episode.image?.medium }
    var airdate: String? { self.episode.airdate }
    
    // MARK: Initialization
    
    init(episode: Episode) {
        self.episode = episode
    }

}
