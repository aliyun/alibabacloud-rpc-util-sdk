using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using AlibabaCloud.Commons;
using Moq;
using Tea;
using tests.Models;
using Xunit;

namespace tests
{
    public class CommonTest
    {
        [Fact]
        public void Test_ReadAsString()
        {
            Assert.Empty(Common.ReadAsString(null));

            MemoryStream stream = new MemoryStream(Encoding.UTF8.GetBytes("test"));
            Assert.Equal("test", Common.ReadAsString(stream));
        }

        [Fact]
        public void Test_GetContentLength()
        {
            Assert.Equal(0, Common.GetContentLength(null));

            Assert.Equal(4, Common.GetContentLength("test"));
        }

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
        public void Test_Default()
        {
            Assert.Equal("default", Common.Default("", "default"));

            Assert.Equal("input", Common.Default("input", "default"));
        }

        [Fact]
        public void Test_DefaultNumber()
        {
            Assert.Equal(100, Common.DefaultNumber(null, 100));

            Assert.Equal(100, Common.DefaultNumber(0, 100));

            Assert.Equal(1, Common.DefaultNumber(1, 100));
        }

        [Fact]
        public void Test_GetTimestamp()
        {
            Assert.NotNull(Common.GetTimestamp());

            Assert.Contains("T", Common.GetTimestamp());

            Assert.Contains("Z", Common.GetTimestamp());
        }

        [Fact]
        public void Test_GetUserAgent()
        {
            Assert.NotNull(Common.GetUserAgent("agent"));

            Assert.Contains("agent", Common.GetUserAgent("agent"));
        }

        [Fact]
        public void Test_GetRpcSignedStr()
        {

        }

        [Fact]
        public void Test_Json()
        {
            Mock<HttpWebResponse> mockHttpWebResponse = new Mock<HttpWebResponse>();
            mockHttpWebResponse.Setup(p => p.StatusCode).Returns(HttpStatusCode.OK);
            mockHttpWebResponse.Setup(p => p.StatusDescription).Returns("StatusDescription");
            mockHttpWebResponse.Setup(p => p.Headers).Returns(new WebHeaderCollection());
            mockHttpWebResponse.Setup(p => p.GetResponseStream()).Returns(new MemoryStream(Encoding.UTF8.GetBytes("{\"test\":\"value\"}")));
            TeaResponse teaResponse = new TeaResponse(mockHttpWebResponse.Object);
            Assert.Equal("value", Common.Json(teaResponse) ["test"]);
        }

        [Fact]
        public void Test_BuildUrl()
        {
            TeaRequest request = new TeaRequest();
            request.Pathname = "pathName";
            Assert.Equal("pathName", Common.BuildUrl(request));

            request.Pathname = "pathName?";
            request.Query.Add("key", "value");
            Assert.Equal("pathName?key=value", Common.BuildUrl(request));

            request.Pathname = "pathName";
            request.Query.Add("testKey", "testValue");
            Assert.Equal("pathName?key=value&testKey=testValue", Common.BuildUrl(request));

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
