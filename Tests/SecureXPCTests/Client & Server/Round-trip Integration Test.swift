//
//  Round-trip Integration Test.swift
//  
//
//  Created by Alexander Momchilov on 2021-11-28.
//

import XCTest
import SecureXPC

class RoundTripIntegrationTest: XCTestCase {
    var xpcClient: XPCClient! = nil


    let anonymousServer = XPCServer.newAnonymousService()

    override func setUp() {
        let endpoint = anonymousServer.endpoint
        xpcClient = XPCClient.forEndpoint(endpoint)
    }

    func testSendWithMessageWithReply() throws {
        let remoteHandlerWasCalled = self.expectation(description: "The remote handler was called")
        let replyBlockWasCalled = self.expectation(description: "The echo reply was received")

        let echoRoute = XPCRouteWithMessageWithReply("echo", messageType: String.self, replyType: String.self)
        anonymousServer.registerRoute(echoRoute) { msg in
            remoteHandlerWasCalled.fulfill()
            return "echo: \(msg)"
        }

        try self.xpcClient.sendMessage("Hello, world!", route: echoRoute) { result in
            XCTAssertNoThrow {
                let response = try result.get()
                XCTAssertEqual(response, "echo: Hello, world!")
            }

            replyBlockWasCalled.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testSendWithoutMessageWithReply() throws {
        let remoteHandlerWasCalled = self.expectation(description: "The remote handler was called")
        let replyBlockWasCalled = self.expectation(description: "The pong reply was received")

        let pingRoute = XPCRouteWithoutMessageWithReply("ping", replyType: String.self)
        anonymousServer.registerRoute(pingRoute) {
            remoteHandlerWasCalled.fulfill()
            return "pong"
        }

        try self.xpcClient.send(route: pingRoute) { result in
            XCTAssertNoThrow {
                let response = try result.get()
                XCTAssertEqual(response, "pong")
            }

            replyBlockWasCalled.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testSendWithMessageWithoutReply() throws {
        let remoteHandlerWasCalled = self.expectation(description: "The remote handler was called")

        let msgNoReplyRoute = XPCRouteWithMessageWithoutReply("msgNoReplyRoute", messageType: String.self)
        anonymousServer.registerRoute(msgNoReplyRoute) { msg in
            XCTAssertEqual(msg, "Hello, world!")
            remoteHandlerWasCalled.fulfill()
        }

        try self.xpcClient.sendMessage("Hello, world!", route: msgNoReplyRoute)

        self.waitForExpectations(timeout: 1)
    }

    func testSendWithoutMessageWithoutReply() throws {
        let remoteHandlerWasCalled = self.expectation(description: "The remote handler was called")

        let noMsgNoReplyRoute = XPCRouteWithoutMessageWithoutReply("noMsgNoReplyRoute")
        anonymousServer.registerRoute(noMsgNoReplyRoute) {
            remoteHandlerWasCalled.fulfill()
        }

        try self.xpcClient.send(route: noMsgNoReplyRoute)

        self.waitForExpectations(timeout: 1)
    }

    func testRouteDoesntExist() throws {
        let routes = (
            withMessage: (
                withReply: XPCRouteWithMessageWithReply("does not exist", messageType: String.self, replyType: String.self),
                withoutReply: XPCRouteWithMessageWithoutReply("does not exist", messageType: String.self)
            ),
            withoutMessage: (
                withReply: XPCRouteWithoutMessageWithReply("does not exist", replyType: String.self),
                withoutReply: XPCRouteWithoutMessageWithoutReply("does not exist")
            )
        )

        func assertNoReply(result: Result<String, XPCError>) {
//            XCTAssertNoThrow(
//                try {
//                    switch result {
//                    case .success(_): XCTFail("We expected to get an error result back, because this route shouldn't exist.")
//                    case .failure(XPCError.routeNotRegistered(_)): return
//                    case .failure(let e): XCTFail("We expected to get an error result back, because this route shouldn't exist.") // unexpected error type
//                    }
//                }()
//            )
        }



        try self.xpcClient.sendMessage("foo", route: routes.withMessage.withReply, withReply: assertNoReply)
        try self.xpcClient.send(route: routes.withoutMessage.withReply, withReply: assertNoReply)

        // `routes.withMessage.withoutReply` and `routes.withoutMessage.withoutReply` can't currently be tested
        // because they don't expect a reply, thus, there's no way to recieve an error back from the server.
    }
}
