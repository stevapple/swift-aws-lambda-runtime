//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Dispatch
import NIOPosix

/// Helper function to trap signals
internal func trap(signal sig: Signal, handler: @escaping (Signal) -> Void) -> DispatchSourceSignal {
    let signalSource = DispatchSource.makeSignalSource(signal: sig.rawValue, queue: DispatchQueue.global())
    signal(sig.rawValue, SIG_IGN)
    signalSource.setEventHandler(handler: {
        signalSource.cancel()
        handler(sig)
    })
    signalSource.resume()
    return signalSource
}

internal enum Signal: Int32 {
    case HUP = 1
    case INT = 2
    case QUIT = 3
    case ABRT = 6
    case KILL = 9
    case ALRM = 14
    case TERM = 15
}

@_spi(Lambda)
extension String {
    public func encodeAsJSONString(into bytes: inout [UInt8]) {
        bytes.append(UInt8(ascii: "\""))
        let stringBytes = self.utf8
        var startCopyIndex = stringBytes.startIndex
        var nextIndex = startCopyIndex

        while nextIndex != stringBytes.endIndex {
            switch stringBytes[nextIndex] {
            case 0 ..< 32, UInt8(ascii: "\""), UInt8(ascii: "\\"):
                // All Unicode characters may be placed within the
                // quotation marks, except for the characters that MUST be escaped:
                // quotation mark, reverse solidus, and the control characters (U+0000
                // through U+001F).
                // https://tools.ietf.org/html/rfc7159#section-7

                // copy the current range over
                bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
                bytes.append(UInt8(ascii: "\\"))
                bytes.append(stringBytes[nextIndex])

                nextIndex = stringBytes.index(after: nextIndex)
                startCopyIndex = nextIndex
            default:
                nextIndex = stringBytes.index(after: nextIndex)
            }
        }

        // copy everything, that hasn't been copied yet
        bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
        bytes.append(UInt8(ascii: "\""))
    }
}
