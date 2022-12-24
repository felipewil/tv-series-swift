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
}

class ShowsListViewModel {

    private enum Mode {
        case list, search
    }
    
    // MARK: Properties
    
    private let urlSession: URLSession
    private var mode: Mode = .list
    private var currentPage = 1
    private(set) var shows: [ Show ] = []
    private(set) var searchResults: [ Show ] = []
    private(set) var hasMore = true
    private var eventSubject = PassthroughSubject<ShowsListEvent, Never>()
    private var search = ""

    var cancellables: Set<AnyCancellable> = []
    var searchCancellable: AnyCancellable?

    @Published private(set) var isLoading = false
    @Published private(set) var isSearching = false

    var eventPublisher: AnyPublisher<ShowsListEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: Public methods
    
    /// Loads the next page of shows
    func loadNextPage() {
        guard let url = Endpoint.Shows.index(page: currentPage).url else { return }
        
        self.isLoading = true

        self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ Show ].self, decoder: JSONDecoder())
            .catch { [ weak self ] error in
                self?.hasMore = false
                self?.isLoading = false
                
                return Empty<[ Show ], Never>()
            }
            .sink { _ in } receiveValue: { [ weak self ] shows in
                guard let self else { return }

                self.handleShowResults(shows)
                self.isLoading = false
                self.hasMore = shows.count > 0
                self.currentPage += 1
                
                if self.currentPage == 3 {
                    self.currentPage = 999
                }

                self.eventSubject.send(.showsUpdated)
            }
            .store(in: &cancellables)
    }
    
    /// Returns the show at the given index.
    func show(at index: Int) -> Show {
        return self.shows[index]
    }
    
    /// Returns the show at the given index.
    func show(withID id: Show.ID) -> Show? {
        if self.mode == .search {
            return self.searchResults.first { $0.id == id }
        }
        
        return self.shows.first { $0.id == id }
    }
    
    /// Returns a search result at the given index.
    func searchResult(at index: Int) -> Show {
        return self.searchResults[index]
    }
    
    /// Searchs shows with the given query.
    func searchShows(for query: String?) {
        guard let query else { return }

        self.search = query
        self.mode = .search
        
        guard let url = Endpoint.Shows.search(query: self.search).url else { return }
        
        self.isSearching = true

        self.searchCancellable?.cancel()
        self.searchCancellable = self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ SearchResult ].self, decoder: JSONDecoder())
            .catch { [ weak self ] error in
                self?.isSearching = false
                
                return Empty<[ SearchResult ], Never>()
            }
            .sink { _ in } receiveValue: { [ weak self ] results in
                guard let self else { return }

                self.isSearching = false
                self.handleSearchResults(results)

                self.eventSubject.send(.showsSearched)
            }
    }
    
    func searchCancelled() {
        self.mode = .list
        self.search = ""
        self.eventSubject.send(.showsUpdated)
    }
    
    // MARK: Helpers

    private func handleShowResults(_ shows: [ Show ]) {
        shows.forEach { show in
            if let index = self.shows.firstIndex(of: show) {
                self.shows[index] = show
            } else {
                self.shows.append(show)
            }
        }
    }
    
    private func handleSearchResults(_ results: [ SearchResult ]) {
        self.searchResults = results.map { $0.show }
    }

}
