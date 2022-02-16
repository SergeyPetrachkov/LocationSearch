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
    var latitude: Double { get }
    var longitude: Double { get }
    var shortName: String? { get }
    var locality: String? { get }
    var administrativeArea: String? { get }
    var country: String? { get }
    var countryCode: String? { get }
}

public protocol LocationSearchProviding {
    func search(query: LocationQuery) -> AnyPublisher<[LocationSearchResultItem], Error>
}
