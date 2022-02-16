//
//  LocationQueryConstructor.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation

public protocol LocationQueryConstructing {
    func request(from searchString: String) -> LocationQuery
}
