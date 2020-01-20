// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribePageSettingResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var FailReasons:map = [String:Any]();

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["FailReasons"] = "FailReasons";
        self.__required["RequestId"] = true;
        self.__required["FailReasons"] = true;
    }
}
