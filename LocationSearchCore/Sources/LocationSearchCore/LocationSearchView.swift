//
//  ContentView.swift
//  LocationSearch
//
//  Created by Sergey Petrachkov on 15/02/2022.
//

import SwiftUI

public protocol LocationSearchbarConfiguring {
    var placeholder: String { get }
    var hidesNavigationBarDuringPresentation: Bool { get }
    var font: UIFont? { get }
    var fontColor: UIColor? { get }
    var backgroundColor: UIColor? { get }
}

public struct LocationSearchView: View {

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

    private let uiConfig: Configurator
    @ObservedObject private var viewModel: LocationSearchViewModel

    public init(viewModel: LocationSearchViewModel, uiConfig: Configurator = .default()) {
        self.viewModel = viewModel
        self.uiConfig = uiConfig
    }

    public var body: some View {
        NavigationView {
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
//                .background(uiConfig.backgroundColor.map(Color.init))
            .navigationBarSearch($viewModel.currentSearchTerm,
                                 uiConfig: uiConfig)
            .navigationTitle(uiConfig.placeholder)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    var contentView: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .loaded(let locations):
                List(locations) { item in
                    Text(item.model.displayString)
                        .onTapGesture {
                            viewModel.select(item: item)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                Spacer()
            }
            Spacer()
        }
    }
}
