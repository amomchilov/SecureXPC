import XCTest
@testable import SecureXPC

final class XPCDecoder_ScalarDecodingTests: XCTestCase {
	// MARK: TODO:
	// 1. file descriptors
	// 2. shared memory regions
	// 3. DispatchData
	// 4. xpc_endpoint_t
	// 5. xpc_activity_t?
	
	// MARK: Signed Integers
	
	func testDecodes_XPCInt64_as_Int() throws {
		try assert(xpc_int64_create(Int64(Int.min)), decodesEqualTo: .min as Int)
		try assert(xpc_int64_create(          -123), decodesEqualTo: -123 as Int)
		try assert(xpc_int64_create(             0), decodesEqualTo:    0 as Int)
		try assert(xpc_int64_create(           123), decodesEqualTo:  123 as Int)
		try assert(xpc_int64_create(Int64(Int.max)), decodesEqualTo: .max as Int)
	}
	
	func testDecodes_XPCInt64_as_Int8() throws {
		try assert(xpc_int64_create(Int64(Int8.min)), decodesEqualTo: .min as Int8)
		try assert(xpc_int64_create(           -123), decodesEqualTo: -123 as Int8)
		try assert(xpc_int64_create(              0), decodesEqualTo:    0 as Int8)
		try assert(xpc_int64_create(            123), decodesEqualTo:  123 as Int8)
		try assert(xpc_int64_create(Int64(Int8.max)), decodesEqualTo: .max as Int8)
	}
	
	func testDecodes_XPCInt64_as_Int16() throws {
		try assert(xpc_int64_create(Int64(Int16.min)), decodesEqualTo: .min as Int16)
		try assert(xpc_int64_create(            -123), decodesEqualTo: -123 as Int16)
		try assert(xpc_int64_create(               0), decodesEqualTo:    0 as Int16)
		try assert(xpc_int64_create(             123), decodesEqualTo:  123 as Int16)
		try assert(xpc_int64_create(Int64(Int16.max)), decodesEqualTo: .max as Int16)
	}
	
	func testDecodes_XPCInt64_as_Int32() throws {
		try assert(xpc_int64_create(Int64(Int32.min)), decodesEqualTo: .min as Int32)
		try assert(xpc_int64_create(            -123), decodesEqualTo: -123 as Int32)
		try assert(xpc_int64_create(               0), decodesEqualTo:    0 as Int32)
		try assert(xpc_int64_create(             123), decodesEqualTo:  123 as Int32)
		try assert(xpc_int64_create(Int64(Int32.max)), decodesEqualTo: .max as Int32)
	}
	
	func testDecodes_XPCInt64_as_Int64() throws {
		try assert(xpc_int64_create(Int64(Int64.min)), decodesEqualTo: .min as Int64)
		try assert(xpc_int64_create(            -123), decodesEqualTo: -123 as Int64)
		try assert(xpc_int64_create(               0), decodesEqualTo:    0 as Int64)
		try assert(xpc_int64_create(             123), decodesEqualTo:  123 as Int64)
		try assert(xpc_int64_create(Int64(Int64.max)), decodesEqualTo: .max as Int64)
	}
	
	// MARK: Unsigned Integers
	
	func testDecodes_XPCUInt64_as_UInt() throws {
		try assert(xpc_uint64_create(UInt64(UInt.min)), decodesEqualTo: .min as UInt)
		try assert(xpc_uint64_create(               0), decodesEqualTo:    0 as UInt)
		try assert(xpc_uint64_create(             123), decodesEqualTo:  123 as UInt)
		try assert(xpc_uint64_create(UInt64(UInt.max)), decodesEqualTo: .max as UInt)
	}
	
	func testDecodes_XPCUInt64_as_UInt8() throws {
		try assert(xpc_uint64_create(UInt64(UInt8.min)), decodesEqualTo: .min as UInt8)
		try assert(xpc_uint64_create(                0), decodesEqualTo:    0 as UInt8)
		try assert(xpc_uint64_create(              123), decodesEqualTo:  123 as UInt8)
		try assert(xpc_uint64_create(UInt64(UInt8.max)), decodesEqualTo: .max as UInt8)
	}
	
	func testDecodes_XPCUInt64_as_UInt16() throws {
		try assert(xpc_uint64_create(UInt64(UInt16.min)), decodesEqualTo: .min as UInt16)
		try assert(xpc_uint64_create(                 0), decodesEqualTo:    0 as UInt16)
		try assert(xpc_uint64_create(               123), decodesEqualTo:  123 as UInt16)
		try assert(xpc_uint64_create(UInt64(UInt16.max)), decodesEqualTo: .max as UInt16)
	}
	
	func testDecodes_XPCUInt64_as_UInt32() throws {
		try assert(xpc_uint64_create(UInt64(UInt32.min)), decodesEqualTo: .min as UInt32)
		try assert(xpc_uint64_create(                 0), decodesEqualTo:    0 as UInt32)
		try assert(xpc_uint64_create(               123), decodesEqualTo:  123 as UInt32)
		try assert(xpc_uint64_create(UInt64(UInt32.max)), decodesEqualTo: .max as UInt32)
	}
	
	func testDecodes_XPCUInt64_as_UInt64() throws {
		try assert(xpc_uint64_create(UInt64(UInt64.min)), decodesEqualTo: .min as UInt64)
		try assert(xpc_uint64_create(                 0), decodesEqualTo:    0 as UInt64)
		try assert(xpc_uint64_create(               123), decodesEqualTo:  123 as UInt64)
		try assert(xpc_uint64_create(UInt64(UInt64.max)), decodesEqualTo: .max as UInt64)
	}
	
	// MARK: Floating point numbers
	
	func testDecodes_XPCDouble_as_Float() throws {
		// "Normal" values, from lowest to highest
		try assert(xpc_double_create(Double(-Float.infinity)),                decodesEqualTo: -Float.infinity)
		try assert(xpc_double_create(Double(-Float.greatestFiniteMagnitude)), decodesEqualTo: -Float.greatestFiniteMagnitude)
		try assert(xpc_double_create(Double(-Float.leastNormalMagnitude)),    decodesEqualTo: -Float.leastNormalMagnitude)
		try assert(xpc_double_create(Double(-Float.leastNonzeroMagnitude)),   decodesEqualTo: -Float.leastNonzeroMagnitude)
		try assert(xpc_double_create(-123.0),                                 decodesEqualTo: -123.0 as Float)
		try assert(xpc_double_create(-0.0),                                   decodesEqualTo: -0.0 as Float)
		try assert(xpc_double_create(0.0),                                    decodesEqualTo: 0.0 as Float)
		try assert(xpc_double_create(123.0),                                  decodesEqualTo: 123.0 as Float)
		try assert(xpc_double_create(Double(Float.leastNonzeroMagnitude)),    decodesEqualTo: Float.leastNonzeroMagnitude)
		try assert(xpc_double_create(Double(Float.leastNormalMagnitude)),     decodesEqualTo: Float.leastNormalMagnitude)
		try assert(xpc_double_create(Double(Float.greatestFiniteMagnitude)),  decodesEqualTo: Float.greatestFiniteMagnitude)
		try assert(xpc_double_create(Double(Float.infinity)),                 decodesEqualTo: Float.infinity)

		// NaN
		let result = try decode(xpc_double_create(Double(Float.nan))) as Float
		XCTAssert(result.isNaN)
	}

	func testDecodes_XPCDouble_SignalingNaN_as_Float_QuietNaN() throws {
		let result = try decode(xpc_double_create(Double(Float.signalingNaN))) as Float
		XCTAssert(result.isNaN)
		// IDK if this is intended or acceptable, but `Double(Float.signalingNaN).isSignalingNaN` returns `false`
		XCTAssertFalse(result.isSignalingNaN)
	}

	func testDecodes_XPCDouble_as_Double() throws {
		// "Normal" values, from lowest to highest
		try assert(xpc_double_create(-Double.infinity),                decodesEqualTo: -Double.infinity)
		try assert(xpc_double_create(-Double.greatestFiniteMagnitude), decodesEqualTo: -Double.greatestFiniteMagnitude)
		try assert(xpc_double_create(-Double.leastNormalMagnitude),    decodesEqualTo: -Double.leastNormalMagnitude)
		try assert(xpc_double_create(-Double.leastNonzeroMagnitude),   decodesEqualTo: -Double.leastNonzeroMagnitude)
		try assert(xpc_double_create(-123.0),                          decodesEqualTo: -123.0 as Double)
		try assert(xpc_double_create(-0.0),                            decodesEqualTo: -0.0 as Double)
		try assert(xpc_double_create(0.0),                             decodesEqualTo: 0.0 as Double)
		try assert(xpc_double_create(123.0),                           decodesEqualTo: 123.0 as Double)
		try assert(xpc_double_create(Double.leastNonzeroMagnitude),    decodesEqualTo: Double.leastNonzeroMagnitude)
		try assert(xpc_double_create(Double.leastNormalMagnitude),     decodesEqualTo: Double.leastNormalMagnitude)
		try assert(xpc_double_create(Double.greatestFiniteMagnitude),  decodesEqualTo: Double.greatestFiniteMagnitude)
		try assert(xpc_double_create(Double.infinity),                 decodesEqualTo: Double.infinity)

		// NaN
		let result = try decode(xpc_double_create(Double.nan)) as Double
		XCTAssert(result.isNaN)
	}

	func testDecodes_XPCDouble_SignalingNaN_as_Double_SignalingNaN() throws {
		let result = try decode(xpc_double_create(Double.signalingNaN)) as Double
		XCTAssert(result.isNaN)
		XCTAssert(result.isSignalingNaN)
	}
	
	// MARK: Misc. types
	
	func testDecodes_XPCBool_as_Bool() throws {
		try assert(xpc_bool_create(false), decodesEqualTo: false)
		try assert(xpc_bool_create(true),  decodesEqualTo:  true)
		try assert(XPC_BOOL_FALSE,         decodesEqualTo: false)
		try assert(XPC_BOOL_TRUE,          decodesEqualTo:  true)
	}
	
	func testDecodes_XPCData_as_Data() throws { // 💾
		let emptyData = Data()
		
		try emptyData.withUnsafeBytes { buffer in
			try assert(xpc_data_create(buffer.baseAddress!, buffer.count), decodesEqualTo: emptyData)
		}
		
		let sampleData = "Hello, world!".data(using: .utf8)!
		
		try sampleData.withUnsafeBytes { buffer in
			try assert(xpc_data_create(buffer.baseAddress!, buffer.count), decodesEqualTo: sampleData)
		}
	}
	
	func testDecodes_XPCDate_as_Date() throws { // 📆
		let y2kSecondsSinceEpoch: Double    = 946_684_800
		let y2KNanosecondsSinceEpoch: Int64 = 946_684_800_000_000_000
		let y2k = Date(timeIntervalSince1970: y2kSecondsSinceEpoch)
		// Round to the nearest second so we don't have any division precision issues to worry about
		let now = Date(timeIntervalSince1970: (Date().timeIntervalSince1970 * 1e9).rounded(.up) / 1e9)
		let nowNanoSecondsSinceEpoch = now.timeIntervalSince1970 * 1e9
		
		// TODO: the conversion from Double to Int64 might cause some rounding that we'd need to account for here
//		try assert(xpc_date_create(Int64(Date.distantPast  .timeIntervalSince1970)), decodesEqualTo: Date.distantPast  )
		try assert(xpc_date_create(                     y2KNanosecondsSinceEpoch ), decodesEqualTo: y2k               )
		try assert(xpc_date_create(Int64(                nowNanoSecondsSinceEpoch)), decodesEqualTo: now               )
//		try assert(xpc_date_create(Int64(Date.distantFuture.timeIntervalSince1970)), decodesEqualTo: Date.distantFuture)
	}

	func testDecodes_XPCString_as_String() throws {
		try assert(xpc_string_create(""), decodesEqualTo: "")
		try assert(xpc_string_create("Hello, world!"), decodesEqualTo: "Hello, world!")
	}
	
	func testDecodes_XPCUUID_as_UUID() throws {
		let expectedUUID = UUID(uuidString: "34933b03-769c-4e50-a44a-5335f584aa9a")!
		
		// If you squint a little, you can see it's the same as the string above ;)
		let sampleXPCUUID = xpc_uuid_create([
			0x34,0x93,0x3b,0x03, // -
			0x76,0x9c, // -
			0x4e,0x50, // -
			0xa4,0x4a, // -
			0x53,0x35,0xf5,0x84,0xaa,0x9a,
		])
		
		try assert(sampleXPCUUID, decodesEqualTo: expectedUUID)
	}
	
	func testDecodes_XPCNull_as_NilValues() throws {
		let xpcNull = xpc_null_create()
		
		// Signed integers
		try assert(xpcNull, decodesEqualTo: nil as Int?)
		try assert(xpcNull, decodesEqualTo: nil as Int8?)
		try assert(xpcNull, decodesEqualTo: nil as Int16?)
		try assert(xpcNull, decodesEqualTo: nil as Int32?)
		try assert(xpcNull, decodesEqualTo: nil as Int64?)
		
		// Unsigned integers
		try assert(xpcNull, decodesEqualTo: nil as UInt?)
		try assert(xpcNull, decodesEqualTo: nil as UInt8?)
		try assert(xpcNull, decodesEqualTo: nil as UInt16?)
		try assert(xpcNull, decodesEqualTo: nil as UInt32?)
		try assert(xpcNull, decodesEqualTo: nil as UInt64?)
		
		// Floating point numbers
		try assert(xpcNull, decodesEqualTo: nil as Float?)
		try assert(xpcNull, decodesEqualTo: nil as Double?)
		
		// Misc. types
		try assert(xpcNull, decodesEqualTo: nil as Bool?)
		try assert(xpcNull, decodesEqualTo: nil as Data?) // 💾
		try assert(xpcNull, decodesEqualTo: nil as Date?) // 📆
		try assert(xpcNull, decodesEqualTo: nil as String?)
		try assert(xpcNull, decodesEqualTo: nil as UUID?)
	}
}
