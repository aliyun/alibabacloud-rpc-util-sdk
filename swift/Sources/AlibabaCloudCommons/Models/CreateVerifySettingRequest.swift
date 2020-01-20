// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CreateVerifySettingRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var BizType:String = "";

    @objc public var BizName:String = "";

    @objc public var Solution:String = "";

    @objc public var GuideStep:Bool = true;

    @objc public var PrivacyStep:Bool = true;

    @objc public var ResultStep:Bool = true;

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["BizType"] = "BizType";
        self.__name["BizName"] = "BizName";
        self.__name["Solution"] = "Solution";
        self.__name["GuideStep"] = "GuideStep";
        self.__name["PrivacyStep"] = "PrivacyStep";
        self.__name["ResultStep"] = "ResultStep";
        self.__required["BizType"] = true;
        self.__required["BizName"] = true;
        self.__required["Solution"] = true;
    }
}
