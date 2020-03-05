English | [简体中文](README-CN.md)

![](https://aliyunsdk-pages.alicdn.com/icons/AlibabaCloud.svg)

## Alibaba Cloud ROA Util SDK for Swift

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate `AlibabaCloudRpcUtils` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AlibabaCloudRpcUtils', '~> 0.1.0'
```

### Carthage

To integrate `AlibabaCloudRpcUtils` into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "alibabacloud-sdk-swift/roa-utils" "0.1.0"
```

### Swift Package Manager

To integrate `AlibabaCloudRpcUtils` into your Xcode project using [Swift Package Manager](https://swift.org/package-manager/) , adding `AlibabaCloudRpcUtils` to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/alibabacloud-sdk-swift/roa-utils.git", from: "0.1.0")
]
```

In addition, you also need to add `"AlibabaCloudRpcUtils"` to the `dependencies` of the `target`, as follows:

```swift
.target(
    name: "<your-project-name>",
    dependencies: [
        "AlibabaCloudRpcUtils",
    ])
```

## Issues

[Opening an Issue](https://github.com/aliyun/tea-roa-util/issues/new), Issues not conforming to the guidelines may be closed immediately.

## Changelog

Detailed changes for each release are documented in the [release notes](./ChangeLog.txt).

## References

* [Latest Release](https://github.com/aliyun/tea-roa-util)

## License

[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Copyright (c) 2009-present, Alibaba Cloud All rights reserved.
