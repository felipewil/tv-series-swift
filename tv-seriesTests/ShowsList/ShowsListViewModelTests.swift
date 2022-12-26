//
//  ShowsListViewModelTests.swift
//  tv-seriesTests
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import Combine
import XCTest
@testable import tv_series

private class ShowsManagerMock: ShowsManager {

    var loadNextPageCalls = 0
    var loadNextPageCompletion: (() -> Void)?
    override func loadNextPage(completion: @escaping () -> Void) {
        self.loadNextPageCalls += 1
        self.loadNextPageCompletion = completion
    }

    var showsStub: [ Show ] = []
    override var shows: [Show] { self.showsStub }
    
    var searchShowsStub: [ Show ] = []
    var searchSubject = PassthroughSubject<[ SearchResult ], Never>()
    override func searchShows(for query: String) -> AnyPublisher<[SearchResult], Never> {
        return self.searchSubject.eraseToAnyPublisher()
    }

    var toggleFavoriteCalls = 0
    var toggleFavoriteLastShow: Show!
    override func toggleFavorite(for show: Show) {
        self.toggleFavoriteCalls += 1
        self.toggleFavoriteLastShow = show
    }

}

// MARK: -

class ShowsListViewModelTests: XCTestCase {

    private var showsManagerMock: ShowsManagerMock!
    private var viewModel: ShowsListViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        
        self.cancellables = []
        self.showsManagerMock = ShowsManagerMock()
        self.viewModel = ShowsListViewModel(showsManager: self.showsManagerMock)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.cancellables = []
        self.showsManagerMock = nil
        self.viewModel = nil
    }

    func testLoadNextPageShouldCallShowsManager() {
        // Given
        // Initial state
        
        // When
        self.viewModel.loadNextPage()
        
        // Then
        XCTAssertEqual(self.showsManagerMock.loadNextPageCalls, 1)
    }
    
    func testLoadNextPageCompletionShouldCallShowsManager() {
        // Given
        let expectation = self.expectation(description: "Event should be sent")

        self.viewModel.eventPublisher
            .sink { event in
                switch event {
                case .showsUpdated: break
                default: XCTFail("Wrong event sent")
                }

                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        self.viewModel.loadNextPage()

        // When
        self.showsManagerMock.loadNextPageCompletion?()
        
        // Then
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.showsManagerMock.loadNextPageCalls, 1)
        }
    }

    func testShowAtShouldUseShowsManager() {
        // Given
        self.showsManagerMock.showsStub = [
            Show(id: 1, name: "Test 1"),
            Show(id: 2, name: "Test 2")
        ]
        
        // Then
        XCTAssertEqual(self.viewModel.show(at: 0).id, 1)
        XCTAssertEqual(self.viewModel.show(at: 1).id, 2)
    }
    
    func testShowsAtInSearchModeShouldFindFromShowsManager() {
        // Given
        self.showsManagerMock.showsStub = [
            Show(id: 1, name: "Test 1"),
            Show(id: 2, name: "Test 2")
        ]

        self.viewModel.searchShows(for: "query")
        self.showsManagerMock.searchSubject.send([
            SearchResult(score: 1.0, show: Show(id: 3, name: "Test 3")),
            SearchResult(score: 1.0, show: Show(id: 4, name: "Test 4"))
        ])

        // Then
        XCTAssertEqual(self.viewModel.show(at: 0).id, 3)
        XCTAssertEqual(self.viewModel.show(at: 1).id, 4)
    }
    
    func testShowsIDsShouldReturnMappedIDsFromShowsManager() {
        // Given
        self.showsManagerMock.showsStub = [
            Show(id: 1, name: "Test 1"),
            Show(id: 2, name: "Test 2")
        ]
        
        // Then
        XCTAssertEqual(self.viewModel.showsIDs(), [ 1, 2 ])
    }
    
    func testSearchCancelledShouldReloadShows() {
        // Given
        let expectation = self.expectation(description: "Event should be sent")

        self.viewModel.eventPublisher
            .sink { event in
                switch event {
                case .showsUpdated: break
                default: XCTFail("Wrong event sent")
                }

                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.viewModel.searchCancelled()
        
        // Then
        self.waitForExpectations(timeout: 2.0)
    }
    
    func testShowFavoritedChangedShouldForwardToShowsManager() {
        // Given
        self.showsManagerMock.showsStub = [
            Show(id: 1, name: "Test 1"),
            Show(id: 2, name: "Test 2")
        ]

        // When
        self.viewModel.showFavoritedChanged(at: 1)
        
        // Then
        XCTAssertEqual(self.showsManagerMock.toggleFavoriteLastShow.id, 2)
    }
    
    func testShowFavoritedChangedShouldSendEvent() {
        // Given
        self.showsManagerMock.showsStub = [
            Show(id: 1, name: "Test 1"),
            Show(id: 2, name: "Test 2")
        ]
        
        let expectation = self.expectation(description: "Event should be sent")

        self.viewModel.eventPublisher
            .sink { event in
                switch event {
                case .reloadShow(let id):
                    XCTAssertEqual(id, 1)
                default: XCTFail("Wrong event sent")
                }

                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.viewModel.showFavoritedChanged(at: 0)
        
        // Then
        self.waitForExpectations(timeout: 2.0)
    }
    
    func testShowFavoriteToggledNotificationShouldSendEvent() {
        // Given
        let expectation = self.expectation(description: "Event should be sent")
        
        self.viewModel.eventPublisher
            .sink { event in
                switch event {
                case .reloadShow(let id): XCTAssertEqual(id, 1)
                default: XCTFail("Wrong event sent")
                }
                
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        // When
        NotificationCenter.default.post(name: .showFavoriteToggled, object: nil, userInfo: [ "id": 1 ])
        
        // Then
        self.waitForExpectations(timeout: 2.0)
    }

}
