//
//  CastCredit.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation

struct EmbeddedShow: Codable {
    
    var show: Show

}

// MARK: -

struct CastCredit: Codable {

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
    
    var embedded: EmbeddedShow

}
