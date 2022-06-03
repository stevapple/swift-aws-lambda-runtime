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

import Dispatch
import Logging
import NIOCore

extension Lambda {
    @_spi(Lambda)
    public struct Configuration: CustomStringConvertible {
        public let general: General
        public let lifecycle: Lifecycle
        public let runtimeEngine: RuntimeEngine

        public init() {
            self.init(general: .init(), lifecycle: .init(), runtimeEngine: .init())
        }

        init(general: General? = nil, lifecycle: Lifecycle? = nil, runtimeEngine: RuntimeEngine? = nil) {
            self.general = general ?? General()
            self.lifecycle = lifecycle ?? Lifecycle()
            self.runtimeEngine = runtimeEngine ?? RuntimeEngine()
        }

        public struct General: CustomStringConvertible {
            public let logLevel: Logger.Level

            init(logLevel: Logger.Level? = nil) {
                self.logLevel = logLevel ?? env("LOG_LEVEL").flatMap(Logger.Level.init) ?? .info
            }

            public var description: String {
                "\(General.self)(logLevel: \(self.logLevel))"
            }
        }

        public struct Lifecycle: CustomStringConvertible {
            public let id: String
            public let maxTimes: Int
            let stopSignal: Signal

            init(id: String? = nil, maxTimes: Int? = nil, stopSignal: Signal? = nil) {
                self.id = id ?? "\(DispatchTime.now().uptimeNanoseconds)"
                self.maxTimes = maxTimes ?? env("MAX_REQUESTS").flatMap(Int.init) ?? 0
                self.stopSignal = stopSignal ?? env("STOP_SIGNAL").flatMap(Int32.init).flatMap(Signal.init) ?? Signal.TERM
                precondition(self.maxTimes >= 0, "maxTimes must be equal or larger than 0")
            }

            public var description: String {
                "\(Lifecycle.self)(id: \(self.id), maxTimes: \(self.maxTimes), stopSignal: \(self.stopSignal))"
            }
        }

        public struct RuntimeEngine: CustomStringConvertible {
            public let ip: String
            public let port: Int
            public let requestTimeout: TimeAmount?

            init(address: String? = nil, keepAlive: Bool? = nil, requestTimeout: TimeAmount? = nil) {
                let ipPort = (address ?? env("AWS_LAMBDA_RUNTIME_API"))?.split(separator: ":") ?? ["127.0.0.1", "7000"]
                guard ipPort.count == 2, let port = Int(ipPort[1]) else {
                    preconditionFailure("invalid ip+port configuration \(ipPort)")
                }
                self.ip = String(ipPort[0])
                self.port = port
                self.requestTimeout = requestTimeout ?? env("REQUEST_TIMEOUT").flatMap(Int64.init).flatMap { .milliseconds($0) }
            }

            public var description: String {
                "\(RuntimeEngine.self)(ip: \(self.ip), port: \(self.port), requestTimeout: \(String(describing: self.requestTimeout))"
            }
        }

        public var description: String {
            "\(Configuration.self)\n  \(self.general))\n  \(self.lifecycle)\n  \(self.runtimeEngine)"
        }
    }
}
