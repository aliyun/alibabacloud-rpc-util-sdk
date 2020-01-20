// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyResultRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var BizId:String = "";

    @objc public var BizType:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["BizId"] = "BizId";
        self.__name["BizType"] = "BizType";
        self.__required["BizId"] = true;
        self.__required["BizType"] = true;
    }
}
