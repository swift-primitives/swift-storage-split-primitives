public import Store_Primitive
public import Store_Protocol_Primitives

extension Store {

    @frozen
    public struct Split<
        Lanes: Store.`Protocol` & ~Copyable,
        Elements: Store.`Protocol` & ~Copyable
    >: ~Copyable {

        @usableFromInline
        internal var _lanes: Lanes

        @usableFromInline
        internal var _elements: Elements

        @inlinable
        public init(lanes: consuming Lanes, elements: consuming Elements) {
            self._lanes = lanes
            self._elements = elements
        }
    }
}

extension Store.Split where Lanes: ~Copyable, Elements: ~Copyable {

    public typealias Element = Elements.Element

    public typealias Lane = Lanes.Element
}

extension Store.Split: Copyable where Lanes: Copyable, Elements: Copyable {}
