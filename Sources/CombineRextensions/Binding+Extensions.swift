//
//  Binding+Extensions.swift
//  CombineRextensions
//
//  Created by Luiz Barbosa on 01.11.19.
//  Copyright © 2019 Lautsprecher Teufel GmbH. All rights reserved.
//

@preconcurrency import CombineRex
import Foundation
import SwiftRex
import SwiftUI

public enum ChangeModifier {
    case animated
    case notAnimated
}

@MainActor
extension Binding {
    public static func store<Action, State>(
        _ store: ObservableViewModel<Action, State>,
        state: KeyPath<State, Value>,
        changeModifier: ChangeModifier = .notAnimated,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        onChange: @escaping (Value) -> Action?
    ) -> Binding<Value> {
        Binding.store(
            store,
            stateMap: { $0[keyPath: state] },
            changeModifier: changeModifier,
            file: file,
            function: function,
            line: line,
            info: info,
            onChange: onChange
        )
    }

    public static func store<Action, State>(
        _ store: ObservableViewModel<Action, State>,
        stateMap: @escaping (State) -> Value,
        changeModifier: ChangeModifier = .notAnimated,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        onChange: @escaping (Value) -> Action?
    ) -> Binding<Value> {
        return .caching(
            get: { stateMap(store.state) },
            set: { newValue in
                // Allow to not dispatch any action.
                guard let action = onChange(newValue) else { return }
                let dispatch = {
                    store.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
                }
                switch changeModifier {
                case .animated:
                    withAnimation { dispatch() }
                case .notAnimated:
                    dispatch()
                }
        })
    }

    /// Returns a Binding that ignores all tries to set the value.
    public static func getOnly<Action, State>(_ store: ObservableViewModel<Action, State>,
                                              state: KeyPath<State, Value>) -> Binding<Value> {
        return .init(
            get: { store.state[keyPath: state] },
            set: { _ in }
        )
    }

    @MainActor
    public static func caching(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void) -> Binding<Value> {
        var temp: Value?
        return .init(
            get: { temp ?? get() },
            set: { newValue in
                temp = newValue
                set(newValue)

        })
    }
}
