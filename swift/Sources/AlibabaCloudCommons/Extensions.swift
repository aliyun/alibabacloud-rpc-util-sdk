import Foundation
import Alamofire
import PromiseKit
import CryptoSwift

extension Int {
    func toString() -> String {
        String(self)
    }
}

extension String {
    static func randomString(len: Int, randomDict: String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") -> String {
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(randomDict.count)))
            ranStr.append(randomDict[randomDict.index(randomDict.startIndex, offsetBy: index)])
        }
        return ranStr
    }

    mutating func generateSignature(secret: String, method: HMAC.Variant = HMAC.Variant.sha1) -> String {
        self = try! (HMAC(key: secret, variant: .sha1).authenticate(self.bytes).toBase64() ?? "");
        return self
    }

    func urlEncode() -> String {
        let unreserved = "*-._"
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: unreserved)
        allowedCharacterSet.addCharacters(in: " ")
        var encoded = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
        encoded = encoded?.replacingOccurrences(of: " ", with: "%20")
        return encoded ?? ""
    }

    func convertToDate(format: String) -> Date {
        dateFormatter(format: format).date(from: self)!
    }

    func convertToDate(formatter: DateFormatter) -> Date {
        formatter.date(from: self)!
    }

    func jsonDecode() -> [String: AnyObject] {
        let jsonData: Data = self.data(using: .utf8)!
        guard let data = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject] else {
            return [String: AnyObject]()
        }
        return data
    }
}

extension Date {
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ss'Z'") -> String {
        dateFormatter(format: format).string(from: self)
    }

    func toString(formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }

    func toTimestamp() -> TimeInterval {
        TimeInterval(self.timeIntervalSince1970)
    }
}
