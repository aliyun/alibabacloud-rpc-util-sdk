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

    func testDefault() {
        XCTAssertEqual("default", AlibabaCloudCommons._default("", "default"))
        XCTAssertEqual("default", AlibabaCloudCommons._default("  ", "default"))
        XCTAssertEqual("real", AlibabaCloudCommons._default("real", "default"))
    }

    func testDefaultNumber() {
        XCTAssertEqual(1, AlibabaCloudCommons.defaultNumber(0, 1))
        XCTAssertEqual(200, AlibabaCloudCommons.defaultNumber(200, 1))
    }

    func testGetUserAgent() {
        let userAgent: String = AlibabaCloudCommons.getUserAgent("CustomizedUserAgent")
        print(userAgent)
        XCTAssertTrue(userAgent.contains("CustomizedUserAgent"))
    }

    func testGetDate() {
        XCTAssertEqual(20, AlibabaCloudCommons.getDate().lengthOfBytes(using: .utf8))
    }

    func testParseXml() {
        let xml: String = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><Tests><Test>foo</Test></Tests>"
        let target: String? = "foo"
        do {
            let r = try AlibabaCloudCommons.parseXml(xml)
            XCTAssertEqual(target, r["Tests"]["Test"].text)
        } catch {
            // Not throw exception
            XCTAssertTrue(false)
        }
    }

    func testGetErrMessage() {
        let xml: String = """
                          <?xml version='1.0' encoding='UTF-8'?><Error>
                          <RequestId>request-id</RequestId><HostId>host-id</HostId><Code>request-code</Code><Message>message</Message></Error>
                          """;
        let r: [String: String?] = AlibabaCloudCommons.getErrMessage(xml)
        XCTAssertEqual("message", r["Message"])
        XCTAssertEqual("request-code", r["Code"])
        XCTAssertEqual("request-id", r["RequestId"])
        XCTAssertEqual("host-id", r["HostId"])
    }

    func testIsFail() {
        let sm: SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        let queue: DispatchQueue = DispatchQueue(label: "AlibabaCloudCommonsTests.TestsQueue")
        let promise = sm.request("https://httpbin.org/get?foo=bar", method: HTTPMethod.get).response(queue: queue)
        do {
            let response: DefaultDataResponse = try await(promise)
            let teaResponse: TeaResponse = TeaResponse(response)
            print(teaResponse.statusCode)
            XCTAssertFalse(AlibabaCloudCommons.isFail(teaResponse))
        } catch {
            XCTAssertTrue(false)
        }
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

    func testGetOpenPlatFormEndpoint() {
        let endpoint: String = "fake.domain.com"
        var regionId: String = ""

        // regionId is empty
        XCTAssertEqual("fake.domain.com", AlibabaCloudCommons.getOpenPlatFormEndpoint(endpoint, regionId))
        // regionId is invalid
        regionId = "invalid-regionId"
        XCTAssertEqual("fake.domain.com", AlibabaCloudCommons.getOpenPlatFormEndpoint(endpoint, regionId))
        // regionId is valid but have upper character
        regionId = "cn-Hongkong"
        XCTAssertEqual("fake.cn-hongkong.domain.com", AlibabaCloudCommons.getOpenPlatFormEndpoint(endpoint, regionId))
        // valid regionId
        regionId = "cn-hongkong"
        XCTAssertEqual("fake.cn-hongkong.domain.com", AlibabaCloudCommons.getOpenPlatFormEndpoint(endpoint, regionId))
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