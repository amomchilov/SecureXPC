//
//  XPCDecoder.swift
//  SecureXPC
//
//  Created by Josh Kaplan on 2021-10-09
//

import Foundation

/// Package internal entry point to decoding as well as checking for the presence of keys in an XPC dictionary.
enum XPCDecoder {
    
    /// Whether the provided XPC dictionary contains the key.
    ///
    /// - Parameters:
    ///   - _:  The key to be checked.
    ///   - dictionary: The XPC dictionary to check for the XPC key in.
    /// - Throws: If the value provided was not an XPC dictionary.
    /// - Returns: Whether the key is contained in the provided dictionary.
    static func containsKey(_ key: XPCDictionaryKey, inDictionary dictionary: xpc_object_t) throws -> Bool {
        try checkXPCDictionary(object: dictionary)
        
        return xpc_dictionary_get_value(dictionary, key) != nil
    }
    
    /// Decodes the value corresponding to the key in the XPC dictionary.
    ///
    /// - Parameters:
    ///  - _: The type to decode the XPC representation to.
    ///  - from: The XPC dictionary containing the value to decode.
    ///  - forKey: The key of the value in the XPC dictionary.
    /// - Throws: If `from` isn't a dictionary, the `key` isn't present in the dictionary, or the decoding fails.
    /// - Returns: An instance of the provided type corresponding to the contents of the value for the provided key.
    static func decode<T: Decodable>(_ type: T.Type,
                                     from dictionary: xpc_object_t,
                                     forKey key: XPCDictionaryKey) throws -> T {
        try checkXPCDictionary(object: dictionary)

		guard let decodedValue = try self.decodeIfPresent(type, from: dictionary, forKey: key) else {
			// Ideally this would throw DecodingError.keyNotFound(...) but that requires providing a CodingKey
			// and there isn't one yet
			let context = DecodingError.Context(codingPath: [CodingKey](),
												debugDescription: "Key not present: \(key)",
												underlyingError: nil)
			throw DecodingError.valueNotFound(type, context)
		}

		return decodedValue
    }

	/// Decodes the value corresponding to the key in the XPC dictionary, if present.
	///
	/// - Parameters:
	///  - _: The type to decode the XPC representation to.
	///  - from: The XPC dictionary containing the value to decode.
	///  - forKey: The key of the value in the XPC dictionary.
	/// - Throws: If `from` isn't a dictionary, the `key` isn't present in the dictionary, or the decoding fails.
	/// - Returns: An instance of the provided type corresponding to the contents of the value for the provided key.
	static func decodeIfPresent<T: Decodable>(_ type: T.Type,
									 from dictionary: xpc_object_t,
									 forKey key: XPCDictionaryKey) throws -> T? {
		try checkXPCDictionary(object: dictionary)

		guard let value = xpc_dictionary_get_value(dictionary, key) else { return nil }

		return try decode(type, object: value)
	}
    
    /// Decodes the XPC object.
    ///
    /// - Parameters:
    ///  - _: The type to decode the XPC representation to.
    ///  - object: The XPC object.
    /// - Throws: If decoding fails.
    /// - Returns: An instance of the provided type corresponding to the object.
    static func decode<T: Decodable>(_ type: T.Type, object: xpc_object_t) throws -> T {
        return try T(from: XPCDecoderImpl(value: object, codingPath: [CodingKey]()))
    }
    
    /// Throws an error if the provided XPC object is not an XPC dictionary.
    private static func checkXPCDictionary(object: xpc_object_t) throws {
        let type = xpc_get_type(object)
        if type != XPC_TYPE_DICTIONARY {
            let context = DecodingError.Context(codingPath: [CodingKey](),
                                                debugDescription: "XPC dictionary required; was \(type.description)",
                                                underlyingError: nil)
            throw DecodingError.typeMismatch(xpc_object_t.self, context)
        }
    }
}
