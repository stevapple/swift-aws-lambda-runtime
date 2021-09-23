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

@testable import TestUtils
@testable import AWSLambdaRuntime
@testable import AWSLambdaRuntimeCore
import NIOCore
import XCTest

#if compiler(>=5.5) && canImport(_Concurrency)
class LambdaHandlerTest: XCTestCase {

    // MARK: - LambdaHandler

    func testBootstrapSuccess() {
        let server = MockLambdaServer(behavior: SimpleBehavior())
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct TestBootstrapHandler: LambdaHandler {
            typealias Event = String
            typealias Output = String

            var initialized = false

            init(context: Lambda.InitializationContext) async throws {
                XCTAssertFalse(self.initialized)
                try await Task.sleep(nanoseconds: 100 * 1000 * 1000) // 0.1 seconds
                self.initialized = true
            }

            func handle(_ event: String, context: Lambda.Context) async throws -> String {
                event
            }
        }

        let maxTimes = Int.random(in: 10 ... 20)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, handlerType: TestBootstrapHandler.self)
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }

    func testBootstrapFailure() {
        let server = MockLambdaServer(behavior: FailedBootstrapBehavior())
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct TestBootstrapHandler: LambdaHandler {
            typealias Event = String
            typealias Output = Void

            var initialized = false

            init(context: Lambda.InitializationContext) async throws {
                XCTAssertFalse(self.initialized)
                try await Task.sleep(nanoseconds: 100 * 1000 * 1000) // 0.1 seconds
                throw TestError("kaboom")
            }

            func handle(_ event: String, context: Lambda.Context) async throws {
                XCTFail("How can this be called if init failed")
            }
        }

        let maxTimes = Int.random(in: 10 ... 20)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, handlerType: TestBootstrapHandler.self)
        assertLambdaLifecycleResult(result, shouldFailWithError: TestError("kaboom"))
    }

    func testHandlerSuccess() {
        let server = MockLambdaServer(behavior: SimpleBehavior())
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct Handler: LambdaHandler {
            typealias Event = String
            typealias Output = String

            init(context: Lambda.InitializationContext) {}

            func handle(_ event: String, context: Lambda.Context) async throws -> String {
                event
            }
        }

        let maxTimes = Int.random(in: 1 ... 10)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, handlerType: Handler.self)
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }

    func testVoidHandlerSuccess() {
        let server = MockLambdaServer(behavior: SimpleBehavior(result: .success(nil)))
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct Handler: LambdaHandler {
            typealias Event = String
            typealias Output = Void

            init(context: Lambda.InitializationContext) {}

            func handle(_ event: String, context: Lambda.Context) async throws {}
        }

        let maxTimes = Int.random(in: 1 ... 10)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))

        let result = Lambda.run(configuration: configuration, handlerType: Handler.self)
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }

    func testHandlerFailure() {
        let server = MockLambdaServer(behavior: SimpleBehavior(result: .failure(TestError("boom"))))
        XCTAssertNoThrow(try server.start().wait())
        defer { XCTAssertNoThrow(try server.stop().wait()) }

        struct Handler: LambdaHandler {
            typealias Event = String
            typealias Output = String

            init(context: Lambda.InitializationContext) {}

            func handle(_ event: String, context: Lambda.Context) async throws -> String {
                throw TestError("boom")
            }
        }

        let maxTimes = Int.random(in: 1 ... 10)
        let configuration = Lambda.Configuration(lifecycle: .init(maxTimes: maxTimes))
        let result = Lambda.run(configuration: configuration, handlerType: Handler.self)
        assertLambdaLifecycleResult(result, shoudHaveRun: maxTimes)
    }
}
#endif
