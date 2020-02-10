import Foundation
import XCTest
import AlamofirePromiseKit
import Alamofire
import AwaitKit
import Tea
@testable import AlibabaCloudCommons

final class AlibabaCloudCommonsTests: XCTestCase {

    func testReadAsString() {
        let str: String = "string"
        let data: Data = "string".data(using: .utf8)!
        let readAsString: String = AlibabaCloudCommons.readAsString(data)
        XCTAssertEqual(str, readAsString)
    }

    func testGetEndpoint() {
        let endpoint: String = "ecs.cn-hangzhou.aliyun.cs.com"
        var useAccelerate: Bool = false
        var endpointType: String = "public"

        XCTAssertEqual("ecs.cn-hangzhou.aliyun.cs.com", AlibabaCloudCommons.getEndpoint(endpoint, useAccelerate))

        endpointType = "internal"
        XCTAssertEqual("ecs-internal.cn-hangzhou.aliyun.cs.com", AlibabaCloudCommons.getEndpoint(endpoint, useAccelerate, endpointType))

        useAccelerate = true
        endpointType = "accelerate"
        XCTAssertEqual("oss-accelerate.aliyuncs.com", AlibabaCloudCommons.getEndpoint(endpoint, useAccelerate, endpointType))
    }

    func testGetHost() {
        let serviceCode: String = "ecs"
        let regionId: String = "cn-hangzhou"
        let endpoint: String? = "fake.aliyuncs.com"

        XCTAssertEqual("ecs.cn-hangzhou.aliyuncs.com", AlibabaCloudCommons.getHost(serviceCode, regionId))
        XCTAssertEqual("fake.aliyuncs.com", AlibabaCloudCommons.getHost(serviceCode, regionId, endpoint))
    }

    func testConvert() {
        let model: MockModel = MockModel()
        model.a = "foo"

        let output: MockModel = MockModel()
        AlibabaCloudCommons.convert(model, output)
        XCTAssertEqual(model.a, output.a)
    }

    func testGetNonce() {
        let str:String = AlibabaCloudCommons.getNonce()
        print(str)
        print(str.lengthOfBytes(using: .utf8))
    }

    static var allTests = [
        ("testReadAsString", testReadAsString),
    ]
}

open class MockModel: TeaModel {
    @objc public var a: String = "A"

    @objc public var b: String = ""

    @objc public var c: String = ""

    public override init() {
        super.init()
        self.__name["a"] = "A"
        self.__required["c"] = true
    }
}