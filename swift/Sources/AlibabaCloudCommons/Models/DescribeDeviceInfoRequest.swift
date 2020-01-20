// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeDeviceInfoRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var Lang:String = "";

    @objc public var TotalCount:Int = 0;

    @objc public var PageSize:Int = 0;

    @objc public var CurrentPage:Int = 0;

    @objc public var DeviceId:String = "";

    @objc public var BizType:String = "";

    @objc public var UserDeviceId:String = "";

    @objc public var ExpiredStartDay:String = "";

    @objc public var ExpiredEndDay:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["Lang"] = "Lang";
        self.__name["TotalCount"] = "TotalCount";
        self.__name["PageSize"] = "PageSize";
        self.__name["CurrentPage"] = "CurrentPage";
        self.__name["DeviceId"] = "DeviceId";
        self.__name["BizType"] = "BizType";
        self.__name["UserDeviceId"] = "UserDeviceId";
        self.__name["ExpiredStartDay"] = "ExpiredStartDay";
        self.__name["ExpiredEndDay"] = "ExpiredEndDay";
    }
}
