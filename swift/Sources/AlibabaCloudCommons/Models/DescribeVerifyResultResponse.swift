// This file is auto-generated, don't edit it. Thanks.

import Foundation
import Tea.Swift

open class DescribeVerifyResultResponse : TeaModel {
    @objc public var RequestId:String = "";

    @objc public var VerifyStatus:Int = 0;

    @objc public var AuthorityComparisionScore:float = 0;

    @objc public var FaceComparisonScore:float = 0;

    @objc public var IdCardFaceComparisonScore:float = 0;

    @objc public var Material:Any = nil;

    public override init() {
        super.init();
        self.__name["RequestId"] = "RequestId";
        self.__name["VerifyStatus"] = "VerifyStatus";
        self.__name["AuthorityComparisionScore"] = "AuthorityComparisionScore";
        self.__name["FaceComparisonScore"] = "FaceComparisonScore";
        self.__name["IdCardFaceComparisonScore"] = "IdCardFaceComparisonScore";
        self.__name["Material"] = "Material";
        self.__required["RequestId"] = true;
        self.__required["VerifyStatus"] = true;
        self.__required["AuthorityComparisionScore"] = true;
        self.__required["FaceComparisonScore"] = true;
        self.__required["IdCardFaceComparisonScore"] = true;
        self.__required["Material"] = true;
    }
}
