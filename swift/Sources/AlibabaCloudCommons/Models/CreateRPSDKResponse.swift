// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CreateRPSDKResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var TaskId:String = "";

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["TaskId"] = "TaskId";
        self.__required["RequestId"] = true;
        self.__required["TaskId"] = true;
    }
}
