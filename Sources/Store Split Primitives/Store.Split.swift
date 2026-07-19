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

public import Store_Primitive
public import Store_Protocol_Primitives

extension Store {
    /// Dual-plane (SoA) storage composing two element-store substrates: a **lane** plane for per-slot
    /// metadata and an **element** plane for payloads.
    ///
    /// `Store.Split` is a **store combinator**, not an allocation-backed leaf: it is generic over two
    /// `Store.`Protocol`` substrates and composes them, holding no `Allocation` of its own and carrying
    /// no deinit oracle (each plane's own teardown frees its region). It therefore lives on the
    /// non-generic `Store` namespace — alongside the seam it composes — rather than under the generic
    /// `Storage<Allocation>` carrier (where it would be phantom-generic over an unused `Allocation`).
    /// The split itself conforms `Store.`Protocol`` over the **payload** plane — a `Store.Split` *is* an
    /// element store of its `Element`, with a parallel metadata plane riding alongside. Lane access goes
    /// through ``lanes``; payload access through the conformance surface (or ``elements``).
    ///
    /// ## Substitution tower position
    ///
    /// ```
    /// Buffer.Slots<…>                       (occupancy discipline)
    ///     └─ Store.Split<Lanes, Elements>   (typed slots, two planes)
    ///            ├─ Lanes                   (metadata store: tokens, control bytes, …)
    ///            └─ Elements                (payload store)
    /// ```
    ///
    /// ## Plane correspondence
    ///
    /// The planes are self-bounding, independent stores; `Store.Split` imposes NO cross-plane capacity
    /// invariant. Slot correspondence between metadata and payload (and any occupancy discipline over
    /// it) is the Buffer tier's concern — exactly as element lifecycle already is.
    @frozen
    public struct Split<
        Lanes: Store.`Protocol` & ~Copyable,
        Elements: Store.`Protocol` & ~Copyable
    >: ~Copyable {
        /// The payload element type — the split's `Store.`Protocol`` `Element`.
        public typealias Element = Elements.Element

        /// The per-slot metadata element type, derived from the lane plane.
        public typealias Lane = Lanes.Element

        /// The lane (metadata) plane.
        @usableFromInline
        internal var _lanes: Lanes

        /// The element (payload) plane.
        @usableFromInline
        internal var _elements: Elements

        /// Creates split storage over the given planes.
        ///
        /// - Parameters:
        ///   - lanes: The metadata element store; ownership transfers in.
        ///   - elements: The payload element store; ownership transfers in.
        @inlinable
        public init(lanes: consuming Lanes, elements: consuming Elements) {
            self._lanes = lanes
            self._elements = elements
        }
    }
}

// MARK: - Conditional Copyability

/// A split is copyable exactly when both of its planes are.
///
/// Copying copies the planes; what a plane copy MEANS (eager copy, CoW
/// reference share, …) is the plane's own semantic.
extension Store.Split: Copyable where Lanes: Copyable, Elements: Copyable {}
