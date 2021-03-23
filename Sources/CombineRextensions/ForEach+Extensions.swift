//
//  ForEach+Extensions.swift
//  CombineRextensions
//
//  Created by Luiz Barbosa on 06.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import CombineRex
import SwiftUI

extension ForEach where Content: View {

    /// Create a ForEach view that also receives the index of each row. Your collection should have identifiable elements.
    /// - Parameters:
    ///   - enumerated: the collection you want to iterate over
    ///   - content: create a row View, given an index and element from your collection
    public init<Subdata: Collection>(
        enumerated: Subdata,
        @ViewBuilder content: @escaping (Subdata.Index, Subdata.Element) -> Content
    ) where Data == [(Subdata.Index, Subdata.Element)], Subdata.Element: Identifiable, ID == Subdata.Element.ID {
        self.init(
            enumerated: enumerated,
            id: \.id,
            content: content
        )
    }

    /// Create a ForEach view that also receives the index of each row. For collection of non-identifiable elements, the path to id must be provided.
    /// - Parameters:
    ///   - enumerated: the collection you want to iterate over
    ///   - id: resolve the ID for each row, or mark the collection element as identifiable to be able to omit this
    ///   - content: create a row View, given an index and element from your collection
    public init<Subdata: Collection>(
        enumerated: Subdata,
        id: KeyPath<Subdata.Element, ID>,
        @ViewBuilder content: @escaping (Subdata.Index, Subdata.Element) -> Content
    ) where Data == [(Subdata.Index, Subdata.Element)] {
        self.init(
            Array(zip(enumerated.indices, enumerated)),
            id: (\(Subdata.Index, Subdata.Element).1).appending(path: id),
            content: content
        )
    }
}

extension ForEach where Content: View {

    /// Given a collection of identifiable elements in your view model, receive an action with ID and row action for each row view model
    /// - Parameters:
    ///   - viewModel: parent view model, holding the state that contains the collection we want to iterate over
    ///   - collection: resolve the path from your state to some collection
    ///   - identifiableRowToCollectionAction: given an ID and a row action, assemble back a view action for the parent view model
    ///   - content: create a row View, given a view model that is specialized in the row types
    public init<Subdata: Collection, Action, State, RowAction>(
        viewModel: ObservableViewModel<Action, State>,
        collection: KeyPath<State, Subdata>,
        identifiableRowToCollectionAction: @escaping (ID, RowAction) -> Action?,
        @ViewBuilder content: @escaping (ObservableViewModel<RowAction, Subdata.Element>) -> Content
    ) where Data == [ObservableViewModel<RowAction, Subdata.Element>],
        Subdata.Element: Identifiable,
        Subdata.Element: Equatable,
        Subdata.Element.ID == ID {
        self.init(
            viewModel.state[keyPath: collection].map { row in
                viewModel.projection(
                    action: { rowAction in
                        identifiableRowToCollectionAction(row.id, rowAction)
                    },
                    state: { _ in
                        row
                    }
                ).asObservableViewModel(initialState: row, emitsValue: .whenDifferent)
            },
            id: \(ObservableViewModel<RowAction, Subdata.Element>).state.id,
            content: content
        )
    }

    /// Given a collection of elements in your view model, and a way to identify its elemenets, receive an action with ID and row action for each row
    /// view model
    /// - Parameters:
    ///   - viewModel: parent view model, holding the state that contains the collection we want to iterate over
    ///   - collection: resolve the path from your state to some collection
    ///   - id: resolve the ID for each row, or mark the collection element as identifiable to be able to omit this
    ///   - identifiableRowToCollectionAction: given an ID and a row action, assemble back a view action for the parent view model
    ///   - content: create a row View, given a view model that is specialized in the row types
    public init<Subdata: Collection, Action, State, RowAction>(
        viewModel: ObservableViewModel<Action, State>,
        collection: KeyPath<State, Subdata>,
        id: KeyPath<Subdata.Element, ID>,
        identifiableRowToCollectionAction: @escaping (ID, RowAction) -> Action?,
        @ViewBuilder content: @escaping (ObservableViewModel<RowAction, Subdata.Element>) -> Content
    ) where Data == [ObservableViewModel<RowAction, Subdata.Element>], Subdata.Element: Equatable {
        self.init(
            viewModel.state[keyPath: collection].map { row in
                viewModel.projection(
                    action: { rowAction in
                        identifiableRowToCollectionAction(row[keyPath: id], rowAction)
                    },
                    state: { _ in
                        row
                    }
                ).asObservableViewModel(initialState: row, emitsValue: .whenDifferent)
            },
            id: (\(ObservableViewModel<RowAction, Subdata.Element>).state).appending(path: id),
            content: content
        )
    }

    ///
    /// - Parameters:
    ///   - viewModel: parent view model, holding the state that contains the collection we want to iterate over
    ///   - collection: resolve the path from your state to some collection
    ///   - indexedRowToCollectionAction:
    ///   - content: create a row View, given a view model that is specialized in the row types
    public init<Subdata: Collection, Action, State, RowAction>(
        viewModel: ObservableViewModel<Action, State>,
        collection: KeyPath<State, Subdata>,
        indexedRowToCollectionAction: @escaping (Subdata.Index, RowAction) -> Action?,
        @ViewBuilder content: @escaping (ObservableViewModel<RowAction, Subdata.Element>) -> Content
    ) where Data == [ObservableViewModel<RowAction, Subdata.Element>],
            Subdata.Element: Identifiable,
            Subdata.Element: Equatable,
            Subdata.Element.ID == ID {
        self.init(
            Array(zip(viewModel.state[keyPath: collection].indices, viewModel.state[keyPath: collection])).map { index, row in
                viewModel.projection(
                    action: { rowAction in
                        indexedRowToCollectionAction(index, rowAction)
                    },
                    state: { _ in
                        row
                    }
                ).asObservableViewModel(initialState: row, emitsValue: .whenDifferent)
            },
            id: \(ObservableViewModel<RowAction, Subdata.Element>).state.id,
            content: content
        )
    }

    /// Given a collection of elements in your view model, and a way to identify its elemenets, receive an action with the index and row action for
    /// each row view model
    /// - Parameters:
    ///   - viewModel: parent view model, holding the state that contains the collection we want to iterate over
    ///   - collection: resolve the path from your state to some collection
    ///   - id: resolve the ID for each row, or mark the collection element as identifiable to be able to omit this
    ///   - indexedRowToCollectionAction: given an index and a row action, assemble back a view action for the parent view model
    ///   - content: create a row View, given a view model that is specialized in the row types
    public init<Subdata: Collection, Action, State, RowAction>(
        viewModel: ObservableViewModel<Action, State>,
        collection: KeyPath<State, Subdata>,
        id: KeyPath<Subdata.Element, ID>,
        indexedRowToCollectionAction: @escaping (Subdata.Index, RowAction) -> Action?,
        @ViewBuilder content: @escaping (ObservableViewModel<RowAction, Subdata.Element>) -> Content
    ) where Data == [ObservableViewModel<RowAction, Subdata.Element>], Subdata.Element: Equatable {
        self.init(
            Array(zip(viewModel.state[keyPath: collection].indices, viewModel.state[keyPath: collection])).map { index, row in
                viewModel.projection(
                    action: { rowAction in
                        indexedRowToCollectionAction(index, rowAction)
                    },
                    state: { _ in
                        row
                    }
                ).asObservableViewModel(initialState: row, emitsValue: .whenDifferent)
            },
            id: (\(ObservableViewModel<RowAction, Subdata.Element>).state).appending(path: id),
            content: content
        )
    }
}
