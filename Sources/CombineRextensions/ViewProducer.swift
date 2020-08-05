//
//  ViewProducer.swift
//  CombineRextensions
//
//  Created by Luis Reisewitz on 12.02.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import SwiftUI

/// Defines a function mapping some state context to a View.
/// Can be used by ViewModels to map navigation anchor points to their views.
public struct ViewProducer<Context, ProducedView: View> {
    /// Runs the function that produces a View from the state context
    public let run: (Context) -> ProducedView

    /// Init with the function that produces a View from some state context
    public init(_ run: @escaping (Context) -> ProducedView) {
        self.run = run
    }
}

extension ViewProducer {
    public func view(_ context: Context) -> ProducedView {
        self.run(context)
    }
}

extension ViewProducer where Context == Void {
    public func view() -> ProducedView {
        self.run(())
    }
}

extension ViewProducer {
    /// Identity case for the ViewProducer, ignoring the state and always rendering the provided view
    /// Can be used in ViewModels to map navigation anchor points to their views.
    public static func pure(_ view: ProducedView) -> ViewProducer {
        .init { _ in view }
    }
}

extension ViewProducer where ProducedView == EmptyView {
    /// Identity case for the ViewProducer, ignoring the state and always rendering an EmptyView
    /// Can be used in ViewModels to map navigation anchor points to their views.
    public static func pure() -> ViewProducer {
        .init { _ in EmptyView() }
    }
}
