# -*- coding: utf-8 -*-
import unittest
import os

from alibabacloud_rpc_util.client import Client
from Tea.request import TeaRequest
from Tea.model import TeaModel


class TestClient(unittest.TestCase):

    class TestConvertModel(TeaModel):
        def __init__(self):
            self.requestId = "test"
            self.dic = {}
            self.no_map = 1
            self.sub_model = None
            self.file = None

        def to_map(self):
            dic = {
                'requestId': self.requestId,
                'dic': self.dic,
                'no_map': self.no_map,
                'sub_model': self.sub_model,
                'file': self.file
            }
            return dic

    class TestConvertSubModel(TeaModel):
        def __init__(self):
            self.requestId = "subTest"
            self.id = 2

        def to_map(self):
            dic = {
                'requestId': self.requestId,
                'id': self.id
            }
            return dic

    class TestConvertMapModel(TeaModel):
        def __init__(self):
            self.requestId = ""
            self.extendId = 0
            self.dic = {}
            self.sub_model = None

        def to_map(self):
            dic = {
                'requestId': self.requestId,
                'dic': self.dic,
                'extendId': self.extendId,
                'sub_model': self.sub_model,
            }
            return dic

        def from_map(self, dic=None):
            self.requestId = dic.get("requestId") or ""
            self.extendId = dic.get("extendId") or 0
            self.dic = dic.get("dic")
            self.sub_model = dic.get("sub_model")

    def test_get_endpoint(self):
        self.assertEqual("test", Client.get_endpoint("test", False, ""))

        self.assertEqual("test-internal.endpoint", Client.get_endpoint("test.endpoint", False, "internal"))

        self.assertEqual("oss-accelerate.aliyuncs.com", Client.get_endpoint("test", True, "accelerate"))

    def test_get_host(self):
        self.assertEqual("testEndpoint", Client.get_host("", "", "testEndpoint"))

        self.assertEqual("cc.CN.aliyuncs.com", Client.get_host("CC_CN", "CN", None))

    def test_get_signature(self):
        request = TeaRequest()
        request.query["query"] = "test"
        request.query["body"] = "test"
        result = Client.get_signature(request, "secret")
        self.assertEqual("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result)

    def test_get_signature_v1(self):
        query = {
            'query': 'test',
            'body': 'test'
        }
        result = Client.get_signature_v1(query, 'GET', 'secret')
        self.assertEqual("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result)

    def test_has_error(self):
        self.assertTrue(Client.has_error(None))

        dic = {}
        self.assertFalse(Client.has_error(dic))

        dic["Code"] = "a"
        self.assertTrue(Client.has_error(dic))

        dic["Code"] = "1"
        self.assertTrue(Client.has_error(dic))

        dic["Code"] = "0"
        self.assertFalse(Client.has_error(dic))

    def test_get_timestamp(self):
        self.assertIsNotNone(Client.get_timestamp())

        self.assertIn("T", Client.get_timestamp())

        self.assertIn("Z", Client.get_timestamp())

    def test_convert(self):
        module_path = os.path.dirname(__file__)
        filename = module_path + "/test_open.txt"
        with open(filename) as f:
            model = TestClient.TestConvertModel()
            model.dic["key"] = "value"
            model.dic["testKey"] = "testValue"
            sub_model = TestClient.TestConvertSubModel()
            model.sub_model = sub_model
            model.file = f
            map_model = TestClient.TestConvertMapModel()
            Client.convert(model, map_model)
            self.assertIsNotNone(map_model)
            self.assertEqual("test", map_model.requestId)
            self.assertEqual(0, map_model.extendId)
            self.assertEqual(2, map_model.sub_model.id)

    def test_query(self):
        result = Client.query(None)
        self.assertEqual(0, len(result))
        dic = {
            'str_test': 'test',
            'bytes_test': b'test',
            'none_test': None,
            'int_test': 1
        }
        result = Client.query(dic)
        self.assertEqual('test', result.get('str_test'))
        self.assertEqual('test', result.get('bytes_test'))
        self.assertIsNone(result.get("none_test"))
        self.assertEqual("1", result.get("int_test"))

        fl = [1, None]
        sub_dict_fl = {
            'none_test': None,
            'int_test': 2,
            'str_test': 'test'
        }
        fl.append(sub_dict_fl)
        sl = [1, None]
        fl.append(sl)
        dic['list'] = fl
        result = Client.query(dic)
        self.assertEqual("1", result.get("list.1"))
        self.assertIsNone(result.get("list.2"))
        self.assertEqual("1", result.get("int_test"))
        self.assertEqual("2", result.get("list.3.int_test"))
        self.assertIsNone(result.get("list.3.none_test"))
        self.assertEqual("test", result.get("list.3.str_test"))
        self.assertEqual("1", result.get("list.4.1"))

        sub_map_fd = {
            'none_test': None,
            'int_test': 2,
            'str_test': 'test'
        }
        fd = {
            'first_map_map': sub_map_fd,
            'first_map_list': sl,
            'none_test': None,
            'int_test': 2,
            'str_test': 'test'
        }
        dic['map'] = fd

        result = Client.query(dic)
        self.assertEqual("1", result.get("map.first_map_list.1"))
        self.assertIsNone(result.get("map.none_test"))
        self.assertEqual("2", result.get("map.int_test"))
        self.assertEqual("test", result.get("map.str_test"))
        self.assertIsNone(result.get("map.first_map_map.none_test"))
        self.assertEqual("2", result.get("map.first_map_map.int_test"))
        self.assertEqual("test", result.get("map.first_map_map.str_test"))

    def test_get_open_plat_form_endpoint(self):
        self.assertEqual("openplatform.aliyuncs.com",
                         Client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", ""))

        self.assertEqual("openplatform.aliyuncs.com",
                         Client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", "cn-hangzhou"))

        self.assertEqual("openplatform.ap-northeast-1.aliyuncs.com",
                         Client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", "ap-northeast-1"))
