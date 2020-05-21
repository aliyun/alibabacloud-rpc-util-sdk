import copy
import hashlib
import hmac
import base64

from datetime import datetime
from urllib.parse import quote_plus

from Tea.model import TeaModel
from Tea.stream import STREAM_CLASS


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
            if queries[k] is not None:
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
        pros = {}
        body_map = body.to_map()
        for k, v in body_map.items():
            if not isinstance(v, STREAM_CLASS):
                pros[k] = copy.deepcopy(v)

        content.from_map(pros)

    @staticmethod
    def query(dic):
        out_dict = {}
        if dic:
            Client._object_handler('', dic, out_dict)
        return out_dict

    @staticmethod
    def _object_handler(key, value, out):
        if value is None:
            return

        if isinstance(value, dict):
            dic = value
            for k, v in dic.items():
                Client._object_handler('%s.%s' % (key, k), v, out)
        elif isinstance(value, (list, tuple)):
            lis = value
            for index, val in enumerate(lis):
                Client._object_handler('%s.%s' % (key, index+1), val, out)
        else:
            if key.startswith('.'):
                key = key[1:]
            out[key] = str(value)

    @staticmethod
    def get_open_plat_form_endpoint(endpoint, region_id):
        support_region_id = ("ap-southeast-1", "ap-northeast-1", "eu-central-1", "cn-hongkong", "ap-south-1")
        if region_id.lower() in support_region_id:
            str_split = endpoint.split(".")
            str_split[0] = str_split[0] + "." + region_id
            return ".".join(str_split)
        return endpoint
