// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swift-aws-lambda-runtime",
    products: [
        // this library exports `AWSLambdaRuntimeCore` with async `LambdaHandler`, and adds Foundation convenience methods
        .library(name: "AWSLambdaRuntime", targets: ["AWSLambdaRuntime"]),
        // this has all the functionality for `EventLoop`-based lambda and it does not link Foundation
        .library(name: "AWSLambdaRuntimeCore", targets: ["AWSLambdaRuntimeCore"]),
        // for testing only
        .library(name: "AWSLambdaTesting", targets: ["AWSLambdaTesting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.33.0")),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.4.2")),
        .package(url: "https://github.com/swift-server/swift-backtrace.git", .upToNextMajor(from: "1.2.3")),
    ],
    targets: [
        .target(name: "AWSLambdaRuntime", dependencies: [
            .byName(name: "AWSLambdaRuntimeCore"),
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOFoundationCompat", package: "swift-nio"),
        ]),
        .target(name: "AWSLambdaRuntimeCore", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "Backtrace", package: "swift-backtrace"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
            .product(name: "NIOPosix", package: "swift-nio"),
        ]),
        // for package testing
        .target(name: "TestUtils", dependencies: [
            .byName(name: "AWSLambdaRuntimeCore"),
        ]),
        .testTarget(name: "TestUtilsTests", dependencies: [
            .byName(name: "TestUtils"),
        ]),
        .testTarget(name: "AWSLambdaRuntimeCoreTests", dependencies: [
            .byName(name: "AWSLambdaRuntimeCore"),
            .byName(name: "TestUtils"),
            .product(name: "NIOTestUtils", package: "swift-nio"),
            .product(name: "NIOFoundationCompat", package: "swift-nio"),
        ]),
        .testTarget(name: "AWSLambdaRuntimeTests", dependencies: [
            .byName(name: "AWSLambdaRuntimeCore"),
            .byName(name: "AWSLambdaRuntime"),
            .byName(name: "TestUtils"),
        ]),
        // testing helper
        .target(name: "AWSLambdaTesting", dependencies: [
            .byName(name: "AWSLambdaRuntime"),
            .product(name: "NIO", package: "swift-nio"),
        ]),
        .testTarget(name: "AWSLambdaTestingTests", dependencies: ["AWSLambdaTesting"]),
        // for perf testing
        .target(name: "MockServer", dependencies: [
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "NIO", package: "swift-nio"),
        ]),
        .target(name: "StringSample", dependencies: ["AWSLambdaRuntime"]),
        .target(name: "CodableSample", dependencies: ["AWSLambdaRuntime"]),
    ]
)
