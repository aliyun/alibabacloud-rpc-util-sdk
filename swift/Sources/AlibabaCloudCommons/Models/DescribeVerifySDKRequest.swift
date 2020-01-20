// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifySDKRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var Lang:String = "";

    @objc public var TaskId:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["Lang"] = "Lang";
        self.__name["TaskId"] = "TaskId";
        self.__required["TaskId"] = true;
    }
}
