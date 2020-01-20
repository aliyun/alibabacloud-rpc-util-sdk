// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyUsageResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var TotalCount:Int = 0;

    @objc public var VerifyUsageList:[String:Any] = [String:NSObject]();

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["TotalCount"] = "TotalCount";
        self.__name["VerifyUsageList"] = "VerifyUsageList";
        self.__required["RequestId"] = true;
        self.__required["TotalCount"] = true;
        self.__required["VerifyUsageList"] = true;
    }
}
