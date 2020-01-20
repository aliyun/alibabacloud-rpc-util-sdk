// This file is auto-generated, don't edit it. Thanks.

import Common
import Common.RuntimeObject
import Foundation
import Tea.Swift

open class Client : BaseClient {
    public init(config:Config) {
        super.init(config.toMap())
    }

    public func detectFaceAttributes(request:DetectFaceAttributesRequest, runtime:TeaModel) throws {
        return super._request("DetectFaceAttributes", "HTTPS", "POST", request, runtime)
    }

    public func compareFaces(request:CompareFacesRequest, runtime:TeaModel) throws {
        return super._request("CompareFaces", "HTTPS", "POST", request, runtime)
    }

    public func describeVerifySDK(request:DescribeVerifySDKRequest, runtime:TeaModel) throws {
        return super._request("DescribeVerifySDK", "HTTPS", "GET", request, runtime)
    }

    public func modifyDeviceInfo(request:ModifyDeviceInfoRequest, runtime:TeaModel) throws {
        return super._request("ModifyDeviceInfo", "HTTPS", "GET", request, runtime)
    }

    public func createVerifySDK(request:CreateVerifySDKRequest, runtime:TeaModel) throws {
        return super._request("CreateVerifySDK", "HTTPS", "GET", request, runtime)
    }

    public func createAuthKey(request:CreateAuthKeyRequest, runtime:TeaModel) throws {
        return super._request("CreateAuthKey", "HTTPS", "GET", request, runtime)
    }

    public func describeDeviceInfo(request:DescribeDeviceInfoRequest, runtime:TeaModel) throws {
        return super._request("DescribeDeviceInfo", "HTTPS", "GET", request, runtime)
    }

    public func describeFaceUsage(request:DescribeFaceUsageRequest, runtime:TeaModel) throws {
        return super._request("DescribeFaceUsage", "HTTPS", "GET", request, runtime)
    }

    public func updateVerifySetting(request:UpdateVerifySettingRequest, runtime:TeaModel) throws {
        return super._request("UpdateVerifySetting", "HTTPS", "GET", request, runtime)
    }

    public func createVerifySetting(request:CreateVerifySettingRequest, runtime:TeaModel) throws {
        return super._request("CreateVerifySetting", "HTTPS", "GET", request, runtime)
    }

    public func describeVerifySetting(request:DescribeVerifySettingRequest, runtime:TeaModel) throws {
        return super._request("DescribeVerifySetting", "HTTPS", "GET", request, runtime)
    }

    public func describeVerifyRecords(request:DescribeVerifyRecordsRequest, runtime:TeaModel) throws {
        return super._request("DescribeVerifyRecords", "HTTPS", "GET", request, runtime)
    }

    public func describePageSetting(request:DescribePageSettingRequest, runtime:TeaModel) throws {
        return super._request("DescribePageSetting", "HTTPS", "GET", request, runtime)
    }

    public func describeVerifyUsage(request:DescribeVerifyUsageRequest, runtime:TeaModel) throws {
        return super._request("DescribeVerifyUsage", "HTTPS", "GET", request, runtime)
    }

    public func describeUserStatus(request:DescribeUserStatusRequest, runtime:TeaModel) throws {
        return super._request("DescribeUserStatus", "HTTPS", "GET", request, runtime)
    }

    public func describeUploadInfo(request:DescribeUploadInfoRequest, runtime:TeaModel) throws {
        return super._request("DescribeUploadInfo", "HTTPS", "GET", request, runtime)
    }

    public func describeVerifyToken(request:DescribeVerifyTokenRequest, runtime:TeaModel) throws {
        return super._request("DescribeVerifyToken", "HTTPS", "GET", request, runtime)
    }

    public func describeOssUploadToken(request:DescribeOssUploadTokenRequest, runtime:TeaModel) throws {
        return super._request("DescribeOssUploadToken", "HTTPS", "GET", request, runtime)
    }

    public func describeVerifyResult(request:DescribeVerifyResultRequest, runtime:TeaModel) throws {
        return super._request("DescribeVerifyResult", "HTTPS", "GET", request, runtime)
    }

    public func verifyMaterial(request:VerifyMaterialRequest, runtime:TeaModel) throws {
        return super._request("VerifyMaterial", "HTTPS", "GET", request, runtime)
    }

    public func describeRPSDK(request:DescribeRPSDKRequest, runtime:TeaModel) throws {
        return super._request("DescribeRPSDK", "HTTPS", "GET", request, runtime)
    }

    public func createRPSDK(request:CreateRPSDKRequest, runtime:TeaModel) throws {
        return super._request("CreateRPSDK", "HTTPS", "GET", request, runtime)
    }

    public func _request(action:String, protocol:String, method:String, request:[String:AnyObject], runtime:TeaModel) throws {
        var runtime_:[String:Any] = [
            "timeouted": "retry",
            "readTimeout": Common(runtime.readTimeout, super._readTimeout).defaultNumber(runtime.readTimeout, super._readTimeout),
            "connectTimeout": Common(runtime.connectTimeout, super._connectTimeout).defaultNumber(runtime.connectTimeout, super._connectTimeout),
            "httpProxy": Common(runtime.httpProxy, super._httpProxy).default_(runtime.httpProxy, super._httpProxy),
            "httpsProxy": Common(runtime.httpsProxy, super._httpsProxy).default_(runtime.httpsProxy, super._httpsProxy),
            "noProxy": Common(runtime.noProxy, super._noProxy).default_(runtime.noProxy, super._noProxy),
            "maxIdleConns": Common(runtime.maxIdleConns, super._maxIdleConns).defaultNumber(runtime.maxIdleConns, super._maxIdleConns),
            "retry": [
                "retryable": runtime.autoretry,
                "maxAttempts": Common(runtime.maxAttempts, 3).defaultNumber(runtime.maxAttempts, 3)
            ],
            "backoff": [
                "policy": Common(runtime.backoffPolicy, "no").default_(runtime.backoffPolicy, "no"),
                "period": Common(runtime.backoffPeriod, 1).defaultNumber(runtime.backoffPeriod, 1)
            ],
            "ignoreSSL": runtime.ignoreSSL
        ]
        var _lastRequest:TeaRequest? = nil
        var _now:Int32 = Int32(Date().timeIntervalSince1970)
        var _retryTimes:Int = 0
        while TeaCore.allowRetry(runtime_["retry"], _retryTimes, _now) {
            if _retryTimes > 0 {
                var _backoffTime:Int = TeaCore.getBackoffTime(runtime_["backoff"], _retryTimes)
                if _backoffTime > 0 {
                    TeaCore.sleep(_backoffTime)
                }
            }
            _retryTimes = _retryTimes + 1
            do {
                var request_ = TeaRequest()
                request_.protocol_ = Common(super._protocol, protocol).default_(super._protocol, protocol)
                request_.method = method
                request_.pathname = "/"
                request_.headers = [
                    "host": Common("Cloudauth", super._regionId, super._endpoint).getHost("Cloudauth", super._regionId, super._endpoint),
                    "user-agent": Common(super._userAgent).getUserAgent(super._userAgent)
                ]
                request_.query["Signature"] = Common(request_, super._getAccessKeySecret()).getSignature(request_, super._getAccessKeySecret())
                _lastRequest = request_
                let response_ = TeaCore.doAction(request_, runtime_)
                body = Common(response_).json(response_)
                if Common(body).hasError(body) {
                    throw TeaException.Error([
                        "message": body["Message"],
                        "data": body,
                        "code": body["Code"]
                    ])
                }
                return body
            }
            catch let e as TeaException {
                if TeaCore.isRetryable(e) {
                    continue
                }
                throw e
            }
        }
        throw TeaException.Unretryable(_lastRequest)
    }
}
