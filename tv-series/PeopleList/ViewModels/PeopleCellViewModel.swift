//
//  PeopleCellViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//


import Foundation
import Combine
import UIKit

struct PeopleCellViewModel {

    // MARK: Properties
    
    private let people: People
    var name: String { self.people.name }
    var mediumImageUrl: String? { self.people.image?.medium }
    
    // MARK: Initializers

    init(people: People) {
        self.people = people
    }

}

