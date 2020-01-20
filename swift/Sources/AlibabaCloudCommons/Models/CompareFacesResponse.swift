// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CompareFacesResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var Success:Bool = true;

    @objc public var Code:String = "";

    @objc public var Message:String = "";

    @objc public var Data:Any = nil;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["Success"] = "Success";
        self.__name["Code"] = "Code";
        self.__name["Message"] = "Message";
        self.__name["Data"] = "Data";
        self.__required["RequestId"] = true;
        self.__required["Success"] = true;
        self.__required["Code"] = true;
        self.__required["Message"] = true;
        self.__required["Data"] = true;
    }
}
