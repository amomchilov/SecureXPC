//
//  TestHelpers.swift
//  
//
//  Created by Alexander Momchilov on 2021-11-03.
//

import XCTest
@testable import SecureXPC

// MARK: Encoding entry point

func encode<T: Encodable>(_ input: T) throws -> xpc_object_t {
	try XPCEncoder.encode(input)
}

// MARK: Assertions


/// Assert that the provided `input`, when encoded using an XPCEncoder, is equal to the `expected` XPC Object
func assert<T: Encodable>(
	_ input: T,
	encodesEqualTo expected: xpc_object_t,
	file: StaticString = #file,
	line: UInt = #line
) throws {
	let actual = try encode(input)
	assertEqual(actual, expected, file: file, line: line)
}

/// Asserts that `actual` and `expected` are value-equal, according to `xpc_equal`
///
/// `-[OS_xpc_object isEqual]` exists, but it uses object-identity as the basis for equality, which is not what we want here.
fileprivate func assertEqual(
	_ actual: xpc_object_t,
	_ expected: xpc_object_t,
	file: StaticString = #file,
	line: UInt = #line
) {
	if !xpc_equal(expected, actual) {
		XCTFail("\(actual) is not equal to \(expected).", file: file, line: line)
	}
}

// MARK: XPC object factories

/// Converts the provided `sourceArray` into an XPC array, by transforming its non-nil elements by the provided `transformIntoXPCObject` closure,
/// and replacing `nil` values with the proper XPC null object.
/// - Parameters:
///   - sourceArray: The values to transform and pack into the XPC array
///   - transformIntoXPCObject: The closures used to transform the non-nil source elements into XPC objects
/// - Returns: an XPC array containing the transformed XPC objects
func createXPCArray<T>(from sourceArray: [T?], using transformIntoXPCObject: (T) -> xpc_object_t) -> xpc_object_t {
	let xpcArray = xpc_array_create(nil, 0)
	
	for element in sourceArray {
		let xpcObject = element.map { transformIntoXPCObject($0) } ?? xpc_null_create()
		xpc_array_append_value(xpcArray, xpcObject)
	}
	
	return xpcArray
}
