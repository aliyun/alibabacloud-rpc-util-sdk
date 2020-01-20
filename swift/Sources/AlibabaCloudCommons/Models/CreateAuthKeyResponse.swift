// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CreateAuthKeyResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var AuthKey:String = "";

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["AuthKey"] = "AuthKey";
        self.__required["RequestId"] = true;
        self.__required["AuthKey"] = true;
    }
}
