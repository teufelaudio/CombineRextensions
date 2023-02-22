// Copyright © 2023 Lautsprecher Teufel GmbH. All rights reserved.

import CombineRex
import SwiftUI
import UIExtensions

extension View {
    /// Presents a destination  when the given `Context` key path is non-nil. The view that will be shown
    /// is created by the given `ViewProducer`.
    ///
    /// - Parameters:
    ///   - store: The view model containing the state.
    ///   - path: The key path pointing to the element to show as sheet.
    ///   - dismissAction: Action that should be dispatched to the store when a modal is dismissed.
    ///   - producer: The ViewProducer that transforms the given `Context` into a View.
    @available(iOS, introduced: 15)
    @available(macOS, introduced: 12)
    public func navigationDestination<Action, State, Context: Identifiable, ContentView: View>(
        _ store: ObservableViewModel<Action, State>,
        path: KeyPath<State, Context?>,
        dismissAction: Action,
        producer: ViewProducer<Context, ContentView>,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil) -> some View {
            return navigationDestination(unwrapping: store.binding[path],
                                         onNavigate: { isActive in
                guard !isActive else { return }
                withAnimation {
                    store.dispatch(
                        dismissAction,
                        from: ActionSource(
                            file: file,
                            function: function,
                            line: line,
                            info: (info.map { $0 + " -> " } ?? "") + "View+NavigationDestination.swift onNavigate closure"
                        )
                    )
                }
            },
                                         destination: { $context in producer.view(context) })
        }
}

