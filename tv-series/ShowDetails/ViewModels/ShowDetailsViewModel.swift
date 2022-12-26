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
    case reloadFavorite
}

class ShowDetailsViewModel {
    
    // MARK: Properties
    
    let showsManager: ShowsManager
    let urlSession: URLSession
    let show: Show
    var name: String { self.show.name }
    private(set) var episodesBySeason: [ Int: [ Episode ] ] = [:]
    private(set) var selectedSeason = 1
    private let eventSubject = PassthroughSubject<ShowDetailsViewModelEvent, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    var eventPublisher: AnyPublisher<ShowDetailsViewModelEvent, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(show: Show, showsManager: ShowsManager = .shared, urlSession: URLSession = .shared) {
        self.show = show
        self.showsManager = showsManager
        self.urlSession = urlSession
        self.setupNotifications()
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
    
    /// Returns an `Episode` at the given index, in the selected season.
    func episode(at index: Int) -> Episode {
        let season = self.selectedSeason
        return self.episodesBySeason[season, default: []][index]
    }

    /// Returns an `Episode` with the given ID, in the selected season.
    func episode(withID id: Episode.ID) -> Episode? {
        let season = self.selectedSeason
        let eps = self.episodesBySeason[season, default: []]
        return eps.first { $0.id == id }
    }
    
    /// Returns all show's seasons.
    func seasons() -> [ Int ] {
        return self.episodesBySeason.map { $0.key }.sorted()
    }
    
    /// Informs that a season was selected.
    func seasonSelected(at index: Int) {
        self.selectedSeason = self.seasons()[index]
        self.eventSubject.send(.episodesUpdated)
    }
    
    /// Whether the show is favorite.
    func isFavorite() -> Bool {
        return self.showsManager.isFavorite(self.show)
    }
    
    /// Handle show's favorite status toggled.
    func favoriteToggled() {
        return self.showsManager.toggleFavorite(for: self.show)
    }
    
    // MARK: Helpers
    
    private func handleEpisodes(_ episodes: [ Episode ]) {
        episodes.forEach { ep in
            self.episodesBySeason[ep.season, default: []].append(ep)
        }
        self.selectedSeason = self.episodesBySeason.keys.min() ?? 1
    }
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .showFavoriteToggled)
            .sink { [ weak self ] notification in
                guard notification.userInfo?["id"] as? Int == self?.show.id else { return }
                self?.eventSubject.send(.reloadFavorite)
            }
            .store(in: &self.cancellables)
    }

}
