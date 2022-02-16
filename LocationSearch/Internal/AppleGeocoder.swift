//
//  AppleGeocoder.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import LocationSearchCore
import Foundation
import CoreLocation
import Combine

final class InternalGeocoder: LocationSearchProviding {

    struct LocationSearchResult: LocationSearchResultItem {
        let latitude: Double
        let longitude: Double
        var displayString: String
        let shortName: String?
        let locality: String?
        let administrativeArea: String?
        let country: String?
        let countryCode: String?

        init?(_ place: CLPlacemark) {
            guard let placeCountry = place.country, let location = place.location else {
                return nil
            }

            let components = Set([place.name,
                              place.locality,
                              place.subAdministrativeArea,
                              place.administrativeArea,
                              place.country].compactMap { $0 })
            let longName = components.joined(separator: ", ")

            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            displayString = longName
            shortName = place.name
            locality = place.locality
            administrativeArea = place.administrativeArea
            country = placeCountry
            countryCode = place.isoCountryCode
        }
    }

    struct Query: LocationQuery {
        var searchTerm: String
    }

    private let geocoder = CLGeocoder()

    func search(query: LocationQuery) -> AnyPublisher<[LocationSearchResultItem], Error> {
        return geocoder
            .places(from: query.searchTerm)
            .map { locations in
                locations.compactMap { LocationSearchResult($0) }
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
