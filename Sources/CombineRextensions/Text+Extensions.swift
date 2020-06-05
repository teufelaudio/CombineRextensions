//
//  Text+Extensions.swift
//  CombineRextensions
//
//  Created by Luiz Rodrigo Martins Barbosa on 05.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import Foundation
import SwiftRex
import SwiftUI

extension Text {
    public init<S: StoreType>(store: S,
                              verbatim: (S) -> String,
                              file: String = #file,
                              function: String = #function,
                              line: UInt = #line,
                              info: String? = nil) {
        self.init(verbatim: verbatim(store))
    }
}

extension Text {
    public init<S: StoreType>(store: S,
                              localizableKey: (S) -> String,
                              file: String = #file,
                              function: String = #function,
                              line: UInt = #line,
                              info: String? = nil) {
        self.init(LocalizedStringKey(localizableKey(store)))
    }
}
