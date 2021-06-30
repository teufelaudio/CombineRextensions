//
//  TeufelButton.swift
//  CombineRextensions
//
//  Created by Luiz Rodrigo Martins Barbosa on 13.12.19.
//  Copyright © 2019 Lautsprecher Teufel GmbH. All rights reserved.
//

import Foundation
import CombineRex
import SwiftRex
import SwiftUI

extension Button where Label == Text {
    public init<S: StoreType>(store: S,
                              verbatim: (S) -> String,
                              action: @escaping @autoclosure () -> S.ActionType,
                              file: String = #file,
                              function: String = #function,
                              line: UInt = #line,
                              info: String? = nil) {
        self.init(
            action: { store.dispatch(action(), from: ActionSource(file: file, function: function, line: line, info: info)) },
            label: { Text(verbatim: verbatim(store)) }
        )
    }
}

extension Button where Label == Text {
    public init<S: StoreType>(store: S,
                              localizableKey: (S) -> String,
                              action: @escaping @autoclosure () -> S.ActionType,
                              file: String = #file,
                              function: String = #function,
                              line: UInt = #line,
                              info: String? = nil) {
        self.init(
            action: { store.dispatch(action(), from: ActionSource(file: file, function: function, line: line, info: info)) },
            label: { Text(LocalizedStringKey(localizableKey(store))) }
        )
    }
}

extension Button where Label == Text {
    public init<ActionType, StateType>(localizedString: KeyPath<StateType, String>,
                                       viewModel: ObservableViewModel<ActionType, StateType>,
                                       action: @escaping @autoclosure () -> ActionType,
                                       file: String = #file,
                                       function: String = #function,
                                       line: UInt = #line,
                                       info: String? = nil) {
        let actionSource = ActionSource(file: file, function: function, line: line, info: info)
        self.init(viewModel.state[keyPath: localizedString], action: {
            viewModel.dispatch(action(), from: actionSource)
        })
    }
}

extension Button {
    public init<S: StoreType>(store: S,
                              action: @escaping @autoclosure () -> S.ActionType,
                              file: String = #file,
                              function: String = #function,
                              line: UInt = #line,
                              info: String? = nil,
                              @ViewBuilder content: (S) -> Label) {
        self.init(
            action: { store.dispatch(action(), from: ActionSource(file: file, function: function, line: line, info: info)) },
            label: { content(store) }
        )
    }
}
