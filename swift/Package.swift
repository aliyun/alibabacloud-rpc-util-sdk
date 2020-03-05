// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlibabaCloudRpcUtils",
    products: [
        .library(
            name: "AlibabaCloudRpcUtils",
            targets: ["AlibabaCloudRpcUtils"])
    ],
    dependencies: [
        .package(url: "https://github.com/aliyun/tea-swift.git", from: "0.3.0"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "5.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "AlibabaCloudRpcUtils",
            dependencies: ["Tea", "SWXMLHash", "SwiftyJSON"]),
        .testTarget(
            name: "AlibabaCloudRpcUtilsTests",
            dependencies: ["AlibabaCloudRpcUtils", "Tea", "SWXMLHash", "SwiftyJSON"])
    ]
)
