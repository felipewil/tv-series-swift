//
//  PeopleDetailsViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import Combine

enum PeopleDetailsViewModelEvent {
    case detailsUpdated
    case reloadShow(id: Int)
}

class PeopleDetailsViewModel {
    
    // MARK: Properties
    
    let showsManager: ShowsManager
    let urlSession: URLSession
    let people: People
    var name: String { self.people.name }
    private(set) var shows: [ Show ] = []
    private let eventSubject = PassthroughSubject<PeopleDetailsViewModelEvent, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    var eventPublisher: AnyPublisher<PeopleDetailsViewModelEvent, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    
    init(people: People,
         showsManager: ShowsManager = .shared,
         urlSession: URLSession = .shared) {
        self.people = people
        self.showsManager = showsManager
        self.urlSession = urlSession
        self.setupNotifications()
    }

    // MARK: Public methods

    /// Loads all cast credits.
    func loadCastCredits() {
        guard let url = Endpoint.People.castcredits(id: self.people.id).url else { return }
        
        self.urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ CastCredit ].self, decoder: JSONDecoder())
            .catch { _ in Empty<[ CastCredit ], Never>() }
            .sink { _ in } receiveValue: { [ weak self ] credits in
                self?.shows = Array(Set(credits.map { $0.embedded.show }))
                self?.eventSubject.send(.detailsUpdated)
            }
            .store(in: &cancellables)
    }
    
    /// Show's favorite status changed at the given index.
    func showFavoritedChanged(at index: Int) {
        let show = self.shows[index]
        self.showsManager.toggleFavorite(for: show)
        self.eventSubject.send(.reloadShow(id: show.id))
    }
    
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .showFavoriteToggle)
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] notification in
                guard let id = notification.userInfo?["id"] as? Int else { return }
                
                self?.eventSubject.send(.reloadShow(id: id))
            }
            .store(in: &self.cancellables)
    }

}

