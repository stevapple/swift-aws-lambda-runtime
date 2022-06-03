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

@_exported import LambdaRuntimeCore

public enum AWSLambda {}

extension AWSLambda: LambdaProvider {
    public static var runtimeEngineAddress: String? {
        Lambda.env("AWS_LAMBDA_RUNTIME_API")
    }
}

#if swift(>=5.5) && canImport(_Concurrency)
// #if swift(>=5.7)
// @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
// public typealias AWSLambdaHandler = LambdaHandler<AWSLambda>
// #else
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public protocol AWSLambdaHandler: LambdaHandler where Provider == AWSLambda {}
// #endif
#endif
