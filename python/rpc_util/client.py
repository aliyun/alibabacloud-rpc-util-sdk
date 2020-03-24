import copy
import json
import hashlib
import hmac
import base64

from datetime import datetime
from _io import TextIOWrapper
from urllib.parse import quote_plus
from Tea.model import TeaModel

class Client:
    SEPARATOR = "&"

    @staticmethod
    def get_endpoint(endpoint, serverUse, endpointType):
        if endpointType == "internal":
            str_split = endpoint.split('.')
            str_split[0] += "-internal"
            endpoint = ".".join(str_split)
        
        if serverUse and endpointType == "accelerate":
            return "oss-accelerate.aliyuncs.com"

        return endpoint

    @staticmethod
    def get_host(productId, regionId, endpoint):
        if not endpoint:
            serviceCode = productId.split('_')[0].lower()
            return "{}.{}.aliyuncs.com".format(serviceCode,regionId)

        return endpoint

    @staticmethod
    def get_signature(request, secret):
        queries = request.query.copy()
        keys = list(queries.keys())
        keys.sort()

        canonicalizedQueryString = ""

        for k in keys:
            if queries[k]:
                canonicalizedQueryString += "&"
                canonicalizedQueryString += quote_plus(k,encoding="utf-8")
                canonicalizedQueryString += "="
                canonicalizedQueryString += quote_plus(queries[k], encoding="utf-8")

        stringToSign = ""
        stringToSign += request.method
        stringToSign += Client.SEPARATOR
        stringToSign += quote_plus("/", encoding="utf-8")
        stringToSign += Client.SEPARATOR
        stringToSign += quote_plus(canonicalizedQueryString[1:] if canonicalizedQueryString.__len__() > 0 else canonicalizedQueryString, encoding="utf-8")
        print("Alibabacloud.Common.GetSignature:stringToSign is " + stringToSign)
        digest_maker = hmac.new(bytes(secret + Client.SEPARATOR, encoding="utf-8"), bytes(stringToSign, encoding="utf-8"), digestmod=hashlib.sha1)
        hash_bytes = digest_maker.digest()
        signedStr = str(base64.b64encode(hash_bytes),encoding="utf-8")

        return signedStr

    @staticmethod
    def has_error(obj):
        if obj is None:
            return True
        resultCode = obj.get("Code")
        if resultCode is None:
            return False
        try:
            return int(resultCode) > 0
        except ValueError:
            return True

    @staticmethod
    def get_timestamp():
        return datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    
    @staticmethod
    def convert(body, content):
        prop_list = [(p, not callable(getattr(body, p)) and p[0] != "_")
                     for p in dir(body)]
        pros = {}
        for i in prop_list:
            if i[1]:
                val = getattr(body, i[0])
                if not isinstance(val, TextIOWrapper):
                    pros[body._names.get(i[0]) or i[0]] = val if not isinstance(val, TeaModel) else val.to_map()
                
        json_body = json.dumps(pros)
        dic = json.loads(json_body)
        content.to_object(dic)

    @staticmethod
    def query(dic):
        out_dic = {}
        for k in dic:
            out_dic[k] = str(dic[k]) if dic[k] is not None else ""
        return out_dic

    @staticmethod
    def get_open_plat_form_endpoint(endpoint, regionId):
        supportRegionId = ("ap-southeast-1", "ap-northeast-1", "eu-central-1", "cn-hongkong", "ap-south-1")
        if regionId.lower() in supportRegionId:
            str_split = endpoint.split(".")
            str_split[0] = str_split[0] + "." + regionId
            return ".".join(str_split)
        return endpoint
