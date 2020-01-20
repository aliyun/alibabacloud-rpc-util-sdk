// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DetectFaceAttributesRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var ResourceOwnerId:Int64 = 0;

    @objc public var MaterialValue:String = "";

    @objc public var DontSaveDB:Bool = true;

    @objc public var ClientTag:String = "";

    @objc public var MaxNumPhotosPerCategory:Int = 0;

    @objc public var RetAttributes:String = "";

    @objc public var MaxFaceNum:Int = 0;

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["ResourceOwnerId"] = "ResourceOwnerId";
        self.__name["MaterialValue"] = "MaterialValue";
        self.__name["DontSaveDB"] = "DontSaveDB";
        self.__name["ClientTag"] = "ClientTag";
        self.__name["MaxNumPhotosPerCategory"] = "MaxNumPhotosPerCategory";
        self.__name["RetAttributes"] = "RetAttributes";
        self.__name["MaxFaceNum"] = "MaxFaceNum";
        self.__required["MaterialValue"] = true;
        self.__required["DontSaveDB"] = true;
        self.__required["ClientTag"] = true;
        self.__required["MaxNumPhotosPerCategory"] = true;
        self.__required["RetAttributes"] = true;
        self.__required["MaxFaceNum"] = true;
    }
}
