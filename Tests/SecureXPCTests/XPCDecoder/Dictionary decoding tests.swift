//
//  Dictinary encoding tests.swift
//
//
//  Created by Alexander Momchilov on 2021-11-03.
//

import XCTest
@testable import SecureXPC

final class XPCDecoder_DictionaryEncodingTests: XCTestCase {
	// MARK: Signed Integers
	
	func testDecodes_dictOf_SignedIntegers_asDictOf_XPCInts() throws {
		let dictOfInt:   [String: Int  ] = ["int"  : 123]
		let dictOfInt8:  [String: Int8 ] = ["int8" : 123]
		let dictOfInt16: [String: Int16] = ["int16": 123]
		let dictOfInt32: [String: Int32] = ["int32": 123]
		let dictOfInt64: [String: Int64] = ["int64": 123]
		
		try assert(createXPCDict(from:   dictOfInt, using: { xpc_int64_create(Int64($0)) }), decodesEqualTo:   dictOfInt)
		try assert(createXPCDict(from:  dictOfInt8, using: { xpc_int64_create(Int64($0)) }), decodesEqualTo:  dictOfInt8)
		try assert(createXPCDict(from: dictOfInt16, using: { xpc_int64_create(Int64($0)) }), decodesEqualTo: dictOfInt16)
		try assert(createXPCDict(from: dictOfInt32, using: { xpc_int64_create(Int64($0)) }), decodesEqualTo: dictOfInt32)
		try assert(createXPCDict(from: dictOfInt64, using: { xpc_int64_create(Int64($0)) }), decodesEqualTo: dictOfInt64)
	}
	
	func testDecodes_dictOf_UnsignedIntegers_asDictOf_XPCUInts() throws {
		let dictOfUInt:   [String: UInt  ] = ["uint"  : 123]
		let dictOfUInt8:  [String: UInt8 ] = ["uint8" : 123]
		let dictOfUInt16: [String: UInt16] = ["uint16": 123]
		let dictOfUInt32: [String: UInt32] = ["uint32": 123]
		let dictOfUInt64: [String: UInt64] = ["uint64": 123]
		
		try assert(createXPCDict(from:   dictOfUInt, using: { xpc_uint64_create(UInt64($0)) }), decodesEqualTo:   dictOfUInt)
		try assert(createXPCDict(from:  dictOfUInt8, using: { xpc_uint64_create(UInt64($0)) }), decodesEqualTo:  dictOfUInt8)
		try assert(createXPCDict(from: dictOfUInt16, using: { xpc_uint64_create(UInt64($0)) }), decodesEqualTo: dictOfUInt16)
		try assert(createXPCDict(from: dictOfUInt32, using: { xpc_uint64_create(UInt64($0)) }), decodesEqualTo: dictOfUInt32)
		try assert(createXPCDict(from: dictOfUInt64, using: { xpc_uint64_create(UInt64($0)) }), decodesEqualTo: dictOfUInt64)
	}
	
	// MARK: Floating point numbers
	
	func testDecodes_dictOf_Floats_asDictOf_XPCDoubles() throws {
		func floatToXPCDouble(_ input: Float) -> xpc_object_t {
			xpc_double_create(Double(input))
		}

		let dictOfFloats: [String: Float] = [
			"-infinity": -.infinity,
			"-greatestFiniteMagnitude": -.greatestFiniteMagnitude,
			"-123": -123,
			"-leastNormalMagnitude": -.leastNormalMagnitude,
			"-leastNonzeroMagnitude": -.leastNonzeroMagnitude,
			"-0.0": -0.0,
			"0.0": 0.0,
			"leastNonzeroMagnitude": -.leastNonzeroMagnitude,
			"leastNormalMagnitude": -.leastNormalMagnitude,
			"123": 123,
			"greatestFiniteMagnitude": .greatestFiniteMagnitude,
			"infinity": .infinity,
		]

		try assert(createXPCDict(from: dictOfFloats, using: floatToXPCDouble), decodesEqualTo: dictOfFloats)

		// These don't have regular equality, so we'll check them seperately.
		let nans: [Float] = try decode(createXPCDict(from: [
			"nan": Float.nan,
			"signalingNaN": Float.signalingNaN
		], using: floatToXPCDouble))
		XCTAssertEqual(nans.count, 2)
		XCTAssert(nans[0].isNaN)
		XCTAssert(nans[1].isNaN)
	}

	func testDecodes_dictOf_Doubles_asDictOf_XPCDoubles() throws {
		let dictOfDoubles: [String: Double] = [
			"-infinity": -.infinity,
			"-greatestFiniteMagnitude": -.greatestFiniteMagnitude,
			"-123": -123,
			"-leastNormalMagnitude": -.leastNormalMagnitude,
			"-leastNonzeroMagnitude": -.leastNonzeroMagnitude,
			"-0.0": -0.0,
			"0.0": 0.0,
			"leastNonzeroMagnitude": -.leastNonzeroMagnitude,
			"leastNormalMagnitude": -.leastNormalMagnitude,
			"123": 123,
			"greatestFiniteMagnitude": .greatestFiniteMagnitude,
			"infinity": .infinity,
		]

		try assert(createXPCDict(from: dictOfDoubles, using: xpc_double_create), decodesEqualTo: dictOfDoubles)

		// These don't have regular equality, so we'll check them seperately.
		let nans: [Double] = try decode(createXPCDict(from: [
			"nan": Double.nan,
			"signalingNaN": Double.signalingNaN
		], using: xpc_double_create))
		XCTAssertEqual(nans.count, 2)
		XCTAssert(nans[0].isNaN)
		XCTAssert(nans[1].isNaN)
	}
//
//	// MARK: Misc. types
//
//	func testDecodes_dictOf_Bools_asDictOf_XPCBools() throws {
//		let bools: [String: Bool?] = ["false": false, "true": true, "nil": nil]
//		try assert(bools, decodesEqualTo: createXPCDict(from: bools, using: xpc_bool_create))
//	}
//
//	func testDecodes_dictOf_Strings_asDictOf_XPCStrings() throws {
//		let strings: [String: String] = ["empty": "", "string": "Hello, world!"]
//		try assert(strings, decodesEqualTo: createXPCDict(from: strings, using: { str in
//			str.withCString(xpc_string_create)
//		}))
//	}
//
//	func testDecodes_dictsOf_Nils() throws {
//		// Signed integers
//		let dictOfInt:   [String: Optional<Int  >] = ["int"  : 123, "nil": nil]
//		let dictOfInt8:  [String: Optional<Int8 >] = ["int8" : 123, "nil": nil]
//		let dictOfInt16: [String: Optional<Int16>] = ["int16": 123, "nil": nil]
//		let dictOfInt32: [String: Optional<Int32>] = ["int32": 123, "nil": nil]
//		let dictOfInt64: [String: Optional<Int64>] = ["int64": 123, "nil": nil]
//
//		try assert(  dictOfInt, decodesEqualTo: createXPCDict(from:   dictOfInt, using: { xpc_int64_create(Int64($0)) }))
//		try assert( dictOfInt8, decodesEqualTo: createXPCDict(from:  dictOfInt8, using: { xpc_int64_create(Int64($0)) }))
//		try assert(dictOfInt16, decodesEqualTo: createXPCDict(from: dictOfInt16, using: { xpc_int64_create(Int64($0)) }))
//		try assert(dictOfInt32, decodesEqualTo: createXPCDict(from: dictOfInt32, using: { xpc_int64_create(Int64($0)) }))
//		try assert(dictOfInt64, decodesEqualTo: createXPCDict(from: dictOfInt64, using: { xpc_int64_create(Int64($0)) }))
//
//		let dictOfUInt:   [String: Optional<UInt  >] = ["uint"  : 123, "nil": nil]
//		let dictOfUInt8:  [String: Optional<UInt8 >] = ["uint8" : 123, "nil": nil]
//		let dictOfUInt16: [String: Optional<UInt16>] = ["uint16": 123, "nil": nil]
//		let dictOfUInt32: [String: Optional<UInt32>] = ["uint32": 123, "nil": nil]
//		let dictOfUInt64: [String: Optional<UInt64>] = ["uint64": 123, "nil": nil]
//
//		try assert(  dictOfUInt, decodesEqualTo: createXPCDict(from:   dictOfUInt, using: { xpc_uint64_create(UInt64($0)) }))
//		try assert( dictOfUInt8, decodesEqualTo: createXPCDict(from:  dictOfUInt8, using: { xpc_uint64_create(UInt64($0)) }))
//		try assert(dictOfUInt16, decodesEqualTo: createXPCDict(from: dictOfUInt16, using: { xpc_uint64_create(UInt64($0)) }))
//		try assert(dictOfUInt32, decodesEqualTo: createXPCDict(from: dictOfUInt32, using: { xpc_uint64_create(UInt64($0)) }))
//		try assert(dictOfUInt64, decodesEqualTo: createXPCDict(from: dictOfUInt64, using: { xpc_uint64_create(UInt64($0)) }))
//
//		// Floating point numbers
//		let floats: [String: Float?] = ["float": 123, "nil": nil]
//		try assert(floats, decodesEqualTo: createXPCDict(from: floats, using: { xpc_double_create(Double($0)) }))
//		let doubles: [String: Double?] = ["double": 123, "nil": nil]
//		try assert(doubles, decodesEqualTo: createXPCDict(from: doubles, using: { xpc_double_create($0) }))
//
//		// Misc. types
//
//		let bools: [String: Bool?] = ["false": false, "true": true, "nil": nil]
//		try assert(bools, decodesEqualTo: createXPCDict(from: bools, using: xpc_bool_create))
//
//		let strings: [String: String?] = ["empty": "", "string": "Hello, world!", "nil": nil]
//		try assert(strings, decodesEqualTo: createXPCDict(from: strings, using: { str in
//			str.withCString(xpc_string_create)
//		}))
//	}
//
//	// MARK: Dictionaries of aggregates
//
//	func testDecode_dictOf_Arrays() throws {
//		// There's too many possible permutations, but it should be satisfactory to just test one kind of nesting.
//		let dictOfArrays: [String: [Int64]] = [
//			"a1": [1, 2, 3],
//			"a2": [4, 5, 6],
//		]
//
//		let expectedXPCDict = createXPCDict(from: dictOfArrays, using: { array in
//			createXPCArray(from: array, using: xpc_int64_create)
//		})
//
//		try assert(dictOfArrays, decodesEqualTo: expectedXPCDict)
//	}
//
//	func testDecode_dictOf_Dicts() throws {
//		// There's too many possible permutations, but it should be satisfactory to just test one kind of nesting.
//		let dictOfDicts: [String: [String: Int64]] = [
//			"d1": ["a": 1, "b": 2, "c": 3],
//			"d2": ["d": 4, "e": 5, "f": 6],
//		]
//
//		let expectedXPCDict = createXPCDict(from: dictOfDicts, using: { subDict in
//			createXPCDict(from: subDict, using: xpc_int64_create)
//		})
//
//		try assert(dictOfDicts, decodesEqualTo: expectedXPCDict)
//	}
}

