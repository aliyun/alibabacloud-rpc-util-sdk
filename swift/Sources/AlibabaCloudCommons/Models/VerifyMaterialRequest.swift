// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class VerifyMaterialRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var IdCardBackImageUrl:String = "";

    @objc public var FaceImageUrl:String = "";

    @objc public var BizType:String = "";

    @objc public var BizId:String = "";

    @objc public var Name:String = "";

    @objc public var IdCardNumber:String = "";

    @objc public var IdCardFrontImageUrl:String = "";

    @objc public var UserId:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["IdCardBackImageUrl"] = "IdCardBackImageUrl";
        self.__name["FaceImageUrl"] = "FaceImageUrl";
        self.__name["BizType"] = "BizType";
        self.__name["BizId"] = "BizId";
        self.__name["Name"] = "Name";
        self.__name["IdCardNumber"] = "IdCardNumber";
        self.__name["IdCardFrontImageUrl"] = "IdCardFrontImageUrl";
        self.__name["UserId"] = "UserId";
        self.__required["FaceImageUrl"] = true;
        self.__required["BizType"] = true;
        self.__required["BizId"] = true;
        self.__required["Name"] = true;
        self.__required["IdCardNumber"] = true;
    }
}
