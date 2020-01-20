// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyRecordsRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var TotalCount:Int = 0;

    @objc public var PageSize:Int = 0;

    @objc public var CurrentPage:Int = 0;

    @objc public var BizType:String = "";

    @objc public var StartDate:String = "";

    @objc public var EndDate:String = "";

    @objc public var BizId:String = "";

    @objc public var IdCardNum:String = "";

    @objc public var StatusList:String = "";

    @objc public var QueryId:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["TotalCount"] = "TotalCount";
        self.__name["PageSize"] = "PageSize";
        self.__name["CurrentPage"] = "CurrentPage";
        self.__name["BizType"] = "BizType";
        self.__name["StartDate"] = "StartDate";
        self.__name["EndDate"] = "EndDate";
        self.__name["BizId"] = "BizId";
        self.__name["IdCardNum"] = "IdCardNum";
        self.__name["StatusList"] = "StatusList";
        self.__name["QueryId"] = "QueryId";
        self.__required["PageSize"] = true;
        self.__required["CurrentPage"] = true;
    }
}
