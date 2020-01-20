// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class CompareFacesRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var ResourceOwnerId:Int64 = 0;

    @objc public var TargetImageType:String = "";

    @objc public var SourceImageType:String = "";

    @objc public var SourceImageValue:String = "";

    @objc public var TargetImageValue:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["ResourceOwnerId"] = "ResourceOwnerId";
        self.__name["TargetImageType"] = "TargetImageType";
        self.__name["SourceImageType"] = "SourceImageType";
        self.__name["SourceImageValue"] = "SourceImageValue";
        self.__name["TargetImageValue"] = "TargetImageValue";
    }
}
