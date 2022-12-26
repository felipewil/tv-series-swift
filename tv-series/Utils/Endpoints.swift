//
//  Endpoints.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import Foundation

private let baseUrl = URL(string: "https://api.tvmaze.com/")

enum Endpoint {

    enum Shows {
        case index(page: Int)
        case show(id: Int)
        case search(query: String)
        case episodes(showId: Int)
        
        var url: URL? {
            switch self {
            case .index(let page):
                let queryItem = URLQueryItem(name: "page", value: "\(page)")
                return baseUrl?.appending(component: "shows").appending(queryItems: [ queryItem ])
            case .show(let id):
                return baseUrl?.appending(component: "shows/\(id)")
            case .search(let query):
                let queryItem = URLQueryItem(name: "q", value: query)
                return baseUrl?.appending(component: "search/shows").appending(queryItems: [ queryItem ])
            case .episodes(let showId):
                return baseUrl?.appending(component: "shows/\(showId)/episodes")
            }
        }
    }

    enum People {
        case index(page: Int)
        case people(id: Int)
        case search(query: String)
        case castcredits(id: Int)
        
        var url: URL? {
            switch self {
            case .index(let page):
                let queryItem = URLQueryItem(name: "page", value: "\(page)")
                return baseUrl?.appending(component: "people").appending(queryItems: [ queryItem ])
            case .people(let id):
                return baseUrl?.appending(component: "people/\(id)")
            case .search(let query):
                let queryItem = URLQueryItem(name: "q", value: query)
                return baseUrl?.appending(component: "search/people").appending(queryItems: [ queryItem ])
            case .castcredits(let id):
                let queryItem = URLQueryItem(name: "embed", value: "show")
                return baseUrl?.appending(component: "people/\(id)/castcredits").appending(queryItems: [ queryItem ])
            }
        }
    }
}
