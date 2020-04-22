import unittest
import os

from rpc_util import client
from Tea.request import TeaRequest
from Tea.model import TeaModel


class TestClient(unittest.TestCase):
    class _TeaModel(TeaModel):
        _base_type = {int, float, bool, complex, str}
        _list_type = {list, tuple, set}
        _dict_type = {dict}

        def _entity_to_dict(self, obj):
            if type(obj) in self._dict_type:
                obj_rtn = {k: self._entity_to_dict(v) for k, v in obj.items()}
                return obj_rtn
            elif type(obj) in self._list_type:
                return [self._entity_to_dict(v) for v in obj]
            elif type(obj) in self._base_type:
                return obj
            elif isinstance(obj, TeaModel):
                prop_list = [(p, not callable(getattr(obj, p)) and p[0] != "_")
                             for p in dir(obj)]
                obj_rtn = {}
                for i in prop_list:
                    if i[1]:
                        obj_rtn[obj._names.get(i[0]) or i[0]] = self._entity_to_dict(
                            getattr(obj, i[0]))
                return obj_rtn

        def to_map(self):
            prop_list = [(p, not callable(getattr(self, p)) and p[0] != "_")
                         for p in dir(self)]
            pros = {}
            for i in prop_list:
                if i[1]:
                    pros[self._names.get(i[0]) or i[0]] = self._entity_to_dict(
                        getattr(self, i[0]))
            return pros

    class TestConvertModel(_TeaModel):
        def __init__(self):
            super().__init__()
            self.requestId = "test"
            self._names["requestId"] = "RequestId"
            self.dic = {}
            self.no_map = 1
            self.sub_model = None
            self.file = None

    class TestConvertSubModel(_TeaModel):
        def __init__(self):
            super().__init__()
            self.requestId = "subTest"
            self._names["requestId"] = "RequestId"
            self.id = 2

    class TestConvertMapModel(_TeaModel):
        def __init__(self):
            super().__init__()
            self.requestId = ""
            self._names["requestId"] = "RequestId"
            self.extendId = 0
            self.dic = {}
            self.sub_model = None

        def from_map(self, dic):
            self.requestId = dic.get("RequestId") or ""
            self.extendId = dic.get("extendId") or 0
            self.dic = dic.get("dic")
            self.sub_model = TestClient.TestConvertSubModel()
            self.sub_model.requestId = dic.get("sub_model").get("RequestId")
            self.sub_model.id = dic.get("sub_model").get("id")

    def test_get_endpoint(self):
        self.assertEqual("test", client.get_endpoint("test", False, ""))

        self.assertEqual("test-internal.endpoint", client.get_endpoint("test.endpoint", False, "internal"))

        self.assertEqual("oss-accelerate.aliyuncs.com", client.get_endpoint("test", True, "accelerate"))

    def test_get_host(self):
        self.assertEqual("testEndpoint", client.get_host("", "", "testEndpoint"))

        self.assertEqual("cc.CN.aliyuncs.com", client.get_host("CC_CN", "CN", None))

    def test_get_signature(self):
        request = TeaRequest()
        request.query["query"] = "test"
        request.query["body"] = "test"
        result = client.get_signature(request, "secret")
        self.assertEqual("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result)

    def test_has_error(self):
        self.assertTrue(client.has_error(None))

        dic = {}
        self.assertFalse(client.has_error(dic))

        dic["Code"] = "a"
        self.assertTrue(client.has_error(dic))

        dic["Code"] = "1"
        self.assertTrue(client.has_error(dic))

        dic["Code"] = "0"
        self.assertFalse(client.has_error(dic))

    def test_get_timestamp(self):
        self.assertIsNotNone(client.get_timestamp())

        self.assertIn("T", client.get_timestamp())

        self.assertIn("Z", client.get_timestamp())

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
            client.convert(model, map_model)
            self.assertIsNotNone(map_model)
            self.assertEqual("test", map_model.requestId)
            self.assertEqual(0, map_model.extendId)
            self.assertEqual(2, map_model.sub_model.id)

    def test_query(self):
        dic = {}
        dic["test"] = 1
        dic["key"] = "value"
        self.assertIsNotNone(client.query(dic))
        self.assertEqual("1", client.query(dic).get("test"))

    def test_get_open_plat_form_endpoint(self):
        self.assertEqual("openplatform.aliyuncs.com",
                         client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", ""))

        self.assertEqual("openplatform.aliyuncs.com",
                         client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", "cn-hangzhou"))

        self.assertEqual("openplatform.ap-northeast-1.aliyuncs.com",
                         client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", "ap-northeast-1"))
