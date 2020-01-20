// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeFaceUsageResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var TotalCount:Int = 0;

    @objc public var FaceUsageList:[String:Any] = [String:NSObject]();

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["TotalCount"] = "TotalCount";
        self.__name["FaceUsageList"] = "FaceUsageList";
        self.__required["RequestId"] = true;
        self.__required["TotalCount"] = true;
        self.__required["FaceUsageList"] = true;
    }
}
