//
//  ViewEvents+Extensions.swift
//  CombineRextensions
//
//  Created by Luiz Rodrigo Martins Barbosa on 05.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import Combine
import Foundation
import SwiftRex
import SwiftUI

@available(iOS 13.0, OSX 10.15, watchOS 6.0, *)
@available(tvOS, unavailable)
extension View {
    public func onLongPressGesture<S: StoreType>(
        store: S,
        minimumDuration: Double = 0.5,
        maximumDistance: CGFloat = 10,
        pressing: ((Bool) -> Void)? = nil,
        perform action: @escaping @autoclosure () -> S.ActionType,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil
    ) -> some View {
        onLongPressGesture(
            minimumDuration: minimumDuration,
            maximumDistance: maximumDistance,
            pressing: pressing,
            perform: { store.dispatch(action(), from: .init(file: file, function: function, line: line, info: info)) }
        )
    }
}

@available(iOS 13.0, OSX 10.15, watchOS 6.0, *)
@available(tvOS, unavailable)
extension View {
    public func onTapGesture<S: StoreType>(
        store: S,
        count: Int = 1,
        perform action: @escaping @autoclosure () -> S.ActionType,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil
    ) -> some View {
        onTapGesture(count: count, perform: { store.dispatch(action(), from: .init(file: file, function: function, line: line, info: info)) })
    }
}

@available(iOS 13.4, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onDrag<S: StoreType>(
        store: S,
        perform action: (() -> S.ActionType)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        _ data: @escaping (S) -> NSItemProvider
    ) -> some View {
        (action?()).map { store.dispatch($0, from: .init(file: file, function: function, line: line, info: info)) }
        return onDrag { data(store) }
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    public func onReceive<P: Publisher, S: StoreType>(
        store: S,
        _ publisher: P,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping (P.Output) -> S.ActionType
    ) -> some View where P.Failure == Never {
        onReceive(publisher, perform: {
            store.dispatch(action($0), from: .init(file: file, function: function, line: line, info: info))
        })
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    public func onAppear<S: StoreType>(
        store: S,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping @autoclosure () -> S.ActionType) -> some View {
        onAppear {
            store.dispatch(action(), from: .init(file: file, function: function, line: line, info: info))
        }
    }

    public func onDisappear<S: StoreType>(
        store: S,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping @autoclosure () -> S.ActionType
    ) -> some View {
        onDisappear {
            store.dispatch(action(), from: .init(file: file, function: function, line: line, info: info))
        }
    }
}

@available(iOS 13.4, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func onHover<S: StoreType>(
        store: S,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping (Bool) -> S.ActionType
    ) -> some View {
        onHover(perform: {
            store.dispatch(action($0), from: .init(file: file, function: function, line: line, info: info))
        })
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    public func onPreferenceChange<K: PreferenceKey, S: StoreType>(
        store: S,
        _ key: K.Type = K.self,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping (K.Value) -> S.ActionType
    ) -> some View where K.Value : Equatable {
        onPreferenceChange(key) {
            store.dispatch(action($0), from: .init(file: file, function: function, line: line, info: info))
        }
    }
}

@available(iOS 13.4, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onDrop<S: StoreType>(
        store: S,
        of supportedTypes: (S) -> [String],
        isTargeted: (S) -> Binding<Bool>?,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping ([NSItemProvider]) -> S.ActionType?
    ) -> some View {
        onDrop(of: supportedTypes(store), isTargeted: isTargeted(store)) { provider in
            guard let dispatchAction = action(provider) else { return false }
            store.dispatch(dispatchAction, from: .init(file: file, function: function, line: line, info: info))
            return true
        }
    }

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onDrop<S: StoreType>(
        store: S,
        of supportedTypes: @escaping (S) -> [String],
        isTargeted: @escaping (S) -> Binding<Bool>?,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        perform action: @escaping ([NSItemProvider], CGPoint) -> S.ActionType?
    ) -> some View {
        onDrop(of: supportedTypes(store), isTargeted: isTargeted(store)) { provider, cgPoint in
            guard let dispatchAction = action(provider, cgPoint) else { return false }
            store.dispatch(dispatchAction, from: .init(file: file, function: function, line: line, info: info))
            return true
        }
    }
}
