//
//  LocationSearchProvider.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import Combine

public protocol LocationQuery {
    var searchTerm: String { get set }
}

public protocol LocationSearchResultItem {
    var displayString: String { get }
}

public protocol LocationSearchProviding {
    func search(query: LocationQuery) -> AnyPublisher<[LocationSearchResultItem], Error>
}
