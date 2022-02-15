//
//  LocationSearchViewModel.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import Combine

public final class LocationSearchViewModel: ObservableObject {

    public struct Configurator {
        public let placeholder: String
        public let hidesNavigationBarDuringPresentation: Bool

        public init(placeholder: String, hidesNavigationBarDuringPresentation: Bool) {
            self.placeholder = placeholder
            self.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation
        }

        public static func `default`() -> Self {
            .init(placeholder: "Search location", hidesNavigationBarDuringPresentation: true)
        }
    }

    @Published private(set) var results: [LocationItemViewModel] = []
    @Published var currentSearchTerm: String = ""

    private var cancellable: AnyCancellable?
    private var searchOperation: AnyCancellable?

    private let locationService: LocationSearchProviding
    let uiConfig: Configurator

    public init(uiConfig: Configurator = .default(), locationService: LocationSearchProviding) {
        self.uiConfig = uiConfig
        self.locationService = locationService
        self.cancellable = $currentSearchTerm
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main).sink { value in
                if value.count < 3 {
                    self.results = []
                    self.searchOperation?.cancel()
                }
                else {
                    self.searchOperation?.cancel()
                    self.search(term: value)
                }
            }
    }

    func select(item: LocationItemViewModel) {
        print("Selected \(item)")
    }

    private func search(term: String) {
        searchOperation = locationService
            .search(query: InternalGeocoder.Query(searchTerm: term))
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return
                    }
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.results.removeAll()
                    }
                },
                receiveValue: { [weak self] values in
                    guard let self = self else {
                        return
                    }
                    self.results = self.map(values)
                }
            )
    }

    private func map(_ geocodingResults: [LocationSearchResultItem]) -> [LocationItemViewModel] {
        geocodingResults.map { LocationItemViewModel(model: $0) }
    }
}
