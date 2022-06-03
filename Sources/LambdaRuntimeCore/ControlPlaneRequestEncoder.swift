//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2021 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIOCore

@_spi(Lambda)
public protocol ControlPlaneRequestEncoder: _EmittingChannelHandler where OutboundOut == ByteBuffer {
    init(host: String)
    mutating func writeRequest(_ request: ControlPlaneRequest, context: ChannelHandlerContext, promise: EventLoopPromise<Void>?)
    mutating func writerAdded(context: ChannelHandlerContext)
    mutating func writerRemoved(context: ChannelHandlerContext)
}
