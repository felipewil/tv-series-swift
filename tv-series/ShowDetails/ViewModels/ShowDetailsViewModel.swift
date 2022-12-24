//
//  ShowDetailsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation
import Combine

enum ShowDetailsViewModelEvent {
    case episodesUpdated
}

class ShowDetailsViewModel {
    
    // MARK: Properties
    
    let urlSession: URLSession
    let show: Show
    var name: String { self.show.name }
    private(set) var episodesBySeason: [ Int: [ Episode ] ] = [:]
    private let eventSubject = PassthroughSubject<ShowDetailsViewModelEvent, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var selectedSeason = 1
    
    var eventPublisher: AnyPublisher<ShowDetailsViewModelEvent, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(show: Show, urlSession: URLSession = .shared) {
        self.show = show
        self.urlSession = urlSession
    }
    
    // MARK: Public methods
    
    /// Loads all show's episodes.
    func loadEpisodes() {
        guard let url = Endpoint.Shows.episodes(showId: self.show.id).url else { return }
        
        self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ Episode ].self, decoder: JSONDecoder())
            .catch { _ in Empty<[ Episode ], Never>() }
            .sink { _ in } receiveValue: { episodes in
                self.handleEpisodes(episodes)
                self.eventSubject.send(.episodesUpdated)
            }
            .store(in: &cancellables)
    }
    
    func episode(at index: Int) -> Episode {
        let season = self.selectedSeason
        return self.episodesBySeason[season, default: []][index]
    }
    
    /// Returns all show's seasons.
    func seasons() -> [ Int ] {
        return self.episodesBySeason.map { $0.key }.sorted()
    }
    
    // MARK: Helpers
    
    private func handleEpisodes(_ episodes: [ Episode ]) {
        episodes.forEach { ep in
            self.episodesBySeason[ep.season, default: []].append(ep)
        }
    }

}
