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

internal import Property_Primitives
public import Storage_Primitive
public import Storage_Error_Primitives
public import Storage_Initialization_Primitives
public import Storage_Field_Primitives
public import Storage_Accessor_Primitives
public import Index_Primitives
public import Memory_Primitives_Standard_Library_Integration
public import Memory_Address_Primitives
public import Memory_Alignment_Primitives
public import Memory_Contiguous_Primitives

// MARK: - Initialize Accessor

extension Storage.Split where Element: ~Copyable {
    /// Accessor for initialize operations on split storage.
    ///
    /// ```swift
    /// storage.initialize(element, to: value, at: slot)
    /// ```
    @inlinable
    public var initialize: Property<Storage.Initialize, Storage.Split<Lane>> {
        Property(self)
    }
}

extension Property {
    /// Initializes the value at the given slot in the given field.
    ///
    /// - Parameters:
    ///   - field: The field handle identifying which array to access.
    ///   - value: The value to store.
    ///   - slot: The physical slot to initialize.
    /// - Precondition: The slot must be uninitialized.
    @inlinable
    public func callAsFunction<Element: ~Copyable, Lane: BitwiseCopyable, Value: ~Copyable>(
        _ field: Storage<Element>.Field<Value>,
        to value: consuming Value,
        at slot: Index<Element>
    ) where Tag == Storage<Element>.Initialize, Base == Storage<Element>.Split<Lane> {
        unsafe base.pointer(field, at: slot).initialize(to: value)
    }
}
