//
//  Show.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import Foundation

struct ShowImage: Codable {
    
    var medium: String?
    var original: String?

}

// MARK: -

struct Show: Codable, Hashable, Identifiable {

    typealias ID = Int

    var id: Int
    var name: String
    var url: String
    var image: ShowImage?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Show, rhs: Show) -> Bool {
        return lhs.id == rhs.id
    }

}
