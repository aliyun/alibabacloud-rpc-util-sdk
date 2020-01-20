// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CreateVerifySettingResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var BizType:String = "";

    @objc public var BizName:String = "";

    @objc public var Solution:String = "";

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["BizType"] = "BizType";
        self.__name["BizName"] = "BizName";
        self.__name["Solution"] = "Solution";
        self.__required["RequestId"] = true;
        self.__required["BizType"] = true;
        self.__required["BizName"] = true;
        self.__required["Solution"] = true;
    }
}
