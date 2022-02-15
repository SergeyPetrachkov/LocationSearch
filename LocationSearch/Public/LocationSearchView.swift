//
//  ContentView.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import SwiftUI

public struct LocationSearchView: View {

    @ObservedObject private var viewModel: LocationSearchViewModel

    public init(viewModel: LocationSearchViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            List(viewModel.results) { item in
                Text(item.model.displayString)
                    .onTapGesture {
                        viewModel.select(item: item)
                    }
            }
            .navigationBarSearch(
                $viewModel.currentSearchTerm,
                placeholder: viewModel.uiConfig.placeholder,
                hidesNavigationBarDuringPresentation: viewModel.uiConfig.hidesNavigationBarDuringPresentation
            )
        }
    }
}

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
