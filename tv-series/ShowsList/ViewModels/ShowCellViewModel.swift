//
//  ShowCellViewModel.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import Foundation
import Combine
import UIKit

struct ShowCellViewModel {

    // MARK: Properties
    
    private let urlSession: URLSession
    private let show: Show
    var name: String { self.show.name }
    var mediumImageUrl: String { self.show.image.medium }
    
    // MARK: Initializers

    init(show: Show, urlSession: URLSession = .shared) {
        self.show = show
        self.urlSession = urlSession
    }
    
    // MARK: Public methods
    
    func loadImage() -> AnyPublisher<(URL, UIImage?), Error> {
        guard let url = URL(string: self.mediumImageUrl) else { return Empty<(URL, UIImage?), Error>().eraseToAnyPublisher() }

        return self.urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .map { (url, UIImage(data: $0)) }
            .catch { error in Empty<(URL, UIImage?), Error>() }
            .eraseToAnyPublisher()
    }

}
