//
//  XPCSingleValueEncodingContainer.swift
//  
//
//  Created by Alexander Momchilov on 2021-11-12.
//

import Foundation

internal class XPCSingleValueEncodingContainer: SingleValueEncodingContainer, XPCContainer {
	private var value: xpc_object_t?
	private var nestedEncoder: XPCEncoderImpl?
	var codingPath: [CodingKey]

	init(codingPath: [CodingKey]) {
		self.codingPath = codingPath
	}

	func encodedValue() throws -> xpc_object_t? {
		if let nestedEncoder = nestedEncoder {
			self.value = try nestedEncoder.encodedValue()
			self.nestedEncoder = nil
		}
		
		return self.value
	}

	private func setValue(_ value: xpc_object_t) {
		self.value = value
	}

	func encodeNil() {
		self.setValue(xpc_null_create())
	}

	func encode(_ value: Bool) {
		self.setValue(xpc_bool_create(value))
	}

	func encode(_ value: String) {
		value.utf8CString.withUnsafeBufferPointer { stringPointer in
			// It is safe to assert the base address will never be nil as the buffer will always have data even if
			// the string is empty
			self.setValue(xpc_string_create(stringPointer.baseAddress!))
	   }
	}

	func encode(_ value: Double) {
		self.setValue(xpc_double_create(value))
	}

	func encode(_ value: Float) {
		// Float.signalingNaN is not converted to Double.signalingNaN when calling Double(...) with a Float so this
		// needs to be done manually
		let doubleValue = value.isSignalingNaN ? Double.signalingNaN : Double(value)
		self.setValue(xpc_double_create(doubleValue))
	}

	func encode(_ value: Int) {
		self.setValue(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int8) {
		self.setValue(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int16) {
		self.setValue(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int32) {
		self.setValue(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int64) {
		self.setValue(xpc_int64_create(value))
	}

	func encode(_ value: UInt) {
		self.setValue(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt8) {
		self.setValue(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt16) {
		self.setValue(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt32) {
		self.setValue(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt64) {
		self.setValue(xpc_uint64_create(value))
	}

	func encode<T: Encodable>(_ value: T) throws {
		let encoder = XPCEncoderImpl(codingPath: self.codingPath)
		self.nestedEncoder = encoder

		try value.encode(to: encoder)
	}
}
