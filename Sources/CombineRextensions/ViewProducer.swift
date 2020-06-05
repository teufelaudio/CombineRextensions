//
//  ViewProducer.swift
//  CombineRextensions
//
//  Created by Luis Reisewitz on 12.02.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import SwiftUI

/// Defines a function mapping a Navigation Route to a View.
/// Can be used in ViewModels to map navigation anchor points to their views.
public protocol ViewProducer: Equatable {
    /// Navigation Route in your State, usually a leaf in an enum tree
    associatedtype Route: Hashable

    /// View to be rendered as output for this function
    associatedtype Content: View

    /// Typealias to the function that produces a View from the navigation route state
    typealias Producer = (Route) -> Content

    /// Init with the function that produces a View from the navigation route state
    init(_ fn: @escaping Producer)

    /// Runs the function that produces a View from the navigation route state
    func view(for route: Route) -> Content
}

extension ViewProducer {
    /// Erase this function to return an AnyView, creating an AnyViewProducer that doesn't hold the second generic parameter. Useful for passing
    /// to layers that don't want to know the resulting view type.
    public func erased() -> AnyViewProducer<Route> {
        .init(self.view(for:))
    }
}

/// Identity case for the ViewProducer, ignoring the Route and always rendering an Empty View
/// Can be used in ViewModels to map navigation anchor points to their views.
public struct EmptyViewProducer<Route: Hashable>: ViewProducer, Equatable {
    /// Init with the function that produces a View from the navigation route state
    /// In this case, this parameter will be ignored as this function always produces an Empty View
    public init(_ fn: @escaping Producer) { }

    /// Default initializer for this function
    public init() { }

    /// Produces an EmptyView regardless of the input parameter
    public func view(for route: Route) -> EmptyView {
        EmptyView()
    }

    /// Creates the closure that will produce an empty view regardless of its input.
    public static var empty: Producer {
        { _ in EmptyView() }
    }
}

/// Typed
public struct TypedViewProducer<Route: Hashable, Content: View>: ViewProducer, Equatable {
    private let viewProducer: (Route) -> Content

    /// Init with the function that produces a View from the navigation route state
    public init(_ fn: @escaping Producer) {
        self.viewProducer = fn
    }

    /// Runs the function that produces a View of type `Content` from the given navigation route state
    public func view(for route: Route) -> Content {
        viewProducer(route)
    }

    /// Always true, so it can be added to a ViewModel. To ensure ViewModel will change, the navigation route should always be present as well.
    public static func == (lhs: TypedViewProducer, rhs: TypedViewProducer) -> Bool {
        true
    }
}

/// Type erased View Producer, which given a Navigation Route will map it into a View, wrap this view in an erased AnyView and return it.
/// Can be used in ViewModels to map navigation anchor points to their views.
public struct AnyViewProducer<Route: Hashable>: ViewProducer, Equatable {
    private let viewProducer: (Route) -> AnyView

    /// Init with the function that produces a View from the navigation route state
    /// In this case, that resulting view will have its type erased to AnyView
    public init<V: View>(_ fn: @escaping (Route) -> V) {
        self.viewProducer = { AnyView(fn($0)) }
    }

    /// Runs the function that produces a View of type `AnyView` from the given navigation route state
    public func view(for route: Route) -> AnyView {
        viewProducer(route)
    }

    /// Always true, so it can be added to a ViewModel. To ensure ViewModel will change, the navigation route should always be present as well.
    public static func == (lhs: AnyViewProducer, rhs: AnyViewProducer) -> Bool {
        true
    }

    public static var empty: AnyViewProducer<Route> {
        EmptyViewProducer<Route>().erased()
    }
}
