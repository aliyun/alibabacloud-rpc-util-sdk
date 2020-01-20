// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class Config : TeaModel {
    @objc public var accessKeyId:String = "";

    @objc public var accessKeySecret:String = "";

    @objc public var type:String = "";

    @objc public var securityToken:String = "";

    @objc public var endpoint:String = "";

    @objc public var protocol_:String = "";

    @objc public var regionId:String = "";

    public override init() {
        super.init();
        self.__name["accessKeyId"] = "accessKeyId";
        self.__name["accessKeySecret"] = "accessKeySecret";
        self.__name["type"] = "type";
        self.__name["securityToken"] = "securityToken";
        self.__name["endpoint"] = "endpoint";
        self.__name["protocol_"] = "protocol";
        self.__name["regionId"] = "regionId";
        self.__required["accessKeyId"] = true;
        self.__required["accessKeySecret"] = true;
        self.__required["type"] = true;
        self.__required["securityToken"] = true;
        self.__required["endpoint"] = true;
        self.__required["protocol_"] = true;
        self.__required["regionId"] = true;
    }
}
