# Storage Split Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A dual-plane (structure-of-arrays) store combinator for Swift — composes two element-store substrates into a single `~Copyable` value with a metadata plane riding alongside a payload plane, with zero platform dependencies.

---

## Quick Start

`Store.Split<Lanes, Elements>` composes two `Store.Protocol` substrates: a **lane** plane for per-slot metadata and an **element** plane for payloads. It holds no allocation of its own — each plane owns and frees its own region — so the split is a pure combinator over the two planes. It conforms `Store.Protocol` over the *payload* plane, so a `Store.Split` *is* an element store of its `Element`; the lane plane is reached through `lanes`.

```swift
import Store_Split_Primitives
import Storage_Contiguous_Primitives
import Index_Primitives

// Compose a metadata plane (control bytes) with a payload plane (Int).
typealias Plane<Element: ~Copyable> = Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>

var split = Store.Split(
    lanes: Plane<UInt8>.create(minimumCapacity: Index<UInt8>.Count(4)),
    elements: Plane<Int>.create(minimumCapacity: Index<Int>.Count(4))
)

// The payload-plane seam: capacity, initialize, subscript, move.
split.initialize(at: 0, to: 42)        // forwards to the element plane
split[0] = 99                          // _read / _modify subscript
let value = split[0]                   // 99
let moved = split.move(at: 0)          // 99, slot now uninitialized

// The metadata plane is reached independently through `lanes`.
split.lanes.initialize(at: 0, to: 0x80)
let control = split.lanes[0]           // 0x80
```

The two planes are **self-bounding, independent stores**: `Store.Split` imposes no cross-plane capacity invariant. Slot correspondence between metadata and payload — and any occupancy discipline over it — is the buffer tier's concern. The split is `~Copyable`, and copyable exactly when both planes are; what a plane copy *means* (eager copy, copy-on-write reference share, …) is each plane's own semantic.

For scoped, exclusive plane access there are closure windows — `withLanes`, `withMutableLanes`, `withElements`, `withMutableElements` — that run a body inside the plane's borrow so a plane-derived `Span` stays sound for the body's duration.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-storage-split-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Store Split Primitives", package: "swift-storage-split-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

One library product composing the `Store` namespace from `swift-storage-primitives`.

| Product | Target | Purpose |
|---------|--------|---------|
| `Store Split Primitives` | `Sources/Store Split Primitives/` | The `Store.Split<Lanes, Elements>` combinator: dual-plane construction, the payload-plane `Store.Protocol` conformance (capacity / subscript / `initialize(at:to:)` / `move(at:)`), direct plane accessors (`lanes` / `elements`), and the scoped plane-access windows. Re-exports `Store Primitive` and `Store Protocol Primitives`. |

`Store.Split` lives on the non-generic `Store` namespace — alongside the seam it composes — rather than under the generic `Storage<Allocation>` carrier, because it owns no allocation and carries no deinit oracle. Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
