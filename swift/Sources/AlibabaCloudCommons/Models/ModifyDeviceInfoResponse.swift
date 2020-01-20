// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class ModifyDeviceInfoResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var DeviceId:String = "";

    @objc public var UserDeviceId:String = "";

    @objc public var BizType:String = "";

    @objc public var BeginDay:String = "";

    @objc public var ExpiredDay:String = "";

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["DeviceId"] = "DeviceId";
        self.__name["UserDeviceId"] = "UserDeviceId";
        self.__name["BizType"] = "BizType";
        self.__name["BeginDay"] = "BeginDay";
        self.__name["ExpiredDay"] = "ExpiredDay";
        self.__required["RequestId"] = true;
        self.__required["DeviceId"] = true;
        self.__required["UserDeviceId"] = true;
        self.__required["BizType"] = true;
        self.__required["BeginDay"] = true;
        self.__required["ExpiredDay"] = true;
    }
}
