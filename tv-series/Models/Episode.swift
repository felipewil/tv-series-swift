//
//  Episode.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation

struct Episode: Codable {
    
    var id: Int
    var name: String
    var season: Int
    var airdate: String?

}
