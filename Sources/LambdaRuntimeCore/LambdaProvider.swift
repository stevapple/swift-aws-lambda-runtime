//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

public protocol LambdaProvider {
    associatedtype Invocation
    associatedtype RequestEncoder: ControlPlaneRequestEncoder
    associatedtype Context: LambdaContext where Context.Invocation == Self.Invocation
    associatedtype ResponseDecoder: ControlPlaneResponseDecoder where ResponseDecoder.Invocation == Self.Invocation

    static var runtimeEngineAddress: String? { get }
    #if DEBUG
    @_spi(Lambda)
    static func withLocalServer<Value>(invocationEndpoint: String?, _ body: @escaping () -> Value) throws -> Value
    #endif
}

#if DEBUG
@_spi(Lambda)
extension LambdaProvider {
    public static func withLocalServer<Value>(_ body: @escaping () -> Value) throws -> Value {
        try self.withLocalServer(invocationEndpoint: nil, body)
    }
}
#endif
