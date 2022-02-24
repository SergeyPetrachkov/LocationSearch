// Copyright © 2020 thislooksfun
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import SwiftUI
import Combine

public extension View {

    @available(iOS, introduced: 13.0, deprecated: 15.0, message: "Use .searchable() and .onSubmit(of:) instead.")
    @available(macCatalyst, introduced: 13.0, deprecated: 15.0, message: "Use .searchable() and .onSubmit(of:) instead.")
    func navigationBarSearch(_ searchText: Binding<String>,
                             uiConfig: LocationSearchbarConfiguring,
                             cancelClicked: @escaping () -> Void = {}, searchClicked: @escaping () -> Void = {}) -> some View {
        return overlay(SearchBar<AnyView>(text: searchText, uiConfig: uiConfig, cancelClicked: cancelClicked, searchClicked: searchClicked).frame(width: 0, height: 0))
    }
}

public struct SearchBarConfigurator {
    let text: String
    let placeholder: String?
    let hidesNavigationBarDuringPresentation: Bool
    let hidesSearchBarWhenScrolling: Bool
    let font: UIFont?
    let textColor: UIColor?
    let tintColor: UIColor?
    let placeholderColor: UIColor?
    let backgroundColor: UIColor?

    public init(text: String,
                placeholder: String?,
                hidesNavigationBarDuringPresentation: Bool,
                hidesSearchBarWhenScrolling: Bool,
                font: UIFont?,
                textColor: UIColor?,
                tintColor: UIColor?,
                placeholderColor: UIColor?,
                backgroundColor: UIColor?) {
        self.text = text
        self.placeholder = placeholder
        self.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation
        self.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
        self.font = font
        self.textColor = textColor
        self.tintColor = tintColor
        self.placeholderColor = placeholderColor
        self.backgroundColor = backgroundColor
    }
}

struct SearchBar<ResultContent: View>: UIViewControllerRepresentable {

    @Binding
    var text: String
    let placeholder: String?
    let hidesNavigationBarDuringPresentation: Bool
    let hidesSearchBarWhenScrolling: Bool
    let uiConfig: LocationSearchbarConfiguring
    let cancelClicked: () -> Void
    let searchClicked: () -> Void
    let resultContent: (String) -> ResultContent?

    init(text: Binding<String>,
         uiConfig: LocationSearchbarConfiguring,
         cancelClicked: @escaping () -> Void,
         searchClicked: @escaping () -> Void,
         @ViewBuilder resultContent: @escaping (String) -> ResultContent? = { _ in nil }) {
        self._text = text
        self.uiConfig = uiConfig
        self.placeholder = uiConfig.placeholder
        self.hidesNavigationBarDuringPresentation = uiConfig.hidesNavigationBarDuringPresentation
        self.hidesSearchBarWhenScrolling = false
        self.cancelClicked = cancelClicked
        self.searchClicked = searchClicked
        self.resultContent = resultContent
    }

    func makeUIViewController(context: Context) -> SearchBarWrapperController {
        return SearchBarWrapperController()
    }

    func updateUIViewController(_ controller: SearchBarWrapperController, context: Context) {
        controller.searchController = context.coordinator.searchController
        controller.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
        controller.searchController?.searchBar.autocapitalizationType = .none
        controller.searchController?.searchBar.barStyle = .default
        controller.searchController?.searchBar.tintColor = uiConfig.fontColor
        controller.searchController?.searchBar.barTintColor = .white
        controller.searchController?.searchBar.isTranslucent = false
        controller.searchController?.searchBar.showsCancelButton = true
        controller.searchController?.searchBar.searchTextField.font = uiConfig.font
        controller.searchController?.searchBar.searchTextField.backgroundColor = uiConfig.backgroundColor
        controller.searchController?.searchBar.searchTextField.tintColor = uiConfig.fontColor
        controller.searchController?.searchBar.searchTextField.textColor = uiConfig.fontColor
        controller.searchController?.searchBar.searchTextField.attributedPlaceholder = .init(string: uiConfig.placeholder,
                                                                                             attributes: [.font: uiConfig.font])
        controller.text = text

        context.coordinator.update(placeholder: placeholder, cancelClicked: cancelClicked, searchClicked: searchClicked)

        if let resultView = resultContent(text) {
            (controller.searchController?.searchResultsController as? UIHostingController<ResultContent>)?.rootView = resultView
        }
        controller.becomeFirstResponder()
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, placeholder: placeholder, hidesNavigationBarDuringPresentation: hidesNavigationBarDuringPresentation, resultContent: resultContent, cancelClicked: cancelClicked, searchClicked: searchClicked)
    }

    class Coordinator: NSObject, UISearchResultsUpdating, UISearchBarDelegate {
        @Binding
        var text: String
        var cancelClicked: () -> Void
        var searchClicked: () -> Void
        let searchController: UISearchController

        private var updatedText: String

        init(text: Binding<String>, placeholder: String?, hidesNavigationBarDuringPresentation: Bool, resultContent: (String) -> ResultContent?, cancelClicked: @escaping () -> Void, searchClicked: @escaping () -> Void) {
            self._text = text
            updatedText = text.wrappedValue
            self.cancelClicked = cancelClicked
            self.searchClicked = searchClicked

            let resultView = resultContent(text.wrappedValue)
            let searchResultController = resultView.map { UIHostingController(rootView: $0) }
            self.searchController = UISearchController(searchResultsController: searchResultController)

            super.init()

            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation
            searchController.obscuresBackgroundDuringPresentation = false

            searchController.searchBar.delegate = self
            searchController.searchBar.text = self.text
            searchController.searchBar.placeholder = placeholder
        }

        func update(placeholder: String?, cancelClicked: @escaping () -> Void, searchClicked: @escaping () -> Void) {
//            searchController.searchBar.placeholder = placeholder

            self.cancelClicked = cancelClicked
            self.searchClicked = searchClicked
        }

        // MARK: - UISearchResultsUpdating
        func updateSearchResults(for searchController: UISearchController) {
            guard let text = searchController.searchBar.text else { return }
            // Make sure the text has actually changed (workaround for #10).
            guard updatedText != text else { return }

            DispatchQueue.main.async {
                self.updatedText = text
                self.text = text
            }
        }

        // MARK: - UISearchBarDelegate
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.cancelClicked()
        }
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            self.searchClicked()
        }
    }

    class SearchBarWrapperController: UIViewController {

        var text: String? {
            didSet {
                self.parent?.navigationItem.searchController?.searchBar.text = text
            }
        }

        var searchController: UISearchController? {
            didSet {
                self.parent?.navigationItem.searchController = searchController
            }
        }

        var hidesSearchBarWhenScrolling: Bool = true {
            didSet {
                self.parent?.navigationItem.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
            }
        }
//
//        var font: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium) {
//            didSet {
//                self.parent?.navigationItem.searchController?.searchBar.searchTextField.font = font
//            }
//        }
//
//        var textColor: UIColor? {
//            didSet {
//                self.parent?.navigationItem.searchController?.searchBar.searchTextField.textColor = textColor
//            }
//        }
//
//        var backgroundColor: UIColor? {
//            didSet {
//                self.parent?.navigationItem.searchController?.searchBar.searchTextField.backgroundColor = backgroundColor
//            }
//        }
//
//        var tintColor: UIColor? {
//            didSet {
//                if let tintColor = tintColor {
//                    self.parent?.navigationItem.searchController?.searchBar.searchTextField.tintColor = tintColor
//                }
//            }
//        }

        override func viewWillAppear(_ animated: Bool) {
            setup()
        }
        override func viewDidAppear(_ animated: Bool) {
            setup()
        }

        private func setup() {
            self.parent?.navigationItem.searchController = searchController
            self.parent?.navigationItem.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling

            // make search bar appear at start (default behaviour since iOS 13)
            self.parent?.navigationController?.navigationBar.sizeToFit()
            // FIXME: What a shame! We need it when present it from UIHostingViewController.
            // If we don't use DispatchQueue.main.async, nothing will happen.
            DispatchQueue.main.async {
                self.searchController?.searchBar.becomeFirstResponder()
            }
        }
    }
}
