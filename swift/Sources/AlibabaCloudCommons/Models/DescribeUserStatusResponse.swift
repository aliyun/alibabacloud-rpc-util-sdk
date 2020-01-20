// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeUserStatusResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var Enabled:Bool = true;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["Enabled"] = "Enabled";
        self.__required["RequestId"] = true;
        self.__required["Enabled"] = true;
    }
}
