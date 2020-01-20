// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyTokenRequest : TeaModel {
    @objc public var SourceIp:String = "";

    @objc public var IdCardBackImageUrl:String = "";

    @objc public var BizType:String = "";

    @objc public var FailedRedirectUrl:String = "";

    @objc public var FaceRetainedImageUrl:String = "";

    @objc public var CallbackSeed:String = "";

    @objc public var IdCardFrontImageUrl:String = "";

    @objc public var UserId:String = "";

    @objc public var BizId:String = "";

    @objc public var Name:String = "";

    @objc public var IdCardNumber:String = "";

    @objc public var PassedRedirectUrl:String = "";

    @objc public var CallbackUrl:String = "";

    public override init() {
        super.init();
        self.__name["SourceIp"] = "SourceIp";
        self.__name["IdCardBackImageUrl"] = "IdCardBackImageUrl";
        self.__name["BizType"] = "BizType";
        self.__name["FailedRedirectUrl"] = "FailedRedirectUrl";
        self.__name["FaceRetainedImageUrl"] = "FaceRetainedImageUrl";
        self.__name["CallbackSeed"] = "CallbackSeed";
        self.__name["IdCardFrontImageUrl"] = "IdCardFrontImageUrl";
        self.__name["UserId"] = "UserId";
        self.__name["BizId"] = "BizId";
        self.__name["Name"] = "Name";
        self.__name["IdCardNumber"] = "IdCardNumber";
        self.__name["PassedRedirectUrl"] = "PassedRedirectUrl";
        self.__name["CallbackUrl"] = "CallbackUrl";
        self.__required["BizType"] = true;
        self.__required["BizId"] = true;
    }
}
