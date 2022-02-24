//
//  LocationSearchViewModel.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import Foundation
import Combine
import UIKit

public protocol LocationSearchbarConfiguring {
    var placeholder: String { get }
    var hidesNavigationBarDuringPresentation: Bool { get }
    var font: UIFont? { get }
    var fontColor: UIColor? { get }
    var backgroundColor: UIColor? { get }
}

public final class LocationSearchViewModel: ObservableObject {

    public struct Configurator: LocationSearchbarConfiguring {
        public let placeholder: String
        public let hidesNavigationBarDuringPresentation: Bool
        public let font: UIFont?
        public let fontColor: UIColor?
        public let backgroundColor: UIColor?

        public init(placeholder: String,
                    hidesNavigationBarDuringPresentation: Bool,
                    font: UIFont,
                    fontColor: UIColor,
                    backgroundColor: UIColor) {
            self.placeholder = placeholder
            self.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation
            self.font = font
            self.fontColor = fontColor
            self.backgroundColor = backgroundColor
        }

        public static func `default`() -> Self {
            .init(placeholder: "Search location",
                  hidesNavigationBarDuringPresentation: true,
                  font: .systemFont(ofSize: 16, weight: .medium),
                  fontColor: UIColor(red: 75.0 / 255.0, green: 90.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0),
                  backgroundColor: UIColor(red: 231.0 / 255.0, green: 234.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0))
        }
    }

    @Published private(set) var results: [LocationItemViewModel] = []
    @Published var currentSearchTerm: String = ""

    private var cancellable: AnyCancellable?
    private var searchOperation: AnyCancellable?

    private let locationService: LocationSearchProviding
    private let queryConstructor: LocationQueryConstructing
    let uiConfig: Configurator

    public var onLocationSelected: ((LocationSearchResultItem) -> Void)?

    public init(uiConfig: Configurator = .default(),
                locationService: LocationSearchProviding,
                queryConstructor: LocationQueryConstructing) {
        self.uiConfig = uiConfig
        self.locationService = locationService
        self.queryConstructor = queryConstructor
        self.cancellable = $currentSearchTerm
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main).sink { [weak self] value in
                guard let self = self else {
                    return
                }
                if value.count < 3 {
                    self.results = []
                    self.searchOperation?.cancel()
                } else {
                    self.searchOperation?.cancel()
                    self.search(term: value)
                }
            }
    }

    func select(item: LocationItemViewModel) {
        onLocationSelected?(item.model)
    }

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
