import Foundation
import Tea
import SwiftyXMLParser

public enum AliababaCloudCommonsException: Error {
    case Error(Any?)
    case ParseXMLError(String?)
}

public class AlibabaCloudCommons {
    internal static var _defaultUserAgent: String = ""
    public static var clientVersion: String = "UnknownClientVersion"
    public static var coreVersion: String = "UnknownCoreVersion"

    func readAsString(_ data: Data) -> String {
        String(data: data, encoding: .utf8) ?? ""
    }

    func getEndpoint(_ endpoint: String, _ useAccelerate: Bool, _ endpointType: String = "public") -> String {
        var endpointStr = endpoint
        if endpointType == "internal" {
            var tmp = endpoint.split(separator: ".")
            tmp[0] += "-internal"
            endpointStr = tmp.joined(separator: ".")
        }
        if useAccelerate && endpointType == "accelerate" {
            return "oss-accelerate.aliyuncs.com"
        }
        return endpointStr
    }

    public static func getHost(_ serviceCode: String, regionId: String, _ endpoint: String? = nil) -> String {
        if endpoint == nil {
            var tmp: [String] = [String]()
            tmp[0] = serviceCode.lowercased()
            tmp[1] = regionId.lowercased()
            tmp[2] = "aliyuncs.com"
            return tmp.joined(separator: ".")
        } else {
            return endpoint!
        }
    }

    func convert(_ input: TeaModel, _ output: TeaModel) -> Void {
        let mirror = Mirror(reflecting: input)
        for (label, value) in mirror.children {
            if label != nil && label != "" {
                output.setValue(value, forKey: label ?? "")
            }
        }
    }

    public static func getNonce() -> String {
        uuid()
    }

    public static func getSignature(_ request: TeaRequest, _ secret: String) -> String {
        var strToSign: String = getRpcSignedStr(method: request.method, query: request.query)
        return strToSign.generateSignature(secret: secret)
    }

    public static func json(_ response: TeaResponse) -> [String: AnyObject] {
        guard let data = try! JSONSerialization.jsonObject(with: response.data) as? [String: AnyObject] else {
            return [String: AnyObject]();
        }
        return data;
    }

    public static func hasError(_ dict: [String: AnyObject]? = nil) -> Bool {
        if (nil == dict) {
            return true;
        }
        if (nil == dict?["Code"]) {
            return false;
        }
        return true;
    }

    public static func getTimestamp() -> TimeInterval {
        Date().toTimestamp()
    }

    public static func query(_ dict: [String: AnyObject]) -> [String: AnyObject] {
        var outDict: [String: AnyObject] = [String: AnyObject]()
        for (key, value) in dict {
            outDict[key] = value
        }
        return outDict
    }

    func _default(_ str: String, _ defaultStr: String) -> String {
        let tmp = str.trimmingCharacters(in: .whitespaces)
        if tmp.isEmpty {
            return defaultStr
        }
        return str
    }

    public func defaultNumber(_ number: Int, _ defaultNumber: Int) -> Int {
        if number > 0 {
            return number
        }
        return defaultNumber
    }

    public static func getUserAgent(_ userAgent: String) -> String {
        _defaultUserAgent + " " + userAgent;
    }

    public static func getDate() -> String {
        Date().toString()
    }

    public static func parseXml(_ content: String) throws -> XML.Accessor {
        do {
            let xml = try XML.parse(content)
            return xml
        } catch {
            print("parse xml error : ", content)
            throw AliababaCloudCommonsException.ParseXMLError(content)
        }
    }

    public static func toForm(dict: [String: AnyObject]?, _ boundary: String) -> String {
        if dict == nil || dict?.count == 0 {
            return ""
        }
        var dic: [String: AnyObject] = dict!

        var str: String = ""
        var file: [String: String]? = nil
        if dic["file"] != nil {
            file = (dic["file"] as! [String: String])
            dic.removeValue(forKey: "file")
        }
        if dic["UserMeta"] != nil {
            let userMeta: [String: String] = dic["UserMeta"] as! [String: String]
            for (key, value) in userMeta {
                str += "--" + boundary + "\r\n"
                str += "Content-Disposition: form-data; name=\"x-oss-meta-" + key + "\"\r\n\r\n"
                str += value + "\r\n"
            }
            dic.removeValue(forKey: "UserMeta")
        }
        for (key, value) in dic {
            str += "--" + boundary + "\r\n"
            str += "Content-Disposition: form-data; name=\"x-oss-meta-" + key + "\"\r\n\r\n"
            str += (value as! String) + "\r\n"
        }
        if file != nil {
            let headerFile: [String: String] = file ?? [String: String]()
            str += "--" + boundary + "\r\n"
            str += "Content-Disposition: form-data; name=\"file\"; filename=\"" + (headerFile["filename"] ?? "") + "\"\r\n\r\n"
            str += "Content-Type: " + (headerFile["content-type"] ?? "")
            str += (headerFile["content"] ?? "") + "\r\n"
        }
        str += "--" + boundary + "--\r\n"
        return str
    }

    public static func getErrMessage(_ bodyStr: String) -> [String: AnyObject] {
        [String: AnyObject]()
    }

    public static func isFail(_ response: TeaResponse) -> Bool {
        let statusCode: Int = Int(response.statusCode) ?? 0
        return 200 <= statusCode && statusCode < 300
    }

    public static func getBoundary() -> String {
        let boundary: CLong = CLong(arc4random() / UInt32.max) * CLong.max
        return boundary.toString()
    }

    public static func empty(_ str: String) -> Bool {
        str.trimmingCharacters(in: .whitespaces).lengthOfBytes(using: .utf8) == 0
    }

    public static func equal(_ val1: String, _ val2: String) -> Bool {
        val1 == val2
    }

    private static func getDefaultUserAgent() -> String {
        var defaultUserAgent: String = ""
        let os = ProcessInfo().operatingSystemVersion
        let osVersion: String = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        defaultUserAgent = "Alibaba Cloud (" + osVersion + ") "
        defaultUserAgent += clientVersion
        defaultUserAgent += " Core/" + coreVersion
        return defaultUserAgent;
    }
}
