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

protocol LambdaChannelHandlerDelegate {
    associatedtype Handler: ByteBufferLambdaHandler

    func responseReceived(_: ControlPlaneResponse<Handler.Context.Invocation>)

    func errorCaught(_: Error)

    func channelInactive()
}

final class NewLambdaChannelHandler<Delegate: LambdaChannelHandlerDelegate>: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let delegate: Delegate
    private var requestsInFlight: CircularBuffer<ControlPlaneRequest>

    private var context: ChannelHandlerContext!

    private var encoder: Delegate.Handler.Provider.RequestEncoder
    private var decoder: NIOSingleStepByteToMessageProcessor<Delegate.Handler.Provider.ResponseDecoder>

    init(delegate: Delegate, host: String) {
        self.delegate = delegate
        self.requestsInFlight = CircularBuffer<ControlPlaneRequest>(initialCapacity: 4)

        self.encoder = .init(host: host)
        self.decoder = NIOSingleStepByteToMessageProcessor(.init(), maximumBufferSize: 7 * 1024 * 1024)
    }

    func sendRequest(_ request: ControlPlaneRequest) {
        self.requestsInFlight.append(request)
        self.encoder.writeRequest(request, context: self.context, promise: nil)
    }

    func handlerAdded(context: ChannelHandlerContext) {
        self.context = context
        self.encoder.writerAdded(context: context)
    }

    func handlerRemoved(context: ChannelHandlerContext) {
        self.context = context
        self.encoder.writerRemoved(context: context)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        do {
            let buffer = self.unwrapInboundIn(data)
            try self.decoder.process(buffer: buffer) { response in
                guard self.requestsInFlight.popFirst() != nil else {
                    throw LambdaRuntimeError.unsolicitedResponse
                }

                self.delegate.responseReceived(response)
            }
        } catch {
            self.delegate.errorCaught(error)
        }
    }

    func channelInactive(context: ChannelHandlerContext) {
        self.delegate.channelInactive()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.delegate.errorCaught(error)
    }
}
