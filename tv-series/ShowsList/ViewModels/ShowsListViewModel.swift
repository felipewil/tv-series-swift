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
        self.setupNotifications()
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
        if self.mode == .search {
            return self.searchResults[index]
        }
        
        return self.showsManager.shows[index]
    }
    
    /// Returns array of all show's IDs.
    func showsIDs() -> [ Show.ID ] {
        return self.showsManager.shows.ids()
    }
    
    /// Number of loaded shows.
    func numberOfShows() -> Int {
        return self.showsManager.shows.count
    }
    
    /// Whether there are more shows to be loaded.
    func hasMoreShows() -> Bool {
        return self.showsManager.hasMore
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

    /// User started to search.
    func searchStarted() {
        guard self.mode == .list else { return }
        self.mode = .search
        self.eventSubject.send(.showsSearched)
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
    
    // MARK: Helpers
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .showFavoriteToggled)
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] notification in
                guard let id = notification.userInfo?["id"] as? Int else { return }
                
                self?.eventSubject.send(.reloadShow(id: id))
            }
            .store(in: &self.cancellables)
    }

}
