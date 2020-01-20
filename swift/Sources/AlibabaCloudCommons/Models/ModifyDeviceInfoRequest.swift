// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class ModifyDeviceInfoRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var Lang:String = "";

    @objc public var DeviceId:String = "";

    @objc public var UserDeviceId:String = "";

    @objc public var BizType:String = "";

    @objc public var Duration:String = "";

    @objc public var ExpiredDay:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["Lang"] = "Lang";
        self.__name["DeviceId"] = "DeviceId";
        self.__name["UserDeviceId"] = "UserDeviceId";
        self.__name["BizType"] = "BizType";
        self.__name["Duration"] = "Duration";
        self.__name["ExpiredDay"] = "ExpiredDay";
        self.__required["DeviceId"] = true;
    }
}
