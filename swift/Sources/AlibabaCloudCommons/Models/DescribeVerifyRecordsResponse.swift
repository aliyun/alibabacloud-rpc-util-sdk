// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyRecordsResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var TotalCount:Int = 0;

    @objc public var PageSize:Int = 0;

    @objc public var CurrentPage:Int = 0;

    @objc public var QueryId:String = "";

    @objc public var RecordsList:[String:Any] = [String:NSObject]();

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["TotalCount"] = "TotalCount";
        self.__name["PageSize"] = "PageSize";
        self.__name["CurrentPage"] = "CurrentPage";
        self.__name["QueryId"] = "QueryId";
        self.__name["RecordsList"] = "RecordsList";
        self.__required["RequestId"] = true;
        self.__required["TotalCount"] = true;
        self.__required["PageSize"] = true;
        self.__required["CurrentPage"] = true;
        self.__required["QueryId"] = true;
        self.__required["RecordsList"] = true;
    }
}
