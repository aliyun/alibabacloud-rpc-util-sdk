// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeOssUploadTokenResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var OssUploadToken:Any = nil;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["OssUploadToken"] = "OssUploadToken";
        self.__required["RequestId"] = true;
        self.__required["OssUploadToken"] = true;
    }
}
