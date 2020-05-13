using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;

using AlibabaCloud.Commons;

using Moq;

using Newtonsoft.Json;

using tests.Models;

using Tea;

using Xunit;

namespace tests
{
    public class CommonTest
    {

        [Fact]
        public void Test_GetEndpoint()
        {
            Assert.Equal("test", Common.GetEndpoint("test", false, ""));

            Assert.Equal("test-internal.endpoint", Common.GetEndpoint("test.endpoint", false, "internal"));

            Assert.Equal("oss-accelerate.aliyuncs.com", Common.GetEndpoint("test", true, "accelerate"));
        }

        [Fact]
        public void Test_Convert()
        {
            TestConvertModel model = new TestConvertModel
            {
                RequestId = "test",
                Dict = new Dictionary<string, object>
                { { "key", "value" },
                { "testKey", "testValue" }
                },
                NoMap = 1,
                SubModel = new TestConvertModel.TestConvertSubModel
                {
                Id = 2,
                RequestId = "subTest"
                }
            };

            TestConvertMapModel mapModel = new TestConvertMapModel();
            Common.Convert(model, mapModel);
            Assert.Equal("test", mapModel.RequestId);
            Assert.Equal(0, mapModel.ExtendId);
            Assert.Equal(2, mapModel.SubModel.Id);
        }

        [Fact]
        public void Test_GetTimestamp()
        {
            Assert.NotNull(Common.GetTimestamp());

            Assert.Contains("T", Common.GetTimestamp());

            Assert.Contains("Z", Common.GetTimestamp());
        }

        [Fact]
        public void Test_GetSignature()
        {
            TeaRequest request = new TeaRequest();
            request.Method = "GET";
            Dictionary<string, string> query = new Dictionary<string, string>
            { { "query", "test" },
                { "body", "test" },
            };
            request.Query = query;
            string result = Common.GetSignature(request, "secret");
            Assert.Equal("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result);
        }

        [Fact]
        public void Test_GetSignatureV1()
        {
            Dictionary<string, string> query = new Dictionary<string, string>
            { { "query", "test" },
                { "body", "test" },
            };
            string result = Common.GetSignatureV1(query, "GET", "secret");
            Assert.Equal("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result);
        }

        [Fact]
        public void Test_HasError()
        {
            Assert.True(Common.HasError(null));

            Dictionary<string, object> dict = new Dictionary<string, object>();
            Assert.False(Common.HasError(dict));

            dict.Add("Code", "a");
            Assert.True(Common.HasError(dict));

            dict["Code"] = 1;
            Assert.True(Common.HasError(dict));

            dict["Code"] = 0;
            Assert.False(Common.HasError(dict));
        }

        [Fact]
        public void Test_Query()
        {
            Dictionary<string, object> dicObj = new Dictionary<string, object>();
            dicObj.Add("test", "test");
            dicObj.Add("key", "value");
            dicObj.Add("null", null);
            Dictionary<string, object> subDict = new Dictionary<string, object>();
            subDict.Add("subKey", "subValue");
            subDict.Add("subTest", "subTest");
            subDict.Add("subListInt", new List<int> { 1, 2, 3 });
            subDict.Add("subNull", null);
            subDict.Add("subListDict", new List<Dictionary<string, object>>
            {
                new Dictionary<string, object> { { "a", "b" }, { "c", "d" } },
                new Dictionary<string, object> { { "e", "f" }, { "g", "h" } },
            });
            dicObj.Add("sub", subDict);
            List<object> listObj = new List<object>
            {
                new Dictionary<string, object> { { "a", "b" }, { "c", "d" } },
                5,
                new List<string> { "list1", "list2" }
            };

            dicObj.Add("slice", listObj);
            Dictionary<string, string> dicQuery = Common.Query(dicObj);
            Assert.NotNull(Common.Query(dicObj));
            Assert.Equal("5", dicQuery["slice.2"]);
            Assert.Equal("value", dicQuery["key"]);
            Assert.Equal("1", dicQuery["sub.subListInt.1"]);
            Assert.Equal("d", dicQuery["sub.subListDict.1.c"]);
            Assert.Equal("list1", dicQuery["slice.3.1"]);
        }

        [Fact]
        public void Test_GetHost()
        {
            Assert.Equal("testEndpoint", Common.GetHost("", "", "testEndpoint"));

            Assert.Equal("cc.CN.aliyuncs.com", Common.GetHost("CC_CN", "CN", null));
        }

        [Fact]
        public void Test_GetOpenPlatFormEndpoint()
        {
            Assert.Equal("openplatform.aliyuncs.com", Common.GetOpenPlatFormEndpoint("openplatform.aliyuncs.com", ""));

            Assert.Equal("openplatform.aliyuncs.com", Common.GetOpenPlatFormEndpoint("openplatform.aliyuncs.com", "cn-hangzhou"));

            Assert.Equal("openplatform.ap-northeast-1.aliyuncs.com", Common.GetOpenPlatFormEndpoint("openplatform.aliyuncs.com", "ap-northeast-1"));
        }
    }
}
