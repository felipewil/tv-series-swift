//
//  People.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation

struct People: Codable, Identifiable {

    typealias ID = Int

    var id: Int
    var name: String
    var image: Image?

}
