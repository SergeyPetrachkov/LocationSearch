//
//  LocationItemViewModel.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import SwiftUI

public struct LocationItemViewModel: Identifiable {
    public var id: String {
        model.displayString
    }

    let model: LocationSearchResultItem
}
