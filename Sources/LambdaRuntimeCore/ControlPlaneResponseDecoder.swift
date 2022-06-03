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

import NIOCore

@_spi(Lambda) public protocol ControlPlaneResponseDecoder: NIOSingleStepByteToMessageDecoder {
    associatedtype Invocation: LambdaInvocation where InboundOut == ControlPlaneResponse<Invocation>
    init()
}

@_spi(Lambda) public extension ControlPlaneResponseDecoder {
    typealias Response = ControlPlaneResponse<Invocation>
}
