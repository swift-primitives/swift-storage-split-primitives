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

public import Store_Protocol_Primitives

// MARK: - Plane Access

extension Store.Split where Lanes: ~Copyable, Elements: ~Copyable {
    /// The lane (metadata) plane — itself an element store.
    ///
    /// `_modify` yields exclusive access through
    /// `&self`, so plane mutation composes with the split's ownership exactly like a stored property.
    @inlinable
    public var lanes: Lanes {
        _read { yield _lanes }
        _modify { yield &_lanes }
    }

    /// The element (payload) plane — itself an element store.
    ///
    /// The split's own `Store.`Protocol`` surface forwards here; direct plane access is provided for
    /// symmetry with ``lanes`` and for plane-generic algorithms (e.g. reaching the payload plane's
    /// `initialization` ledger).
    @inlinable
    public var elements: Elements {
        _read { yield _elements }
        _modify { yield &_elements }
    }
}

// MARK: - Scoped plane access (the coroutine-window rule)
//
// The `lanes`/`elements` accessors are `_read`/`_modify` coroutines: a ~Escapable value derived
// from a plane (a `Span`) cannot outlive their yield scope. These closure windows run the body
// INSIDE the plane access, so plane-derived views are sound for the body's duration — the same
// scoped/yielding rule the buffer tier uses at its window boundaries.

extension Store.Split where Lanes: ~Copyable, Elements: ~Copyable {
    /// Calls `body` with a borrow of the lane (metadata) plane.
    @inlinable
    public func withLanes<R, Failure: Swift.Error>(
        _ body: (borrowing Lanes) throws(Failure) -> R
    ) throws(Failure) -> R {
        try body(_lanes)
    }

    /// Calls `body` with exclusive access to the lane (metadata) plane.
    @inlinable
    public mutating func withMutableLanes<R, Failure: Swift.Error>(
        _ body: (inout Lanes) throws(Failure) -> R
    ) throws(Failure) -> R {
        try body(&_lanes)
    }

    /// Calls `body` with a borrow of the element (payload) plane.
    @inlinable
    public func withElements<R, Failure: Swift.Error>(
        _ body: (borrowing Elements) throws(Failure) -> R
    ) throws(Failure) -> R {
        try body(_elements)
    }

    /// Calls `body` with exclusive access to the element (payload) plane.
    @inlinable
    public mutating func withMutableElements<R, Failure: Swift.Error>(
        _ body: (inout Elements) throws(Failure) -> R
    ) throws(Failure) -> R {
        try body(&_elements)
    }
}
