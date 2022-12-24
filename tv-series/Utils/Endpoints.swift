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
        
        var url: URL? {
            switch self {
            case .index(let page):
                let queryItem = URLQueryItem(name: "page", value: "\(page)")
                return baseUrl?.appending(component: "shows").appending(queryItems: [ queryItem ])
            }
        }
    }

}
