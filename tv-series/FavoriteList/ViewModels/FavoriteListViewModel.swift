//
//  FavoriteListViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation
import Combine

enum FavoriteListEvent {
    case loading
    case showsUpdated
}

class FavoriteListViewModel {
    
    // MARK: Properties
    
    private let showsManager: ShowsManager
    private var eventSubject = PassthroughSubject<FavoriteListEvent, Never>()
    private var search = ""
    private(set) var shows: [ Show ] = []

    var cancellables: Set<AnyCancellable> = []

    var eventPublisher: AnyPublisher<FavoriteListEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(showsManager: ShowsManager = .shared) {
        self.showsManager = showsManager
    }
    
    // MARK: Public methods
    
    /// Loads the next page of shows
    func loadFavorites() {
        if self.shows.count == 0 {
            self.eventSubject.send(.loading)
        }

        self.showsManager.loadFavorites { [ weak self ] in
            guard let self else { return }

            self.shows = self.showsManager.favoriteShows().sorted { $0.name < $1.name }
            self.eventSubject.send(.showsUpdated)
        }
    }

    /// Returns the show at the given index.
    func show(at index: Int) -> Show {
        return self.filteredShows()[index]
    }
    
    /// Returns array of all show's IDs.
    func showsIDs() -> [ Show.ID ] {
        return self.filteredShows().ids()
    }
    
    /// Returns the show at the given index.
    func show(withID id: Show.ID) -> Show? {
        return self.filteredShows().first { $0.id == id }
    }
    
    /// Number of loaded shows.
    func numberOfShows() -> Int {
        return self.filteredShows().count
    }
    
    /// Searchs shows with the given query.
    func searchShows(for query: String?) {
        self.search = query ?? ""
        self.eventSubject.send(.showsUpdated)
    }

    /// Search was cancelled, should exit search mode.
    func searchCancelled() {
        self.search = ""
        self.eventSubject.send(.showsUpdated)
    }
    
    /// Removes a show with given ID from favorites.
    func removeFavorite(withID id: Show.ID) {
        guard let index = self.shows.firstIndex(where: { $0.id == id }) else { return }
        
        let show = self.shows.remove(at: index)
        self.showsManager.removeFromFavorites(show)
        self.eventSubject.send(.showsUpdated)
    }

    // MARK: Helpers
    
    private func filteredShows() -> [ Show ] {
        guard !self.search.isEmpty else { return self.shows }
        
        return self.shows.filter(self.showMatchesSearch)
    }
    
    private func showMatchesSearch(_ show: Show) -> Bool {
        let name = show.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let search = self.search.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return name.contains(search)
    }

}

