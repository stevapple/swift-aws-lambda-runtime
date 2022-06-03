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

public protocol ControlPlaneRequestEncoder: _EmittingChannelHandler where OutboundOut == ByteBuffer {
    @_spi(Lambda) init(host: String)
    @_spi(Lambda) mutating func writeRequest(_ request: ControlPlaneRequest, context: ChannelHandlerContext, promise: EventLoopPromise<Void>?)
    @_spi(Lambda) mutating func writerAdded(context: ChannelHandlerContext)
    @_spi(Lambda) mutating func writerRemoved(context: ChannelHandlerContext)
}
