//
//  PeopleListViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import Combine

enum PeopleListEvent {
    case listUpdated
}

// MARK: -

private struct PeopleSearchResult: Codable {
    
    enum CodingKeys: String, CodingKey {
        case people = "person"
    }

    var people: People

}

// MARK: -

class PeopleListViewModel {
    
    // MARK: Properties
    
    private let urlSession: URLSession
    private(set) var people: [ People ] = []
    private var eventSubject = PassthroughSubject<PeopleListEvent, Never>()

    var cancellables: Set<AnyCancellable> = []

    @Published private(set) var isLoading = false

    var eventPublisher: AnyPublisher<PeopleListEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: Public methods
    
    /// Searchs people with the given query.
    func search(for query: String?) {
        guard
            let query,
            !query.isEmpty,
            let url = Endpoint.People.search(query: query).url else {

            self.people = []
            self.isLoading = false
            self.eventSubject.send(.listUpdated)

            return
        }

        self.isLoading = true
        self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ PeopleSearchResult ].self, decoder: JSONDecoder())
            .catch { _ in
                self.isLoading = false
                return Empty<[ PeopleSearchResult ], Never>()
            }
            .sink { [ weak self ] results in
                guard let self else { return }

                self.isLoading = false
                self.people = results.map { $0.people }
                self.eventSubject.send(.listUpdated)
            }
            .store(in: &self.cancellables)
    }

}
