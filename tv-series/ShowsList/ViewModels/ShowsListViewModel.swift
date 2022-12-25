//
//  SeriesListViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import Foundation
import Combine

enum ShowsListEvent {
    case showsUpdated
    case showsSearched
    case reloadShow(id: Show.ID)
}

class ShowsListViewModel {

    private enum Mode {
        case list, search
    }
    
    // MARK: Properties
    
    private let showsManager: ShowsManager
    private var mode: Mode = .list

    private(set) var searchResults: [ Show ] = []
    private var eventSubject = PassthroughSubject<ShowsListEvent, Never>()

    var cancellables: Set<AnyCancellable> = []

    @Published private(set) var isLoading = false

    var eventPublisher: AnyPublisher<ShowsListEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(showsManager: ShowsManager = .shared) {
        self.showsManager = showsManager
    }
    
    // MARK: Public methods
    
    /// Loads the next page of shows
    func loadNextPage() {
        self.showsManager.loadNextPage { [ weak self ] in
            self?.eventSubject.send(.showsUpdated)
        }
    }
    
    /// Returns the show at the given index.
    func show(at index: Int) -> Show {
        return self.showsManager.shows[index]
    }
    
    /// Returns array of all show's IDs.
    func showsIDs() -> [ Show.ID ] {
        return self.showsManager.shows.map { $0.id }
    }
    
    /// Returns the show at the given index.
    func show(withID id: Show.ID) -> Show? {
        if self.mode == .search {
            return self.searchResults.first { $0.id == id }
        }
        
        return self.showsManager.shows.first { $0.id == id }
    }
    
    /// Number of loaded shows.
    func numberOfShows() -> Int {
        return self.showsManager.shows.count
    }
    
    /// Whether there are more shows to be loaded.
    func hasMoreShows() -> Bool {
        return self.showsManager.hasMore
    }
    
    /// Returns a search result at the given index.
    func searchResult(at index: Int) -> Show {
        return self.searchResults[index]
    }
    
    /// Searchs shows with the given query.
    func searchShows(for query: String?) {
        guard let query else { return }

        self.mode = .search
        
        self.showsManager.searchShows(for: query)
            .sink { [ weak self ] results in
                guard let self else { return }

                self.searchResults = results.map { $0.show }
                self.eventSubject.send(.showsSearched)
            }
            .store(in: &self.cancellables)
    }

    /// Search was cancelled, should exit search mode.
    func searchCancelled() {
        self.mode = .list
        self.eventSubject.send(.showsUpdated)
    }
    
    /// Show's favorite status changed at the given index.
    func showFavoritedChanged(at index: Int) {
        let show: Show

        if self.mode == .search {
            show = self.searchResults[index]
        } else {
            show = self.showsManager.shows[index]
        }

        self.showsManager.toggleFavorite(for: show)
        self.eventSubject.send(.reloadShow(id: show.id))
    }

}
