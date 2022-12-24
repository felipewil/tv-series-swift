//
//  EpisodeDetailsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation
import Combine

class EpisodeDetailsViewModel {
    
    // MARK: Properties
    
    let episode: Episode
    var name: String { self.episode.name }
    var number: Int { self.episode.number }
    var season: Int { self.episode.season }
    var mediumImageUrl: String? { self.episode.image?.medium }
    var summary: String? { self.episode.summary }
    
    // MARK: Initialization
    
    init(episode: Episode) {
        self.episode = episode
    }

}
