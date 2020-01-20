// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeDeviceInfoResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var PageSize:Int = 0;

    @objc public var CurrentPage:Int = 0;

    @objc public var TotalCount:Int = 0;

    @objc public var DeviceInfoList:Any = nil;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["PageSize"] = "PageSize";
        self.__name["CurrentPage"] = "CurrentPage";
        self.__name["TotalCount"] = "TotalCount";
        self.__name["DeviceInfoList"] = "DeviceInfoList";
        self.__required["RequestId"] = true;
        self.__required["PageSize"] = true;
        self.__required["CurrentPage"] = true;
        self.__required["TotalCount"] = true;
        self.__required["DeviceInfoList"] = true;
    }
}
