//
//  StoreSheet.swift
//  CombineRextensions
//
//  Created by Luis Reisewitz on 13.02.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import CombineRex
import SwiftUI

extension View {
    /// Presents a sheet  when the given `Screen` key path is non-nil. The view that will be shown
    /// is created by the given `ViewProducer`.
    ///
    /// - Parameters:
    ///   - store: The view model containing the state.
    ///   - path: The key path pointing to the element to show as sheet.
    ///   - dismissAction: Action that should be dispatched to the store when a modal is dismissed.
    ///   - producer: The ViewProducer that transforms the given `Screen` into a View.
    public func storeSheet<Action, State, Context: Identifiable, ContentView: View>(
        _ store: ObservableViewModel<Action, State>,
        path: KeyPath<State, Context?>,
        dismissAction: Action,
        producer: ViewProducer<Context, ContentView>) -> some View {
        return sheet(
            item: store.binding[path],
            onDismiss: { store.dispatch(dismissAction) },
            content: producer.view
        )
    }
}

// MARK: - Sheets from Store
extension View {
    /// Presents a sheet  when the given `Context` key path is non-nil. The view that will be shown
    /// is created by the given `ViewProducer`.
    ///
    /// - Parameters:
    ///   - store: The view model containing the state.
    ///   - path: The key path pointing to the element to show as sheet.
    ///   - dismissAction: Action that should be dispatched to the store when a modal is dismissed.
    ///   - producer: The ViewProducer that transforms the given `Context` into a View.
    public func storeSheet<Action, State, Context: Identifiable, ContentView: View>(
        _ store: ObservableViewModel<Action, State>,
        path: KeyPath<State, Context?>,
        dismissAction: Action,
        producer: ViewProducer<Context, ContentView>,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil) -> some View {
        return sheet(
            item: store.binding[path],
            onDismiss: {
                withAnimation {
                    store.dispatch(
                        dismissAction,
                        from: ActionSource(
                            file: file,
                            function: function,
                            line: line,
                            info: (info.map { $0 + " -> " } ?? "") + "View+StoreSheet.swift onDismiss closure"
                        )
                    )
                }
            },
            content: producer.view
        )
    }
}
