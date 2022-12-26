//
//  ShowsManagerTests.swift
//  tv-seriesTests
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import Combine
import XCTest
@testable import tv_series

private class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // To check if this protocol can handle the given request.
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Here you return the canonical version of the request but most of the time you pass the orignal one.
        return request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            fatalError("Handler is unavailable.")
        }
      
        do {
            // 2. Call handler with received request and capture the tuple of response and data.
            let (response, data) = try handler(request)
      
            // 3. Send received response to the client.
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      
            if let data = data {
                // 4. Send received data to the client.
                client?.urlProtocol(self, didLoad: data)
            }
      
            // 5. Notify request has been finished.
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // 6. Notify received error.
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}

// MARK: -

class ShowsManagerTests: XCTestCase {

    private var urlSessionMock: URLSession!
    private var manager: ShowsManager!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [ URLProtocolMock.self ]
        self.urlSessionMock = URLSession.init(configuration: configuration)
        
        self.cancellables = []
        self.manager = ShowsManager(urlSession: self.urlSessionMock)
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolMock.requestHandler = nil
        
        self.cancellables = []
        self.manager.clearFavorites()
        self.manager = nil
    }

    func testLoadNextPage() {
        // Given
        URLProtocolMock.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "url.one")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let content = """
            [
                {
                    "id": 1,
                    "name": "Test 1",
                },
                {
                    "id": 2,
                    "name": "Test 2",
                }
            ]
            """
            
            return (response, content.data(using: .utf8)!)
        }

        let expectation = self.expectation(description: "Completion should be called")

        // When
        self.manager.loadNextPage {
            XCTAssertEqual(self.manager.shows.count, 2)
            XCTAssertEqual(self.manager.shows[0].id, 1)
            XCTAssertEqual(self.manager.shows[1].id, 2)
            
            expectation.fulfill()
        }
        
        // Then
        self.waitForExpectations(timeout: 2.0)
    }
    
    func testAddFavorites() {
        // Given
        let show = Show(id: 1, name: "Test")

        XCTAssertEqual(self.manager.favorites.count, 0)

        // When
        self.manager.addToFavorites(show)
        
        // Then
        XCTAssertEqual(self.manager.favorites.count, 1)
        XCTAssertTrue(self.manager.favorites.contains(show.id))
    }
    
    func testAddFavoritesShouldAddItToShowsIfNotThereBefore() {
        // Given
        let show = Show(id: 1, name: "Test")

        XCTAssertEqual(self.manager.favorites.count, 0)
        XCTAssertEqual(self.manager.shows.count, 0)

        // When
        self.manager.addToFavorites(show)
        
        // Then
        XCTAssertEqual(self.manager.favorites.count, 1)
        XCTAssertTrue(self.manager.favorites.contains(show.id))
        XCTAssertTrue(self.manager.shows.contains(show))
    }
    
    func testAddFavoritesShouldNotAddItToShowsIfThereBefore() {
        // Given
        URLProtocolMock.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "url.one")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let content = """
            [
                {
                    "id": 1,
                    "name": "Test 1",
                },
                {
                    "id": 2,
                    "name": "Test 2",
                }
            ]
            """
            
            return (response, content.data(using: .utf8)!)
        }

        let expectation = self.expectation(description: "Completion should be called")

        
        self.manager.loadNextPage {
            // When
            XCTAssertEqual(self.manager.favorites.count, 0)
            XCTAssertEqual(self.manager.shows.count, 2)
            
            let show = Show(id: 1, name: "Test")
            self.manager.addToFavorites(show)
            
            // Then
            XCTAssertEqual(self.manager.favorites.count, 1)
            XCTAssertEqual(self.manager.shows.count, 2)
            
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 2.0)
    }
    
    func testRemoveFromFavorites() {
        // Given
        let show = Show(id: 1, name: "Test")
        self.manager.addToFavorites(show)
        
        XCTAssertEqual(self.manager.favorites.count, 1)

        // When
        self.manager.removeFromFavorites(show)
        
        // Then
        XCTAssertEqual(self.manager.favorites.count, 0)
    }
    
    func testToggleFavorite() {
        // Given
        let show = Show(id: 1, name: "Test")
        
        XCTAssertEqual(self.manager.favorites.count, 0)

        // When
        self.manager.toggleFavorite(for: show)
        
        // Then
        XCTAssertEqual(self.manager.favorites.count, 1)
        XCTAssertTrue(self.manager.favorites.contains(show.id))
        
        // When
        self.manager.toggleFavorite(for: show)
        
        // Then
        XCTAssertEqual(self.manager.favorites.count, 0)
    }

}
