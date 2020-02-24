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
        .package(url: "https://github.com/aliyun/tea-swift.git", from: "0.2.0"),
        .package(url: "https://github.com/AxiosCros/SwiftyXMLParser.git", from: "5.2.0-beta"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "AlibabaCloudCommons",
            dependencies: ["Tea", "SwiftyXMLParser", "SwiftyJSON"]),
        .testTarget(
            name: "AlibabaCloudCommonsTests",
            dependencies: ["Tea", "SwiftyJSON"])
    ]
)
