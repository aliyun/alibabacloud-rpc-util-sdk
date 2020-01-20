// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifySettingResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var VerifySettingList:[String:Any] = [String:NSObject]();

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["VerifySettingList"] = "VerifySettingList";
        self.__required["RequestId"] = true;
        self.__required["VerifySettingList"] = true;
    }
}
