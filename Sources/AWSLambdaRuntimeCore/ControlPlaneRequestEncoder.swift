//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@_spi(Lambda) import LambdaRuntimeCore
import NIOCore

@_spi(Lambda)
extension AWSLambda {
    public struct RequestEncoder: ControlPlaneRequestEncoder {
        private var host: String
        private var byteBuffer: ByteBuffer!

        public init(host: String) {
            self.host = host
        }

        public mutating func writeRequest(_ request: ControlPlaneRequest, context: ChannelHandlerContext, promise: EventLoopPromise<Void>?) {
            self.byteBuffer.clear(minimumCapacity: self.byteBuffer.storageCapacity)

            switch request {
            case .next:
                self.byteBuffer.writeString(.nextInvocationRequestLine)
                self.byteBuffer.writeHostHeader(host: self.host)
                self.byteBuffer.writeString(.userAgentHeader)
                self.byteBuffer.writeString(.CRLF) // end of head
                context.write(self.wrapOutboundOut(self.byteBuffer), promise: promise)
                context.flush()

            case .invocationResponse(let requestID, let payload):
                let contentLength = payload?.readableBytes ?? 0
                self.byteBuffer.writeInvocationResultRequestLine(requestID)
                self.byteBuffer.writeHostHeader(host: self.host)
                self.byteBuffer.writeString(.userAgentHeader)
                self.byteBuffer.writeContentLengthHeader(length: contentLength)
                self.byteBuffer.writeString(.CRLF) // end of head
                if let payload = payload, contentLength > 0 {
                    context.write(self.wrapOutboundOut(self.byteBuffer), promise: nil)
                    context.write(self.wrapOutboundOut(payload), promise: promise)
                } else {
                    context.write(self.wrapOutboundOut(self.byteBuffer), promise: promise)
                }
                context.flush()

            case .invocationError(let requestID, let errorMessage):
                let payload = errorMessage.toJSONBytes()
                self.byteBuffer.writeInvocationErrorRequestLine(requestID)
                self.byteBuffer.writeContentLengthHeader(length: payload.count)
                self.byteBuffer.writeHostHeader(host: self.host)
                self.byteBuffer.writeString(.userAgentHeader)
                self.byteBuffer.writeString(.unhandledErrorHeader)
                self.byteBuffer.writeString(.CRLF) // end of head
                self.byteBuffer.writeBytes(payload)
                context.write(self.wrapOutboundOut(self.byteBuffer), promise: promise)
                context.flush()

            case .initializationError(let errorMessage):
                let payload = errorMessage.toJSONBytes()
                self.byteBuffer.writeString(.runtimeInitErrorRequestLine)
                self.byteBuffer.writeContentLengthHeader(length: payload.count)
                self.byteBuffer.writeHostHeader(host: self.host)
                self.byteBuffer.writeString(.userAgentHeader)
                self.byteBuffer.writeString(.unhandledErrorHeader)
                self.byteBuffer.writeString(.CRLF) // end of head
                self.byteBuffer.writeBytes(payload)
                context.write(self.wrapOutboundOut(self.byteBuffer), promise: promise)
                context.flush()
            }
        }

        public mutating func writerAdded(context: ChannelHandlerContext) {
            self.byteBuffer = context.channel.allocator.buffer(capacity: 256)
        }

        public mutating func writerRemoved(context: ChannelHandlerContext) {
            self.byteBuffer = nil
        }
    }
}

extension String {
    fileprivate static let CRLF: String = "\r\n"

    fileprivate static let userAgentHeader: String = "user-agent: Swift-Lambda/Unknown\r\n"
    fileprivate static let unhandledErrorHeader: String = "lambda-runtime-function-error-type: Unhandled\r\n"

    fileprivate static let nextInvocationRequestLine: String =
        "GET /2018-06-01/runtime/invocation/next HTTP/1.1\r\n"

    fileprivate static let runtimeInitErrorRequestLine: String =
        "POST /2018-06-01/runtime/init/error HTTP/1.1\r\n"
}

extension ByteBuffer {
    fileprivate mutating func writeInvocationResultRequestLine(_ requestID: LambdaRequestID) {
        self.writeString("POST /2018-06-01/runtime/invocation/")
        self.writeRequestID(requestID)
        self.writeString("/response HTTP/1.1\r\n")
    }

    fileprivate mutating func writeInvocationErrorRequestLine(_ requestID: LambdaRequestID) {
        self.writeString("POST /2018-06-01/runtime/invocation/")
        self.writeRequestID(requestID)
        self.writeString("/error HTTP/1.1\r\n")
    }

    fileprivate mutating func writeHostHeader(host: String) {
        self.writeString("host: ")
        self.writeString(host)
        self.writeString(.CRLF)
    }

    fileprivate mutating func writeContentLengthHeader(length: Int) {
        self.writeString("content-length: ")
        self.writeString("\(length)")
        self.writeString(.CRLF)
    }
}
