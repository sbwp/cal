//
//  Publisher.swift
//
//  Created by Sabrina Bea on 10/25/20.
//  Copyright © 2020 Sabrina Bea. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    // Returns values emitted pairwise, starting with first and second values
    func pairwise(initialValue: Self.Output) -> Publishers.Drop<Publishers.Scan<Self, (Self.Output, Self.Output)>> {
        return scan((initialValue, initialValue)) { ($0.1, $1) }
            .dropFirst()
    }
}

extension Publisher where Self.Output: DefaultInitable {
    // Returns values emitted pairwise, starting with first and second values
    func pairwise() -> Publishers.Drop<Publishers.Scan<Self, (Self.Output, Self.Output)>> {
        return pairwise(initialValue: Self.Output())
    }
}

protocol DefaultInitable {
    init()
}

extension Array: DefaultInitable {}
