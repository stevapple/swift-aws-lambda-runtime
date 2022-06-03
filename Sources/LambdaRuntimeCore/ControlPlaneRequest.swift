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

import NIOCore
import NIOHTTP1

public protocol LambdaInvocation: Hashable {
    @_spi(Lambda) var requestID: String { get }
    @_spi(Lambda) init(headers: HTTPHeaders) throws
}

@_spi(Lambda)
public enum ControlPlaneRequest: Hashable {
    case next
    case invocationResponse(LambdaRequestID, ByteBuffer?)
    case invocationError(LambdaRequestID, ErrorResponse)
    case initializationError(ErrorResponse)
}

@_spi(Lambda)
public enum ControlPlaneResponse<Invocation: LambdaInvocation>: Hashable {
    case next(Invocation, ByteBuffer)
    case accepted
    case error(ErrorResponse)
}

@_spi(Lambda)
public struct ErrorResponse: Hashable, Codable {
    public var errorType: String
    public var errorMessage: String
}

@_spi(Lambda)
extension ErrorResponse {
    public func toJSONBytes() -> [UInt8] {
        var bytes = [UInt8]()
        bytes.append(UInt8(ascii: "{"))
        bytes.append(contentsOf: #""errorType":"#.utf8)
        self.errorType.encodeAsJSONString(into: &bytes)
        bytes.append(contentsOf: #","errorMessage":"#.utf8)
        self.errorMessage.encodeAsJSONString(into: &bytes)
        bytes.append(UInt8(ascii: "}"))
        return bytes
    }
}
