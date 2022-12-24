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
}

class ShowsListViewModel {

    // MARK: Properties
    
    private let urlSession: URLSession
    private var currentPage = 1
    private(set) var shows: [ Show ] = []
    private(set) var hasMore = true
    private var eventSubject = PassthroughSubject<ShowsListEvent, Never>()
    @Published private(set) var isLoading = false
    var cancellables: Set<AnyCancellable> = []

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

                self.shows.append(contentsOf: shows)
                self.isLoading = false
                self.currentPage += 1

                self.eventSubject.send(.showsUpdated)
            }
            .store(in: &cancellables)
    }
    
    /// Returns the show at the given index.
    func show(at index: Int) -> Show {
        return self.shows[index]
    }

}
