//
//  LocationItemViewModel.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import SwiftUI

public struct LocationItemViewModel: Identifiable, Hashable {
    public var id: Int {
        hashValue
    }

    let model: LocationSearchResultItem

    public func hash(into hasher: inout Hasher) {
        hasher.combine(model.latitude)
        hasher.combine(model.longitude)
    }

    public static func == (lhs: LocationItemViewModel, rhs: LocationItemViewModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
