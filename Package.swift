// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swift-aws-lambda-runtime",
    products: [
        // this library exports `AWSLambdaRuntimeCore` and adds Foundation convenience methods
        .library(name: "AWSLambdaRuntime", targets: ["AWSLambdaRuntime"]),
        // this has all the main functionality for AWS Lambda and it does not link Foundation
        .library(name: "AWSLambdaRuntimeCore", targets: ["AWSLambdaRuntimeCore"]),
//        // this is the supporting library for any AWS-like lambda runtime
//        .library(name: "LambdaRuntimeCore", targets: ["LambdaRuntimeCore"]),
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
            .byName(name: "LambdaRuntimeCore"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "NIOCore", package: "swift-nio"),
        ]),
        .target(name: "LambdaRuntimeCore", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "Backtrace", package: "swift-backtrace"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOPosix", package: "swift-nio"),
        ]),
//        .testTarget(name: "AWSLambdaRuntimeCoreTests", dependencies: [
//            .byName(name: "AWSLambdaRuntimeCore"),
//            .product(name: "NIOTestUtils", package: "swift-nio"),
//            .product(name: "NIOFoundationCompat", package: "swift-nio"),
//        ]),
        .testTarget(name: "AWSLambdaRuntimeTests", dependencies: [
            .byName(name: "AWSLambdaRuntime"),
            .byName(name: "AWSLambdaRuntimeCore"),
            .byName(name: "LambdaRuntimeCore"),
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
    ]
)
