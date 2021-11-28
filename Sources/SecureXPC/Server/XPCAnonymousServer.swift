//
//  XPCAnonymousServer.swift
//  
//
//  Created by Alexander Momchilov on 2021-11-28.
//

import Foundation

internal class XPCAnonymousServer: XPCServer {
    private let anonymousListenerConnection: xpc_connection_t

    internal override init() {
        self.anonymousListenerConnection = xpc_connection_create(nil, nil)
        super.init()

        // Start listener for the new anonymous connection, all received events should be for incoming client connections
         xpc_connection_set_event_handler(anonymousListenerConnection, { newClientConnection in
             // Listen for events (messages or errors) coming from this connection
             xpc_connection_set_event_handler(newClientConnection, { event in
                 self.handleEvent(connection: newClientConnection, event: event)
             })
             xpc_connection_resume(newClientConnection)
         })
         xpc_connection_resume(anonymousListenerConnection)
    }

    public override func start() -> Never {
        fatalError("Anonymous services don't need to be `start()`ed.")
    }

    internal override func acceptMessage(connection: xpc_connection_t, message: xpc_object_t) -> Bool {
        // Anonymous service connections should only ever passed among trusted parties.
        true
    }

    public override var endpoint: XPCServerEndpoint {
        XPCServerEndpoint(
            kind: .anonymousClient,
            serviceName: nil,
            endpoint: xpc_endpoint_create(self.anonymousListenerConnection)
        )
    }
}
