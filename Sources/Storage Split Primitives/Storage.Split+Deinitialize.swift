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

// MARK: - Deinitialize Accessor

extension Storage.Split where Element: ~Copyable {
    /// Accessor for deinitialize operations on split storage.
    ///
    /// ```swift
    /// storage.deinitialize(element, at: slot)
    /// ```
    @inlinable
    public var `deinitialize`: Property<Storage.Deinitialize, Storage.Split<Lane>> {
        Property(self)
    }
}

extension Property {
    /// Deinitializes the value at the given slot in the given field.
    ///
    /// - Parameters:
    ///   - field: The field handle identifying which array to access.
    ///   - slot: The physical slot to deinitialize.
    /// - Precondition: The slot must contain an initialized value.
    @inlinable
    public func callAsFunction<Element: ~Copyable, Lane: BitwiseCopyable, Value: ~Copyable>(
        _ field: Storage<Element>.Field<Value>,
        at slot: Index<Element>
    ) where Tag == Storage<Element>.Deinitialize, Base == Storage<Element>.Split<Lane> {
        unsafe base.pointer(field, at: slot).deinitialize(count: .one)
    }
}
