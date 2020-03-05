import Foundation
import XCTest
import AlamofirePromiseKit
import Alamofire
import AwaitKit
import Tea
import SWXMLHash
@testable import AlibabaCloudRpcUtils

final class AlibabaCloudRpcUtilsTests: XCTestCase {

    func testReadAsString() {
        let str: String = "string"
        let data: Data = "string".data(using: .utf8)!
        let readAsString: String = AlibabaCloudRpcUtils.readAsString(data)
        XCTAssertEqual(str, readAsString)
    }

    func testGetEndpoint() {
        let endpoint: String = "ecs.cn-hangzhou.aliyun.cs.com"
        var useAccelerate: Bool = false
        var endpointType: String = "public"

        XCTAssertEqual("ecs.cn-hangzhou.aliyun.cs.com", AlibabaCloudRpcUtils.getEndpoint(endpoint, useAccelerate))

        endpointType = "internal"
        XCTAssertEqual("ecs-internal.cn-hangzhou.aliyun.cs.com", AlibabaCloudRpcUtils.getEndpoint(endpoint, useAccelerate, endpointType))

        useAccelerate = true
        endpointType = "accelerate"
        XCTAssertEqual("oss-accelerate.aliyuncs.com", AlibabaCloudRpcUtils.getEndpoint(endpoint, useAccelerate, endpointType))
    }

    func testGetHost() {
        let serviceCode: String = "ecs"
        let regionId: String = "cn-hangzhou"
        let endpoint: String? = "fake.aliyuncs.com"

        XCTAssertEqual("ecs.cn-hangzhou.aliyuncs.com", AlibabaCloudRpcUtils.getHost(serviceCode, regionId))
        XCTAssertEqual("fake.aliyuncs.com", AlibabaCloudRpcUtils.getHost(serviceCode, regionId, endpoint))
    }

    func testConvert() {
        let model: MockModel = MockModel()
        model.a = "foo"

        let output: MockModel = MockModel()
        AlibabaCloudRpcUtils.convert(model, output)
        XCTAssertEqual(model.a, output.a)
    }

    func testGetNonce() {
        XCTAssertEqual(32, AlibabaCloudRpcUtils.getNonce().lengthOfBytes(using: .utf8))
    }

    func testGetSignature() {
        let secret: String = "access-key-secret"
        let request = TeaRequest()
        request.query["foo"] = "bar"
        XCTAssertEqual("LYCzlHWLR8dc/gOmv9u5dEfpPvU=", AlibabaCloudRpcUtils.getSignature(request, secret))
    }

    func testJson() {
        let sm: SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        let queue: DispatchQueue = DispatchQueue(label: "AlibabaCloudRpcUtilsTests.TestsQueue")
        let promise = sm.request("https://httpbin.org/get?foo=bar", method: HTTPMethod.get).response(queue: queue)
        do {
            let response: DefaultDataResponse = try await(promise)
            let teaResponse: TeaResponse = TeaResponse(response)
            let dict = AlibabaCloudRpcUtils.json(teaResponse)
            let args: [String: String] = dict["args"] as! [String: String]
            XCTAssertEqual(args["foo"], "bar")
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testHasError() {
        var dict: [String: AnyObject] = [String: AnyObject]()

        XCTAssertTrue(AlibabaCloudRpcUtils.hasError())
        XCTAssertFalse(AlibabaCloudRpcUtils.hasError(dict))

        dict["Code"] = "Success" as AnyObject
        XCTAssertTrue(AlibabaCloudRpcUtils.hasError(dict))
    }

    func testGetTimestamp() {
        let now = AlibabaCloudRpcUtils.getTimestamp()
        sleep(1)
        let end = AlibabaCloudRpcUtils.getTimestamp()

        XCTAssertTrue(end - now >= 0)
    }

    func testDefault() {
        XCTAssertEqual("default", AlibabaCloudRpcUtils._default("", "default"))
        XCTAssertEqual("default", AlibabaCloudRpcUtils._default("  ", "default"))
        XCTAssertEqual("real", AlibabaCloudRpcUtils._default("real", "default"))
    }

    func testDefaultNumber() {
        XCTAssertEqual(1, AlibabaCloudRpcUtils.defaultNumber(0, 1))
        XCTAssertEqual(200, AlibabaCloudRpcUtils.defaultNumber(200, 1))
    }

    func testGetUserAgent() {
        let userAgent: String = AlibabaCloudRpcUtils.getUserAgent("CustomizedUserAgent")
        print(userAgent)
        XCTAssertTrue(userAgent.contains("CustomizedUserAgent"))
    }

    func testGetDate() {
        XCTAssertEqual(20, AlibabaCloudRpcUtils.getDate().lengthOfBytes(using: .utf8))
    }

    func testParseXml() {
        let xml: String = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><Tests><Test>foo</Test></Tests>"
        let target: String? = "foo"
        let dict: XMLIndexer = AlibabaCloudRpcUtils.parseXml(xml)
        XCTAssertEqual(target, dict["Tests"]["Test"].element?.text)
    }

    func testToForm() {
        let data: Data = "string".data(using: .utf8)!
        XCTAssertEqual("".data(using: .utf8), AlibabaCloudRpcUtils.toForm(dict: nil, data, "boundary"))
        var dict: [String: AnyObject] = [String: AnyObject]()
        dict["foo"] = "bar" as AnyObject

        var result: Data = AlibabaCloudRpcUtils.toForm(dict: dict, data, "boundary")
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
        result = AlibabaCloudRpcUtils.toForm(dict: dict, data, "boundary")
        str = String(data: result, encoding: .utf8) ?? ""
        XCTAssertEqual(str, "--boundary\r\nContent-Disposition: form-data; name=\"x-oss-meta-test\"\r\n\r\ntest\r\n--boundary\r\nContent-Disposition: form-data; name=\"x-oss-meta-foo\"\r\n\r\nbar\r\n--boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"filename\"\r\n\r\nContent-Type: jsoncontent\r\n--boundary--\r\n")
    }

    func testGetErrMessage() {
        let xml: String = """
                          <?xml version='1.0' encoding='UTF-8'?><Error>
                          <RequestId>request-id</RequestId><HostId>host-id</HostId><Code>request-code</Code><Message>message</Message></Error>
                          """;
        let r: [String: String?] = AlibabaCloudRpcUtils.getErrMessage(xml)
        XCTAssertEqual("message", r["Message"])
        XCTAssertEqual("request-code", r["Code"])
        XCTAssertEqual("request-id", r["RequestId"])
        XCTAssertEqual("host-id", r["HostId"])
    }

    func testIsFail() {
        let sm: SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        let queue: DispatchQueue = DispatchQueue(label: "AlibabaCloudRpcUtilsTests.TestsQueue")
        let promise = sm.request("https://httpbin.org/get?foo=bar", method: HTTPMethod.get).response(queue: queue)
        do {
            let response: DefaultDataResponse = try await(promise)
            let teaResponse: TeaResponse = TeaResponse(response)
            XCTAssertEqual("200", teaResponse.statusCode)
            XCTAssertFalse(AlibabaCloudRpcUtils.isFail(teaResponse))
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testGetBoundary() {
        XCTAssertEqual(32, AlibabaCloudRpcUtils.getBoundary().lengthOfBytes(using: .utf8))
    }

    func testEmpty() {
        XCTAssertTrue(AlibabaCloudRpcUtils.empty(""))
        XCTAssertFalse(AlibabaCloudRpcUtils.empty("not empty"))
    }

    func testEqual() {
        XCTAssertTrue(AlibabaCloudRpcUtils.equal("equal", "equal"))
        XCTAssertFalse(AlibabaCloudRpcUtils.equal("a", "b"))
    }

    func testGetOpenPlatFormEndpoint() {
        let endpoint: String = "fake.domain.com"
        var regionId: String = ""

        // regionId is empty
        XCTAssertEqual("fake.domain.com", AlibabaCloudRpcUtils.getOpenPlatFormEndpoint(endpoint, regionId))
        // regionId is invalid
        regionId = "invalid-regionId"
        XCTAssertEqual("fake.domain.com", AlibabaCloudRpcUtils.getOpenPlatFormEndpoint(endpoint, regionId))
        // regionId is valid but have upper character
        regionId = "cn-Hongkong"
        XCTAssertEqual("fake.cn-hongkong.domain.com", AlibabaCloudRpcUtils.getOpenPlatFormEndpoint(endpoint, regionId))
        // valid regionId
        regionId = "cn-hongkong"
        XCTAssertEqual("fake.cn-hongkong.domain.com", AlibabaCloudRpcUtils.getOpenPlatFormEndpoint(endpoint, regionId))
    }

    static var allTests = [
        ("testReadAsString", testReadAsString),
        ("testGetEndpoint", testGetEndpoint),
        ("testGetHost", testGetHost),
        ("testConvert", testConvert),
        ("testGetNonce", testGetNonce),
        ("testGetSignature", testGetSignature),
        ("testJson", testJson),
        ("testHasError", testHasError),
        ("testGetTimestamp", testGetTimestamp),
        ("testDefault", testDefault),
        ("testDefaultNumber", testDefaultNumber),
        ("testGetUserAgent", testGetUserAgent),
        ("testGetDate", testGetDate),
        ("testParseXml", testParseXml),
        ("testToForm", testToForm),
        ("testGetErrMessage", testGetErrMessage),
        ("testIsFail", testIsFail),
        ("testGetBoundary", testGetBoundary),
        ("testEmpty", testEmpty),
        ("testEqual", testEqual),
        ("testGetOpenPlatFormEndpoint", testGetOpenPlatFormEndpoint),
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
