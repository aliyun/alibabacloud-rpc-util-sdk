// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class RuntimeObject : TeaModel {
    @objc public var autoretry:Bool = true;

    @objc public var ignoreSSL:Bool = true;

    @objc public var maxAttempts:Int = 0;

    @objc public var backoffPolicy:String = "";

    @objc public var backoffPeriod:Int = 0;

    @objc public var readTimeout:Int = 0;

    @objc public var connectTimeout:Int = 0;

    @objc public var httpProxy:String = "";

    @objc public var httpsProxy:String = "";

    @objc public var noProxy:String = "";

    @objc public var maxIdleConns:Int = 0;

    public override init() {
        super.init();
        self.__name["autoretry"] = "autoretry";
        self.__name["ignoreSSL"] = "ignoreSSL";
        self.__name["maxAttempts"] = "max_attempts";
        self.__name["backoffPolicy"] = "backoff_policy";
        self.__name["backoffPeriod"] = "backoff_period";
        self.__name["readTimeout"] = "readTimeout";
        self.__name["connectTimeout"] = "connectTimeout";
        self.__name["httpProxy"] = "httpProxy";
        self.__name["httpsProxy"] = "httpsProxy";
        self.__name["noProxy"] = "noProxy";
        self.__name["maxIdleConns"] = "maxIdleConns";
        self.__required["autoretry"] = true;
        self.__required["ignoreSSL"] = true;
        self.__required["maxAttempts"] = true;
        self.__required["backoffPolicy"] = true;
        self.__required["backoffPeriod"] = true;
        self.__required["readTimeout"] = true;
        self.__required["connectTimeout"] = true;
        self.__required["httpProxy"] = true;
        self.__required["httpsProxy"] = true;
        self.__required["noProxy"] = true;
        self.__required["maxIdleConns"] = true;
    }
}
