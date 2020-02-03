import Foundation
import CryptoSwift
import PromiseKit
import Alamofire
import AwaitKit

func dateFormatter(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.timeZone = TimeZone(identifier: "GMT")
    formatter.dateFormat = format
    return formatter
}

func hasExpired(expiration: TimeInterval) -> Bool {
    Double(expiration) - Double(Date().timeIntervalSince1970) <= 180
}

func composeUrl(host: String, params: [String: Any], pathname: String = "/", schema: String = "https", port: String = "80") -> String {
    var url: String = ""
    url = url + schema.lowercased() + "://" + host
    if port != "80" {
        url = url + ":" + port
    }
    url = url + pathname
    if params.count > 0 {
        if url.contains("?") {
            if url.last != "&" {
                url = url + "&"
            }
        } else {
            url = url + "?"
        }
        url = url + httpQueryString(query: params)
    }
    return url
}

func httpQueryString(query: [String: Any]) -> String {
    var url: String = ""
    if query.count > 0 {
        let keys = Array(query.keys).sorted()
        var arr: [String] = [String]()
        for key in keys {
            let value: String = "\(query[key] ?? "")"
            if value.isEmpty {
                continue
            }
            arr.append(key + "=" + "\(value)".urlEncode())
        }
        arr = arr.sorted()
        if arr.count > 0 {
            url = arr.joined(separator: "&")
        }
    }
    return url
}

func uuid() -> String {
    let timestamp: TimeInterval = Date().toTimestamp()
    let timestampStr: String = String(timestamp)
    return (String.randomString(len: 10) + timestampStr + UUID().uuidString).md5()
}

func getRpcSignedStr(method: String, query: [String: Any]) -> String {
    var params: [String] = [String]()
    params.append(method.uppercased())
    params.append("/".urlEncode())
    params.append(httpQueryString(query: query).urlEncode())
    return params.joined(separator: "&")
}

func stsRequest(accessKeySecret: String, connectTimeout: Double, readTimeout: Double, query: [String: String]) -> DefaultDataResponse {
    var params: [String: String] = query
    var strToSign: String = getRpcSignedStr(method: "GET", query: params)
    params["Signature"] = strToSign.generateSignature(secret: accessKeySecret + "&")
    let url: String = composeUrl(host: "sts.aliyuncs.com", params: params)
    let config: URLSessionConfiguration = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = connectTimeout
    config.timeoutIntervalForResource = readTimeout
    let sessionManage: SessionManager = Alamofire.SessionManager(configuration: config)
    let promise = sessionManage.request(url, method: HTTPMethod.get).response()
    let response: DefaultDataResponse = try! await(promise)
    return response
}