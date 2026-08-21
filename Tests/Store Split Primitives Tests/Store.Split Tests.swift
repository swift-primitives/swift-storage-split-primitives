import Index_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Store_Split_Primitives
import Testing

private typealias Plane<Element: ~Copyable> =
    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>

@Suite
struct `Store Split Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `payload seam forwards to element plane`() {
        var split = Store.Split(
            lanes: Plane<UInt8>.create(minimumCapacity: Index<UInt8>.Count(4)),
            elements: Plane<Int>.create(minimumCapacity: Index<Int>.Count(4))
        )
        let cap = split.capacity
        #expect(cap == Index<Int>.Count(4))

        split.initialize(at: 0, to: 42)
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
    func `lane plane is independently accessible`() {
        var split = Store.Split(
            lanes: Plane<UInt8>.create(minimumCapacity: Index<UInt8>.Count(4)),
            elements: Plane<Int>.create(minimumCapacity: Index<Int>.Count(4))
        )

        split.lanes.initialize(at: 0, to: 0x80)
        split.lanes.initialize(at: 1, to: 0x01)
        split.initialize(at: 0, to: 1000)

        let lane0 = split.lanes[0]
        let lane1 = split.lanes[1]
        let laneCap = split.lanes.capacity
        let payload0 = split[0]
        #expect(lane0 == 0x80)
        #expect(lane1 == 0x01)
        #expect(laneCap == Index<UInt8>.Count(4))
        #expect(payload0 == 1000)
    }
}
