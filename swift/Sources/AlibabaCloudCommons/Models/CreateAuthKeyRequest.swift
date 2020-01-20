// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CreateAuthKeyRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var Lang:String = "";

    @objc public var BizType:String = "";

    @objc public var UserDeviceId:String = "";

    @objc public var Test:Bool = true;

    @objc public var AuthYears:Int = 0;

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["Lang"] = "Lang";
        self.__name["BizType"] = "BizType";
        self.__name["UserDeviceId"] = "UserDeviceId";
        self.__name["Test"] = "Test";
        self.__name["AuthYears"] = "AuthYears";
    }
}
