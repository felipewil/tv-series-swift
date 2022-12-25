//
//  ShowsManager.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation
import Combine

class ShowsManager {

    // MARK: Properties
    
    static let shared = ShowsManager()
    
    private let urlSession: URLSession
    private let fileManager: FileManager
    
    var hasMore = true
    private var isLoading = false
    private var currentPage = 1
    private var cancellables: Set<AnyCancellable> = []
    private var searchCancellable: AnyCancellable?

    private(set) var shows: [ Show ] = []
    private(set) var favorites: Set<Show.ID> = []
    
    // MARK: Initialization
    
    private init(urlSession: URLSession = .shared, fileManager: FileManager = .default) {
        self.urlSession = urlSession
        self.fileManager = fileManager
        self.loadFavorites()
    }
    
    // MARK: Public methods

    /// Loads the next page of shows
    func loadNextPage(completion: @escaping () -> Void) {
        guard let url = Endpoint.Shows.index(page: self.currentPage).url else { return }

        self.isLoading = true

        self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ Show ].self, decoder: JSONDecoder())
            .catch { [ weak self ] error in
                self?.hasMore = false
                self?.isLoading = false
                
                completion()
                
                return Empty<[ Show ], Never>()
            }
            .sink { _ in } receiveValue: { [ weak self ] shows in
                guard let self else { return }

                self.handleShowResults(shows)
                self.isLoading = false
                self.hasMore = shows.count > 0
                self.currentPage += 1
                
                completion()
            }
            .store(in: &self.cancellables)
    }

    /// Toggles favorite status for the given show.
    func toggleFavorite(for show: Show) {
        if self.favorites.contains(show.id) {
            self.removeFromFavorites(show)
        } else {
            self.addToFavorites(show)
        }
    }
    
    /// Adds the given show as favorite.
    func addToFavorites(_ show: Show) {
        self.favorites.insert(show.id)
        self.saveFavorites()

        guard self.shows.firstIndex(where: { $0.id == show.id }) == nil else { return }
        
        self.insertShow(show)
    }
    
    /// Removes the given show from favorites.
    func removeFromFavorites(_ show: Show) {
        self.favorites.remove(show.id)
        self.saveFavorites()
    }

    /// Whether the given show is a favorite.
    func isFavorite(_ show: Show) -> Bool {
        return self.favorites.contains(show.id)
    }

    /// Load all shows that are favorite, if not loaded before.
    func loadFavorites(completion: @escaping () -> Void) {
        let toLoad = self.favorites.filter { id in self.shows.first { $0.id == id } == nil }

        toLoad
            .publisher
            .compactMap { Endpoint.Shows.show(id: $0).url }
            .flatMap { self.urlSession.dataTaskPublisher(for: $0) }
            .map(\.data)
            .decode(type: Show.self, decoder: JSONDecoder())
            .catch { _ in Empty<Show, Never>() }
            .sink { _ in completion() } receiveValue: { [ weak self ] show in
                self?.insertShow(show)
            }
            .store(in: &self.cancellables)
    }
    
    /// Returns all favorite shows
    func favoriteShows() -> [ Show ] {
        return self.shows.filter { self.favorites.contains($0.id) }
    }
    
    /// Searchs shows with the given query.
    func searchShows(for query: String) -> AnyPublisher<[ SearchResult ], Never> {
        guard let url = Endpoint.Shows.search(query: query).url else {
            return Empty<[ SearchResult ], Never>().eraseToAnyPublisher()
        }

        return self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ SearchResult ].self, decoder: JSONDecoder())
            .catch { _ in Empty<[ SearchResult ], Never>() }
            .eraseToAnyPublisher()
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

    private func favoritesFilePath() -> URL {
        let path = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return path.appending(component: "favorites")
    }
    
    private func loadFavorites() {
        let url = self.favoritesFilePath()
        guard
            let data = try? Data(contentsOf: url),
            let archivedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Data else { return }
        
        self.favorites = Set((try? JSONDecoder().decode([ Show.ID ].self, from: archivedData)) ?? [])
    }
    
    private func saveFavorites() {
        guard
            let data = try? JSONEncoder().encode(self.favorites),
            let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) else {
            // Add error event
            return
        }
        
        let url = self.favoritesFilePath()
        try? archivedData.write(to: url)
    }
    
    private func insertShow(_ show: Show) {
        guard !self.shows.contains(show) else { return }

        let insertAt = self.positionToInsertShow(show)
        self.shows.insert(show, at: insertAt)
    }
    
    private func positionToInsertShow(_ show: Show) -> Int {
        var left = 0
        var right = self.shows.count - 1

        while left <= right {
            let mid = (left + right) / 2

            if self.shows[mid].id < show.id {
                left = mid + 1
            } else if self.shows[mid].id > show.id {
                right = mid - 1
            } else {
                return mid
            }
        }

        return left
    }

}
