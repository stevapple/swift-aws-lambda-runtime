//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2021 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import AWSLambdaRuntimeCore
@testable import TestUtils
import NIOCore
import XCTest

class LambdaHandlerTest: XCTestCase {

    // MARK: - EventLoopLambdaHandler

    func testEventLoopSuccess() {
        let server = MockLambdaServer(behavior: SimpleBehavior())
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct Handler: EventLoopLambdaHandler {
            typealias Event = String
            typealias Output = String

            func handle(_ event: String, context: Lambda.Context) -> EventLoopFuture<String> {
                context.eventLoop.makeSucceededFuture(event)
            }
        }

        let maxTimes = Int.random(in: 1 ... 10)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, factory: { context in
            context.eventLoop.makeSucceededFuture(Handler())
        })
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }

    func testVoidEventLoopSuccess() {
        let server = MockLambdaServer(behavior: SimpleBehavior(result: .success(nil)))
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct Handler: EventLoopLambdaHandler {
            typealias Event = String
            typealias Output = Void

            func handle(_ event: String, context: Lambda.Context) -> EventLoopFuture<Void> {
                context.eventLoop.makeSucceededFuture(())
            }
        }

        let maxTimes = Int.random(in: 1 ... 10)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, factory: { context in
            context.eventLoop.makeSucceededFuture(Handler())
        })
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }

    func testEventLoopFailure() {
        let server = MockLambdaServer(behavior: SimpleBehavior(result: .failure(TestError("boom"))))
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct Handler: EventLoopLambdaHandler {
            typealias Event = String
            typealias Output = String

            func handle(_ event: String, context: Lambda.Context) -> EventLoopFuture<String> {
                context.eventLoop.makeFailedFuture(TestError("boom"))
            }
        }

        let maxTimes = Int.random(in: 1 ... 10)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, factory: { context in
            context.eventLoop.makeSucceededFuture(Handler())
        })
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }

    func testEventLoopBootstrapFailure() {
        let server = MockLambdaServer(behavior: FailedBootstrapBehavior())
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        let result = Lambda.run(configuration: .init(), factory: { context in
            context.eventLoop.makeFailedFuture(TestError("kaboom"))
        })
        assertLambdaLifecycleResult(result, shouldFailWithError: TestError("kaboom"))
    }
}
