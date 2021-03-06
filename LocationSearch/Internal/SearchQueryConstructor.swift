//
//  SearchQueryConstructor.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import LocationSearchCore

struct SearchQueryConstructor: LocationQueryConstructing {
    func request(from searchString: String) -> LocationQuery {
        InternalGeocoder.Query(searchTerm: searchString)
    }
}
