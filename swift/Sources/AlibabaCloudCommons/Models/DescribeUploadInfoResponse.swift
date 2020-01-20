// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeUploadInfoResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var Accessid:String = "";

    @objc public var Policy:String = "";

    @objc public var Signature:String = "";

    @objc public var Folder:String = "";

    @objc public var Host:String = "";

    @objc public var Expire:Int64 = 0;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["Accessid"] = "Accessid";
        self.__name["Policy"] = "Policy";
        self.__name["Signature"] = "Signature";
        self.__name["Folder"] = "Folder";
        self.__name["Host"] = "Host";
        self.__name["Expire"] = "Expire";
        self.__required["RequestId"] = true;
        self.__required["Accessid"] = true;
        self.__required["Policy"] = true;
        self.__required["Signature"] = true;
        self.__required["Folder"] = true;
        self.__required["Host"] = true;
        self.__required["Expire"] = true;
    }
}
