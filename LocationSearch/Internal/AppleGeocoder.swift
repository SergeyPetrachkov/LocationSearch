//
//  AppleGeocoder.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import CoreLocation
import Combine

final class InternalGeocoder: LocationSearchProviding {

    struct LocationSearchResult: LocationSearchResultItem {
        var displayString: String
    }
    struct Query: LocationQuery {
        var searchTerm: String
    }

    private let geocoder = CLGeocoder()

    func search(query: LocationQuery) -> AnyPublisher<[LocationSearchResultItem], Error> {
        return geocoder
            .places(from: query.searchTerm)
            .map { locations in
                locations.map { LocationSearchResult(displayString: ($0.name ?? $0.locality) ?? "Failed decoding") }
            }
            .eraseToAnyPublisher()
    }
}

extension CLGeocoder {
    func places(from input: String) -> Future<[CLPlacemark], Error> {
        return Future() { promise in
            self.geocodeAddressString(input,
                                 in: nil,
                                 preferredLocale: Locale(identifier: "en_US")) { placemark, error in
                if let error = error {
                    return promise(.failure(error))
                } else {
                    return promise(.success(placemark ?? []))
                }
            }
        }
    }
}
