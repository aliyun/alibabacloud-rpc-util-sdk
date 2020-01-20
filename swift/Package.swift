// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlibabaCloudCommons",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "AlibabaCloudCommons",
            targets: ["AlibabaCloudCommons"])
    ],
    dependencies: [
        .package(url: "https://github.com/yannickl/AwaitKit.git", from: "5.2.0")
    ],
    targets: [
        .target(
            name: "AlibabaCloudCommons",
            dependencies: ["AwaitKit"]),
        .testTarget(
            name: "AlibabaCloudCommonsTests",
            dependencies: ["AlibabaCloudCommons"])
    ]
)
