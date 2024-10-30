//
//  NavigationLink+Extensions.swift
//  CombineRextensions
//
//  Created by Luiz Barbosa on 02.11.19.
//  Copyright © 2019 Lautsprecher Teufel GmbH. All rights reserved.
//

import Combine
import CombineRex
import SwiftRex
import SwiftUI

extension NavigationLink {
    @MainActor
    public init<Action, State, RowTag: Hashable>(
        destination: Destination,
        rowTag: RowTag,
        viewModel: ObservableViewModel<Action, State>,
        pathToSelectedRowTag: KeyPath<State, RowTag?>,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        onOpen: @escaping (RowTag) -> Action,
        onClose: @autoclosure @escaping () -> Action,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.init(
            destination: destination,
            tag: rowTag,
            selection: Binding<RowTag?>(
                get: {
                    viewModel.state[keyPath: pathToSelectedRowTag]
                },
                set: { row in
                    if row != nil && row == rowTag {
                        viewModel.dispatch(onOpen(rowTag), from: .init(file: file, function: function, line: line, info: info))
                    } else if row == nil {
                        viewModel.dispatch(onClose(), from: .init(file: file, function: function, line: line, info: info))
                    }
                }),
            label: label)
    }
}

// MARK: - PoppableAction
public protocol PoppableAction {
    /// An action that describes that a detail screen was popped.
    static var popAction: Self { get }
}

// MARK: - NavigationTree Support
extension NavigationLink {
    @MainActor
    public init?<Action: PoppableAction, State, ViewProducerContext: Hashable>(
        store: ObservableViewModel<Action, State>,
        path: KeyPath<State, ViewProducerContext?>,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        producer: ViewProducer<ViewProducerContext, Destination>)
        where Label == EmptyView {
            // Don't even return the NavigationLink when we have no Screen to show.
            // That way, we do not unnecessarily produce views via ViewProducer.
            guard let secondScreen = store.state[keyPath: path] else { return nil }
            self.init(
                destination: producer.view(secondScreen),
                tag: secondScreen,
                selection: Binding<ViewProducerContext?>.store(store, state: path, file: file, function: function, line: line, info: info) { value in
                    // We want to dispatch the pop action here in case the user
                    // pops the detail screen so that the RouterReducer knows
                    // to manipulate the NavigationTree.
                    // TODO: The given binding is ALSO set to nil when the view disappears
                    // IMPORTANT: disappears or is recreated? This is an important distinction.
                    // Meaning, when we (for whatever reason) hide the view containing
                    // the NavigationLink, SwiftUI tries to set the binding to nil.
                    guard value == nil else { return nil }
                    return .popAction
                },
                label: EmptyView.init
            )
    }
}
