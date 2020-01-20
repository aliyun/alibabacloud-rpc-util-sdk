// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CreateRPSDKRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var Lang:String = "";

    @objc public var AppUrl:String = "";

    @objc public var Platform:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["Lang"] = "Lang";
        self.__name["AppUrl"] = "AppUrl";
        self.__name["Platform"] = "Platform";
        self.__required["AppUrl"] = true;
    }
}
