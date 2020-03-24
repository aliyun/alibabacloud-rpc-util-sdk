import unittest
import os

from rpc_util.client import Client
from Tea.request import TeaRequest
from Tea.model import TeaModel

class TestClient(unittest.TestCase):

    class TestConvertModel(TeaModel):
        def __init__(self):
                super().__init__()
                self.requestId = "test"
                self._names["requestId"] = "RequestId"
                self.dic = {}
                self.no_map = 1
                self.sub_model = None
                self.file = None

    class TestConvertSubModel(TeaModel):
        def __init__(self):
                super().__init__()
                self.requestId = "subTest"
                self._names["requestId"] = "RequestId"
                self.id = 2

    class TestConvertMapModel(TeaModel):
        def __init__(self):
                super().__init__()
                self.requestId = ""
                self._names["requestId"] = "RequestId"
                self.extendId = 0
                self.dic = {}
                self.sub_model = None
        
        
        def to_object(self, dic):
            self.requestId = dic.get("RequestId") or ""
            self.extendId = dic.get("extendId") or 0
            self.dic = dic.get("dic")
            self.sub_model = TestClient.TestConvertSubModel()
            self.sub_model.requestId = dic.get("sub_model").get("RequestId")
            self.sub_model.id = dic.get("sub_model").get("id")

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
        dic = {}
        dic["test"] = 1
        dic["key"] = "value"
        self.assertIsNotNone(Client.query(dic))
        self.assertEqual("1", Client.query(dic).get("test"))

    def test_get_open_plat_form_endpoint(self):
        self.assertEqual("openplatform.aliyuncs.com", Client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", ""))

        self.assertEqual("openplatform.aliyuncs.com", Client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", "cn-hangzhou"))

        self.assertEqual("openplatform.ap-northeast-1.aliyuncs.com", Client.get_open_plat_form_endpoint("openplatform.aliyuncs.com", "ap-northeast-1"))
