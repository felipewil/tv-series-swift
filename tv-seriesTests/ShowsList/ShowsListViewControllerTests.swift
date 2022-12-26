//
//  ShowsListViewControllerTests.swift
//  tv-seriesTests
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import XCTest
@testable import tv_series

private class UINavigationControllerMock: UINavigationController {

    var pushViewControllerLastVC: UIViewController!
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.pushViewControllerLastVC = viewController
        super.pushViewController(viewController, animated: animated)
    }

}

// MARK: -

private class UISearchControllerMock: UISearchController {

    var isActiveStub = false
    override var isActive: Bool {
        get { isActiveStub }
        set {}
    }

}

// MARK: -

class ShowsListViewModelMock: ShowsListViewModel {

    var loadNextPageCalls = 0
    var loadNextPageHandler: (() -> Void)?
    override func loadNextPage() {
        self.loadNextPageCalls += 1
        self.loadNextPageHandler?()
    }

    var showsIDsMock: [ Show.ID ] = []
    override func showsIDs() -> [Show.ID] {
        return self.showsIDsMock
    }
    
    var searchShowsCalls = 0
    var searchShowsLastQuery: String!
    override func searchShows(for query: String?) {
        self.searchShowsCalls += 1
        self.searchShowsLastQuery = query
    }
    
    var searchCancelledCalls = 0
    override func searchCancelled() {
        self.searchCancelledCalls += 1
    }

    var numberOfShowsStub = 0
    override func numberOfShows() -> Int {
        return self.numberOfShowsStub
    }

    var showAtCalls = 0
    var showAtStub: Show!
    override func show(at index: Int) -> Show {
        self.showAtCalls += 1
        return self.showAtStub
    }

}

// MARK: -

class ShowsListViewControllerTests: XCTestCase {

    private var viewModelMock: ShowsListViewModelMock!
    private var vc: ShowsListViewController!

    override func setUp() {
        super.setUp()

        self.viewModelMock = ShowsListViewModelMock()
        self.vc = ShowsListViewController(viewModel: self.viewModelMock)
        self.vc.loadView()
    }
    
    override func tearDown() {
        super.tearDown()

        self.viewModelMock = nil
        self.vc = nil
    }

    func testViewDidLoadShould() {
        // Given
        let expectation = self.expectation(description: "")

        self.viewModelMock.loadNextPageHandler = {
            expectation.fulfill()
        }

        // When
        self.vc.viewDidLoad()
        
        // Then
        self.waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.viewModelMock.loadNextPageCalls, 1)
        }
    }

    func testUpdateSearchResultsWithActiveSearchControllerShouldForwardQueryToViewModel() {
        // Given
        let searchController = UISearchControllerMock()
        searchController.searchBar.text = "Query"
        searchController.isActiveStub = true
        
        // When
        self.vc.updateSearchResults(for: searchController)
        
        // Then
        XCTAssertEqual(self.viewModelMock.searchShowsCalls, 1)
        XCTAssertEqual(self.viewModelMock.searchShowsLastQuery, "Query")
        XCTAssertEqual(self.viewModelMock.searchCancelledCalls, 0)
    }
    
    func testUpdateSearchResultsWithInactiveSearchControllerShouldForwardToViewModel() {
        // Given
        let searchController = UISearchControllerMock()
        searchController.searchBar.text = "Query"
        searchController.isActiveStub = false
        
        // When
        self.vc.updateSearchResults(for: self.vc.searchController)

        // Then
        XCTAssertEqual(self.viewModelMock.searchCancelledCalls, 1)
        XCTAssertEqual(self.viewModelMock.searchShowsLastQuery, nil)
        XCTAssertEqual(self.viewModelMock.searchShowsCalls, 0)
    }
    
    func testDisplayCellShouldCallNextPageWhenCloseToEnd() {
        // Given
        let mockCell = UITableViewCell()
        self.viewModelMock.numberOfShowsStub = 20
        
        // When
        self.vc.tableView(self.vc.tableView,
                          willDisplay: mockCell,
                          forRowAt: IndexPath(row: 10, section: 0))
        
        // Then
        XCTAssertEqual(self.viewModelMock.loadNextPageCalls, 0)
        
        // When
        self.vc.tableView(self.vc.tableView,
                          willDisplay: mockCell,
                          forRowAt: IndexPath(row: 17, section: 0))
        
        // Then
        XCTAssertEqual(self.viewModelMock.loadNextPageCalls, 0)
        
        // When
        self.vc.tableView(self.vc.tableView,
                          willDisplay: mockCell,
                          forRowAt: IndexPath(row: 18, section: 0))
        
        // Then
        XCTAssertEqual(self.viewModelMock.loadNextPageCalls, 1)
    }
    
    func testDidSelectRowShouldPresentShowDetailsViewController() {
        // Given
        let navVC = UINavigationControllerMock(rootViewController: self.vc)
        self.viewModelMock.showAtStub = Show(id: 1, name: "Test")

        // When
        self.vc.tableView(self.vc.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        // Then
        XCTAssertEqual(self.viewModelMock.showAtCalls, 1)
        XCTAssertTrue(navVC.pushViewControllerLastVC is ShowDetailsViewController)
    }

}

