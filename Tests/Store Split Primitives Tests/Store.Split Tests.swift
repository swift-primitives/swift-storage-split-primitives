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

// Behavioral tests for the reshaped `Store.Split<Lanes, Elements>` store combinator — two
// `Store.Protocol` planes (a lane/metadata plane + an element/payload plane), with the split
// conforming the 4-op seam over the payload plane and exposing both planes directly. Tower values are
// `~Copyable`, so every property / subscript result is read into a copyable local before `#expect`.

import Index_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Store_Split_Primitives
import Testing

/// A heap-backed contiguous plane (a `Store.Protocol` conformer) parameterized by its element type.
private typealias Plane<Element: ~Copyable> =
    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>

@Suite
struct StoreSplitTests {

    @Test
    func payloadSeamForwardsToElementPlane() {
        var split = Store.Split(
            lanes: Plane<UInt8>.create(minimumCapacity: Index<UInt8>.Count(4)),
            elements: Plane<Int>.create(minimumCapacity: Index<Int>.Count(4))
        )
        let cap = split.capacity
        #expect(cap == Index<Int>.Count(4))  // capacity is the payload plane's

        split.initialize(at: 0, to: 42)  // seam → payload plane
        split.initialize(at: 1, to: 43)
        let v0 = split[0]
        let v1 = split[1]
        #expect(v0 == 42)
        #expect(v1 == 43)

        split[0] = 99
        let v0b = split[0]
        #expect(v0b == 99)

        let moved = split.move(at: 1)
        #expect(moved == 43)
    }

    @Test
    func lanePlaneIsIndependentlyAccessible() {
        var split = Store.Split(
            lanes: Plane<UInt8>.create(minimumCapacity: Index<UInt8>.Count(4)),
            elements: Plane<Int>.create(minimumCapacity: Index<Int>.Count(4))
        )
        // The two planes are independent stores; lane access goes through `lanes`.
        split.lanes.initialize(at: 0, to: 0x80)
        split.lanes.initialize(at: 1, to: 0x01)
        split.initialize(at: 0, to: 1000)

        let lane0 = split.lanes[0]
        let lane1 = split.lanes[1]
        let laneCap = split.lanes.capacity
        let payload0 = split[0]
        #expect(lane0 == 0x80)
        #expect(lane1 == 0x01)
        #expect(laneCap == Index<UInt8>.Count(4))  // each plane bounds itself
        #expect(payload0 == 1000)
    }
}
