// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyTokenResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var VerifyPageUrl:String = "";

    @objc public var VerifyToken:String = "";

    @objc public var OssUploadToken:Any = nil;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["VerifyPageUrl"] = "VerifyPageUrl";
        self.__name["VerifyToken"] = "VerifyToken";
        self.__name["OssUploadToken"] = "OssUploadToken";
        self.__required["RequestId"] = true;
        self.__required["VerifyPageUrl"] = true;
        self.__required["VerifyToken"] = true;
        self.__required["OssUploadToken"] = true;
    }
}
