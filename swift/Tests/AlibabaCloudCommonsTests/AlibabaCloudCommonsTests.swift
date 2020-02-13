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
        XCTAssertEqual(32, AlibabaCloudCommons.getNonce().lengthOfBytes(using: .utf8))
    }

    func testGetSignature() {
        let secret: String = "access-key-secret"
        let request = TeaRequest()
        request.query["foo"] = "bar"
        XCTAssertEqual("LYCzlHWLR8dc/gOmv9u5dEfpPvU=", AlibabaCloudCommons.getSignature(request, secret))
    }

    func testJson() {
        let sm: SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        let queue: DispatchQueue = DispatchQueue(label: "AlibabaCloudCommonsTests.TestsQueue")
        let promise = sm.request("https://httpbin.org/get?foo=bar", method: HTTPMethod.get).response(queue: queue)
        do {
            let response: DefaultDataResponse = try await(promise)
            let teaResponse: TeaResponse = TeaResponse(response)
            let dict = AlibabaCloudCommons.json(teaResponse)
            let args: [String: String] = dict["args"] as! [String: String]
            XCTAssertEqual(args["foo"], "bar")
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testHasError() {
        var dict: [String: AnyObject] = [String: AnyObject]()

        XCTAssertTrue(AlibabaCloudCommons.hasError())
        XCTAssertFalse(AlibabaCloudCommons.hasError(dict))

        dict["Code"] = "Success" as AnyObject
        XCTAssertTrue(AlibabaCloudCommons.hasError(dict))
    }

    func testGetTimestamp() {
        let now = AlibabaCloudCommons.getTimestamp()
        sleep(1)
        let end = AlibabaCloudCommons.getTimestamp()

        XCTAssertTrue(end - now >= 0)
    }

    func testToForm() {
        let data: Data = "string".data(using: .utf8)!
        XCTAssertEqual("".data(using: .utf8), AlibabaCloudCommons.toForm(dict: nil, data, "boundary"))
        var dict: [String: AnyObject] = [String: AnyObject]()
        dict["foo"] = "bar" as AnyObject

        var result: Data = AlibabaCloudCommons.toForm(dict: dict, data, "boundary")
        var str: String = String(data: result, encoding: .utf8) ?? ""
        XCTAssertEqual(str, "--boundary\r\nContent-Disposition: form-data; name=\"x-oss-meta-foo\"\r\n\r\nbar\r\n--boundary--\r\n")

        var headerFile: [String: AnyObject] = [String: AnyObject]()
        headerFile["content-type"] = "json" as AnyObject
        headerFile["filename"] = "filename" as AnyObject
        headerFile["content"] = "content" as AnyObject
        var userMeta: [String: String] = [String: String]()
        userMeta["test"] = "test"
        dict["file"] = headerFile as AnyObject
        dict["UserMeta"] = userMeta as AnyObject
        result = AlibabaCloudCommons.toForm(dict: dict, data, "boundary")
        str = String(data: result, encoding: .utf8) ?? ""
        XCTAssertEqual(str, "--boundary\r\nContent-Disposition: form-data; name=\"x-oss-meta-test\"\r\n\r\ntest\r\n--boundary\r\nContent-Disposition: form-data; name=\"x-oss-meta-foo\"\r\n\r\nbar\r\n--boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"filename\"\r\n\r\nContent-Type: jsoncontent\r\n--boundary--\r\n")
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