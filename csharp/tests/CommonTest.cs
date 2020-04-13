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
        public void Test_GetSignature()
        {
            TeaRequest request = new TeaRequest(); 
            request.Method = "GET";
            Dictionary<string, string> query = new Dictionary<string, string>
            { 
                { "query", "test" },
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
            { 
                { "query", "test" },
                { "body", "test" },
            };
            string result = Common.GetSignatureV1(query, "GET", "secret");
            Assert.Equal("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result);
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
            Assert.NotNull(Common.Query(dicObj));
            Assert.Equal(2, Common.Query(dicObj).Count);
        }

        [Fact]
        public void Test_GetNonce()
        {
            string nonce = Common.GetNonce();
            Assert.NotNull(nonce);

            Assert.NotEqual(nonce, Common.GetNonce());
        }

        [Fact]
        public void Test_ToBody()
        {
            string xmlStr = @"<ListAllMyBucketsResult>
  <Owner>
    <ID>512</ID>
    <DisplayName>51264</DisplayName>
  </Owner>
  <Buckets>
    <Bucket>
      <CreationDate>2015-12-17T18:12:43.000Z</CreationDate>
      <ExtranetEndpoint>oss-cn-shanghai.aliyuncs.com</ExtranetEndpoint>
      <IntranetEndpoint>oss-cn-shanghai-internal.aliyuncs.com</IntranetEndpoint>
      <Location>oss-cn-shanghai</Location>
      <Name>app-base-oss</Name>
      <StorageClass>Standard</StorageClass>
    </Bucket>
    <Bucket>
      <CreationDate>2014-12-25T11:21:04.000Z</CreationDate>
      <ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>
      <IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>
      <Location>oss-cn-hangzhou</Location>
      <Name>atestleo23</Name>
      <StorageClass>IA</StorageClass>
    </Bucket>
    <Bucket />
  </Buckets>
  <listStr>1</listStr>
  <listStr>2</listStr>
  <Owners>
    <ID>512</ID>
    <DisplayName>51264</DisplayName>
  </Owners>
  <TestLong>3</TestLong>
  <TestShort>4</TestShort>
  <TestUInt>5</TestUInt>
  <TestUShort>7</TestUShort>
  <TestULong>6</TestULong>
  <TestFloat>2</TestFloat>
  <TestDouble>1</TestDouble>
  <TestBool>true</TestBool>
</ListAllMyBucketsResult>";

            Dictionary<string, object> xmlBody = Common.ParseXml(xmlStr, typeof(ToBodyModel));
            ToBodyModel teaModel = TeaModel.ToObject<ToBodyModel>(xmlBody);
            Assert.NotNull(teaModel);
            Assert.Equal(1, teaModel.listAllMyBucketsResult.TestDouble);
        }

        [Fact]
        public void Test_Empty()
        {
            Assert.True(Common.Empty(null));

            Assert.False(Common.Empty("test"));
        }

        [Fact]
        public void Test_Equal()
        {
            Assert.True(Common.Equal("a", "a"));

            Assert.False(Common.Equal("a", "b"));
        }

        [Fact]
        public void Test_IsFail()
        {
            Mock<HttpWebResponse> mock = new Mock<HttpWebResponse>();
            mock.Setup(p => p.StatusCode).Returns(HttpStatusCode.BadRequest);
            mock.Setup(p => p.StatusDescription).Returns("StatusDescription");
            mock.Setup(p => p.Headers).Returns(new WebHeaderCollection());
            TeaResponse response = new TeaResponse(mock.Object);
            Assert.True(Common.IsFail(response));

            mock.Setup(p => p.StatusCode).Returns(HttpStatusCode.Continue);
            response = new TeaResponse(mock.Object);
            Assert.True(Common.IsFail(response));

            mock.Setup(p => p.StatusCode).Returns(HttpStatusCode.Accepted);
            response = new TeaResponse(mock.Object);
            Assert.False(Common.IsFail(response));
        }

        [Fact]
        public void Test_GetDate()
        {
            Assert.NotNull(Common.GetDate());
            Assert.Contains("GMT", Common.GetDate());
        }

        [Fact]
        public void Test_GetHost()
        {
            Assert.Equal("testEndpoint", Common.GetHost("", "", "testEndpoint"));

            Assert.Equal("cc.CN.aliyuncs.com", Common.GetHost("CC_CN", "CN", null));
        }

        [Fact]
        public void Test_GetBoundary()
        {
            Assert.Equal(14, Common.GetBoundary().Length);
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

        [Fact]
        public void Test_ObjToDictionary()
        {
            string jsonStr = "{\"items\":[{\"total_size\":18,\"partNumber\":1,\"tags\":[{\"aa\":\"11\"}]},{\"total_size\":20,\"partNumber\":2,\"tags\":[{\"aa\":\"22\"}]}],\"next_marker\":\"\",\"test\":{\"total_size\":19,\"partNumber\":1,\"tags\":[{\"aa\":\"11\"}]}}";
            Dictionary<string, object> dic = new Dictionary<string, object>();
            Dictionary<string, object> dicBody = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonStr);
            dic = Common.ObjToDictionary(dicBody);
            Assert.Empty(dic["next_marker"].ToString());
            Assert.Equal(2, ((List<Dictionary<string, object>>) dic["items"]).Count);
            Assert.Equal(19L, ((Dictionary<string, object>) dic["test"]) ["total_size"]);
        }

        [Fact]
        public void Test_GetErrMessage()
        {
            string errMessage = "<?xml version='1.0' encoding='UTF-8'?><Error><Code>401</Code></Error>";
            Dictionary<string, object> result = Common.GetErrMessage(errMessage);
            Assert.Equal("401", result["Code"]);

            errMessage = "<?xml version='1.0' encoding='UTF-8'?><Code>401</Code>";
            result = Common.GetErrMessage(errMessage);
            Assert.Null(result);
        }

        
    }
}
