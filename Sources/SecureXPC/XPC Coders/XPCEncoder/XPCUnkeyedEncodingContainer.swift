//
//  XPCUnkeyedEncodingContainer.swift
//  
//
//  Created by Alexander Momchilov on 2021-11-12.
//

import Foundation

internal class XPCUnkeyedEncodingContainer : UnkeyedEncodingContainer, XPCContainer {
    /// FIX docs: Array of containers which can be later be resolved to XPC objects upon calling `encodedValue()`
	private let values = xpc_array_create(nil, 0)
    
    /// Optimized alternative to `values` which works in the case where all of the encoded values are of a guaranteed fixed length.
    ///
    /// See `supportedDataTypes` for the supported types.
    private var valuesAsData: Data? = Data()
	
	private var superEncoders = [XPCContainer]()
    
    /// The types which can be encoded directly to data. These types have a guaranteed fixed byte length for the given Mac this code is running on.
    /// Note while `UInt` and `Int` can vary in length, they'll always be the same on both sides of the XPC connection as it's local only.
    static let supportedDataTypes: [Any.Type] = [ Int.self,  Int8.self,  Int16.self,  Int32.self,  Int64.self,
                                                 UInt.self, UInt8.self, UInt16.self, UInt32.self, UInt64.self,
                                                 Float.self, Double.self, Bool.self]
    
	let codingPath: [CodingKey]

	var count: Int {
		xpc_array_get_count(self.values)
	}

	init(codingPath: [CodingKey]) {
		self.codingPath = codingPath
	}

	private func append(_ container: XPCContainer) {
		self.values.append(container)
	func encodedValue() throws -> xpc_object_t? {
        let value: xpc_object_t
        if let valuesAsData = valuesAsData { // data-backed optimization worked out, so use it
            value = valuesAsData.withUnsafeBytes { pointer in
                xpc_data_create(pointer.baseAddress, valuesAsData.count)
            }
        } else { // otherwise, fall back to creating an XPC array
            for element in self.superEncoders {
                if let elementValue = try element.encodedValue() {
					xpc_array_append_value(self.values, elementValue)
                } else {
                    let context = EncodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "This value failed to encode itself",
                                                        underlyingError: nil)
                    throw EncodingError.invalidValue(element, context)
                }
            }
			self.superEncoders.removeAll()
			
			value = self.values
        }
        
        return value
	}

	private func append(_ value: xpc_object_t) {
		xpc_array_append_value(self.values, value)
	}
    
    private func attemptDataBackedAppend<T>(_ value: T) {
        // If it's no longer possible for this container to encode all of its values directly as data due to a prior
        // encoded value, then valuesAsData will be nil
        if valuesAsData == nil {
            return
        }
        
        if XPCUnkeyedEncodingContainer.supportedDataTypes.contains(where: { $0 == T.self }) {
            var value = value
            withUnsafeBytes(of: &value) { pointer in
                let reboundPointer = pointer.bindMemory(to: UInt8.self)
                valuesAsData?.append(reboundPointer.baseAddress!, count: pointer.count)
            }
        } else { // this value can't be encoded directly as data, so nil out valuesAsData
            valuesAsData = nil
        }
    }
    
    /// Call this function if an encoding request means that data backed encoding is no longer possible, such as trying to encode `String` or requesting a
    /// container.
    private func dataBackedEncodingNoLongerPossible() {
        valuesAsData = nil
    }

	func encodeNil() {
        self.dataBackedEncodingNoLongerPossible()
		self.append(xpc_null_create())
	}

	func encode(_ value: Bool) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_bool_create(value))
	}

	func encode(_ value: String) {
        self.attemptDataBackedAppend(value)
		value.utf8CString.withUnsafeBufferPointer { stringPointer in
			// It is safe to assert the base address will never be nil as the buffer will always have data even if
			// the string is empty
			self.append(xpc_string_create(stringPointer.baseAddress!))
		}
	}

	func encode(_ value: Double) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_double_create(value))
	}

	func encode(_ value: Float) {
        self.attemptDataBackedAppend(value)
        
		// Float.signalingNaN is not converted to Double.signalingNaN when calling Double(...) with a Float so this
		// needs to be done manually
		let doubleValue = value.isSignalingNaN ? Double.signalingNaN : Double(value)
		self.append(xpc_double_create(doubleValue))
	}

	func encode(_ value: Int) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int8) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int16) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int32) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_int64_create(Int64(value)))
	}

	func encode(_ value: Int64) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_int64_create(value))
	}

	func encode(_ value: UInt) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt8) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt16) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt32) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_uint64_create(UInt64(value)))
	}

	func encode(_ value: UInt64) {
        self.attemptDataBackedAppend(value)
		self.append(xpc_uint64_create(value))
	}

	func encode<T: Encodable>(_ value: T) throws {
        self.attemptDataBackedAppend(value)
        
		let encoder = XPCEncoderImpl(codingPath: self.codingPath)
		try value.encode(to: encoder)
		
		let encodedValue = try encoder.encodedValue()!
		self.append(encodedValue)
	}

	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        self.dataBackedEncodingNoLongerPossible()
        
		let nestedContainer = XPCKeyedEncodingContainer<NestedKey>(codingPath: self.codingPath)
		self.append(nestedContainer.values)

		return KeyedEncodingContainer(nestedContainer)
	}

	func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.dataBackedEncodingNoLongerPossible()
        
		let nestedUnkeyedContainer = XPCUnkeyedEncodingContainer(codingPath: self.codingPath)
		self.append(nestedUnkeyedContainer.values)

		return nestedUnkeyedContainer
	}

	func superEncoder() -> Encoder {
        self.dataBackedEncodingNoLongerPossible()
        
		let encoder = XPCEncoderImpl(codingPath: self.codingPath)
		
		// FIXME: This fucks up the ordering of the resulting array.
		// FIXME: None of the existing tests caught this.
		self.superEncoders.append(encoder)

		return encoder
	}
}
