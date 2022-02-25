//
//  LocationSearchViewModel.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import Combine

public final class LocationSearchViewModel: ObservableObject {

    // MARK: - Injectable properties

    private let locationService: LocationSearchProviding
    private let queryConstructor: LocationQueryConstructing

    public var onLocationSelected: ((LocationSearchResultItem) -> Void)?

    // MARK: - State

    public enum State {
        case loaded([LocationItemViewModel])
        case loading
        case failed(Error)
    }

    @Published private(set) var state: State
    @Published var currentSearchTerm: String = ""

    var locations: [LocationItemViewModel] {
        switch self.state {
        case .loaded(let locations):
            return locations
        case .loading:
            return []
        case .failed(_):
            return []
        }
    }

    // MARK: - Combine internals

    private var cancellable: AnyCancellable?
    private var searchOperation: AnyCancellable?

    // MARK: - Initializer

    public init(
        initialState: State = .loaded([]),
        locationService: LocationSearchProviding,
        queryConstructor: LocationQueryConstructing) {
        self.state = initialState
        self.locationService = locationService
        self.queryConstructor = queryConstructor
        self.cancellable = $currentSearchTerm
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main).sink { [weak self] value in
                guard let self = self else {
                    return
                }
                if value.count < 3 {
                    self.searchOperation?.cancel()
                    self.state = .loaded([])
                } else {
                    self.state = .loading
                    self.searchOperation?.cancel()
                    self.search(term: value)
                }
            }
    }

    // MARK: - Interface

    func select(item: LocationItemViewModel) {
        onLocationSelected?(item.model)
    }

    // MARK: - Private

    private func search(term: String) {
        searchOperation = locationService
            .search(query: queryConstructor.request(from: term))
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return
                    }
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.state = .failed(error)
                    }
                },
                receiveValue: { [weak self] values in
                    guard let self = self else {
                        return
                    }
                    let mappedResults = self.map(values)
                    self.state = .loaded(mappedResults)
                }
            )
    }

    private func map(_ geocodingResults: [LocationSearchResultItem]) -> [LocationItemViewModel] {
        geocodingResults.map { LocationItemViewModel(model: $0) }
    }
}
