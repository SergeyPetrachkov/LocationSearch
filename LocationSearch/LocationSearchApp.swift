//
//  LocationSearchApp.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import SwiftUI

@main
struct LocationSearchApp: App {

    var body: some Scene {
        WindowGroup {
            LocationSearchView(viewModel: LocationSearchViewModel(locationService: InternalGeocoder(), queryConstructor: SearchQueryConstructor()))
        }
    }
}
