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
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.3.0"),
        .package(url: "https://github.com/aliyun/tea-swift.git", from: "0.1.0"),
        .package(url: "https://github.com/AxiosCros/SwiftyXMLParser.git", from: "5.2.0-beta")
    ],
    targets: [
        .target(
            name: "AlibabaCloudCommons",
            dependencies: ["CryptoSwift", "Tea", "SwiftyXMLParser"]),
        .testTarget(
            name: "AlibabaCloudCommonsTests",
            dependencies: ["CryptoSwift", "Tea"])
    ]
)
