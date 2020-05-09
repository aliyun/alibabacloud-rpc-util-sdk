import copy
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
    def get_endpoint(endpoint, server_use, endpoint_type):
        if endpoint_type == "internal":
            str_split = endpoint.split('.')
            str_split[0] += "-internal"
            endpoint = ".".join(str_split)

        if server_use and endpoint_type == "accelerate":
            return "oss-accelerate.aliyuncs.com"

        return endpoint

    @staticmethod
    def get_host(product_id, region_id, endpoint):
        if not endpoint:
            service_code = product_id.split('_')[0].lower()
            return "{}.{}.aliyuncs.com".format(service_code, region_id)

        return endpoint

    @staticmethod
    def get_signature(request, secret):
        return Client._get_rpc_signature(request.query, request.method, secret)

    @staticmethod
    def get_signature_v1(signed_params, method, secret):
        return Client._get_rpc_signature(signed_params, method, secret)

    @staticmethod
    def _get_rpc_signature(signed_params, method, secret):
        queries = signed_params.copy()
        keys = list(queries.keys())
        keys.sort()

        canonicalized_query_string = ""

        for k in keys:
            if queries[k]:
                canonicalized_query_string += "&"
                canonicalized_query_string += quote_plus(k, encoding="utf-8")
                canonicalized_query_string += "="
                canonicalized_query_string += quote_plus(queries[k], encoding="utf-8")

        string_to_sign = ""
        string_to_sign += method
        string_to_sign += Client.SEPARATOR
        string_to_sign += quote_plus("/", encoding="utf-8")
        string_to_sign += Client.SEPARATOR
        string_to_sign += quote_plus(
            canonicalized_query_string[1:] if canonicalized_query_string.__len__() > 0 else canonicalized_query_string,
            encoding="utf-8")
        digest_maker = hmac.new(bytes(secret + Client.SEPARATOR, encoding="utf-8"),
                                bytes(string_to_sign, encoding="utf-8"),
                                digestmod=hashlib.sha1)
        hash_bytes = digest_maker.digest()
        signed_str = str(base64.b64encode(hash_bytes), encoding="utf-8")

        return signed_str

    @staticmethod
    def has_error(obj):
        if obj is None:
            return True
        result_code = obj.get("Code")
        if result_code is None:
            return False
        try:
            return int(result_code) > 0
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
                    pros[body._names.get(i[0]) or i[0]] = copy.deepcopy(
                        val if not isinstance(val, TeaModel) else val.to_map())

        content.from_map(pros)

    @staticmethod
    def query(dic):
        out_dic = {}
        for k in dic:
            out_dic[k] = str(dic[k]) if dic[k] is not None else ""
        return out_dic

    @staticmethod
    def get_open_plat_form_endpoint(endpoint, region_id):
        support_region_id = ("ap-southeast-1", "ap-northeast-1", "eu-central-1", "cn-hongkong", "ap-south-1")
        if region_id.lower() in support_region_id:
            str_split = endpoint.split(".")
            str_split[0] = str_split[0] + "." + region_id
            return ".".join(str_split)
        return endpoint
