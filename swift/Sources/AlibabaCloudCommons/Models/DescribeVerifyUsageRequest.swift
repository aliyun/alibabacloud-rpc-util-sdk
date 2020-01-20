// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyUsageRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var BizType:String = "";

    @objc public var StartDate:String = "";

    @objc public var EndDate:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["BizType"] = "BizType";
        self.__name["StartDate"] = "StartDate";
        self.__name["EndDate"] = "EndDate";
        self.__required["StartDate"] = true;
        self.__required["EndDate"] = true;
    }
}
