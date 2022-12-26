//
//  Collection+Extensions.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation

extension Collection {

    /// Collection of IDs of all elements in the collection.
    func ids() -> [ Element.ID ] where Element : Identifiable {
        return self.map { $0.id }
    }

}
