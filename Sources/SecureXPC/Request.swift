//
//  Request.swift
//  SecureXPC
//
//  Created by Josh Kaplan on 2021-11-05
//

import Foundation

/// A request sent across an XPC connection.
///
/// A request always contains a route and optionally contains a payload.
struct Request {
    private enum RequestKeys {
        static let route: XPCDictionaryKey = const("__route")
        static let payload: XPCDictionaryKey = const("__payload")
    }
    
    /// The route represented by this request.
    let route: XPCRoute
    /// Whether this request contains a payload.
    let containsPayload: Bool
    /// This request encoded as an XPC dictionary.
    ///
    /// If  `containsPayload` is `true` then `decodePayload` can be called to decode it; otherwise calling this function will result an error being thrown.
    let dictionary: xpc_object_t
}

extension Request {
    /// Represents a request that's already been encoded into an XPC dictionary.
    ///
    /// This initializer is expected to be used by the server when receiving a request which it now needs to decode.
    init(dictionary: xpc_object_t) throws {
        self.init(
            route: try XPCDecoder.decode(XPCRoute.self, from: dictionary, forKey: RequestKeys.route),
            containsPayload: try XPCDecoder.containsKey(RequestKeys.payload, inDictionary: dictionary),
            dictionary: dictionary
        )
    }

    private init(route: XPCRoute, encodedPayload: xpc_object_t?, wantsErrorHandlerReply: Bool) throws {
        let dictionary = xpc_dictionary_create(nil, nil, 0)

        let encodedRouted = try XPCEncoder.encode(route)

        if wantsErrorHandlerReply {
            xpc_dictionary_set_value(encodedRouted, "replyType", xpc_string_create(XPCRoute.errorOnlyReplyType))
        }

        xpc_dictionary_set_value(dictionary, RequestKeys.route, encodedRouted)

        if let encodedPayload = encodedPayload {
            xpc_dictionary_set_value(dictionary, RequestKeys.payload, encodedPayload)
        }

        self.init(
            route: route,
            containsPayload: encodedPayload != nil,
            dictionary: dictionary
        )
    }

    /// Represents a request without a payload which has yet to be encoded into an XPC dictionary.
    ///
    /// This initializer is expected to be used by the client in order to send a request across the XPC connection.
    init(route: XPCRoute, wantsErrorHandlerReply: Bool) throws {
        try self.init(route: route, encodedPayload: nil, wantsErrorHandlerReply: wantsErrorHandlerReply)
    }
    
    /// Represents a request with a payload which has yet to be encoded into an XPC dictionary.
    ///
    /// This initializer is expected to be used by the client in order to send a request across the XPC connection.
    init<P: Encodable>(route: XPCRoute, payload: P, wantsErrorHandlerReply: Bool) throws {
        try self.init(route: route, encodedPayload: try XPCEncoder.encode(payload), wantsErrorHandlerReply: wantsErrorHandlerReply)
    }
    
    /// Decodes the payload as the provided type.
    ///
    /// This is expected to be called from the server.
    func decodePayload<T: Decodable>(asType type: T.Type) throws -> T {
        return try XPCDecoder.decode(type, from: self.dictionary, forKey: RequestKeys.payload)
    }
}
