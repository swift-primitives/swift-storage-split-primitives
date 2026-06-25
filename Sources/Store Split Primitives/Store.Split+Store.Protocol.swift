// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Index_Primitives
public import Store_Protocol_Primitives

// MARK: - Store.Protocol Witnesses (the PAYLOAD plane)
//
// `Store.Split` conforms the 4-op seam over its payload plane, forwarding through the plane's own
// `_read` / `_modify` accessors — the element-store seam crossing that specializes to zero
// `witness_method` on concrete towers. The lane plane rides alongside (reached via `lanes`); the
// split imposes no cross-plane capacity invariant.

extension Store.Split where Lanes: ~Copyable, Elements: ~Copyable {
    /// Payload slot capacity — the element plane's capacity.
    @inlinable
    public var capacity: Index<Elements.Element>.Count {
        _elements.capacity
    }

    /// Reads or writes the initialized payload at the given physical slot (witnesses `subscript`).
    @inlinable
    public subscript(slot: Index<Elements.Element>) -> Elements.Element {
        _read { yield _elements[slot] }
        _modify { yield &_elements[slot] }
    }

    /// Initializes the uninitialized payload slot at `slot` (witnesses `initialize(at:to:)`).
    @inlinable
    public mutating func initialize(at slot: Index<Elements.Element>, to element: consuming Elements.Element) {
        _elements.initialize(at: slot, to: element)
    }

    /// Moves the initialized payload out of `slot` (witnesses `move(at:)`).
    @inlinable
    public mutating func move(at slot: Index<Elements.Element>) -> Elements.Element {
        _elements.move(at: slot)
    }
}

// MARK: - Conformance

extension Store.Split: Store.`Protocol` where Lanes: ~Copyable, Elements: ~Copyable {}
