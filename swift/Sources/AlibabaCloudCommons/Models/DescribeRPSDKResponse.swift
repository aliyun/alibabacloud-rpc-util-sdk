// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeRPSDKResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var SdkUrl:String = "";

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["SdkUrl"] = "SdkUrl";
        self.__required["RequestId"] = true;
        self.__required["SdkUrl"] = true;
    }
}
