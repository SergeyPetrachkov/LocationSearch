//
//  LocationSearchPreview.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import SwiftUI
import LocationSearchCore

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView(
            viewModel: LocationSearchViewModel(
                locationService: InternalGeocoder(),
                queryConstructor: SearchQueryConstructor()
            )
        )
    }
}
