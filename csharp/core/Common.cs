using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

using AlibabaCloud.Commons.Models;
using AlibabaCloud.Commons.Utils;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

using Tea;

namespace AlibabaCloud.Commons
{
    public static class Common
    {

        internal static string _defaultUserAgent;
        internal static string SEPARATOR = "&";

        static Common()
        {
            _defaultUserAgent = GetDefaultUserAgent();
        }

        public static string ReadAsString(Stream stream)
        {
            if (stream == null)
            {
                return string.Empty;
            }
            int bufferLength = 1024;
            using(var ms = new MemoryStream())
            {
                var buffer = new byte[bufferLength];

                while (true)
                {
                    var length = stream.Read(buffer, 0, bufferLength);
                    if (length == 0)
                    {
                        break;
                    }

                    ms.Write(buffer, 0, length);
                }

                ms.Seek(0, SeekOrigin.Begin);
                var bytes = new byte[ms.Length];
                ms.Read(bytes, 0, bytes.Length);

                stream.Close();
                stream.Dispose();

                return Encoding.UTF8.GetString(bytes);
            }
        }

        public static int GetContentLength(string str)
        {
            if (string.IsNullOrWhiteSpace(str))
            {
                return 0;
            }
            return str.Length;
        }

        public static string GetEndpoint(string endpoint, bool? useAccelerate, string endpointType)
        {
            if (endpointType == "internal")
            {
                string[] strs = endpoint.Split('.');
                strs[0] += "-internal";
                endpoint = string.Join(".", strs);
            }
            if (useAccelerate == true && endpointType == "accelerate")
            {
                return "oss-accelerate.aliyuncs.com";
            }

            return endpoint;
        }

        public static void Convert(TeaModel input, TeaModel output)
        {
            Dictionary<string, object> dict = new Dictionary<string, object>();
            Type type = input.GetType();
            PropertyInfo[] properties = type.GetProperties();
            for (int i = 0; i < properties.Length; i++)
            {
                PropertyInfo p = properties[i];
                var propertyType = p.PropertyType;
                if (!typeof(Stream).IsAssignableFrom(propertyType))
                {
                    dict[p.Name] = p.GetValue(input);
                }
            }

            string jsonStr = JsonConvert.SerializeObject(dict);
            TeaModel tempModel = (TeaModel) JsonConvert.DeserializeObject(jsonStr, output.GetType());

            Type outType = output.GetType();
            PropertyInfo[] outPropertyies = outType.GetProperties();
            foreach (PropertyInfo p in outPropertyies)
            {
                var outPropertyType = p.PropertyType;
                p.SetValue(output, p.GetValue(tempModel));
            }
        }

        public static string Default(string reaStr, string defaultStr)
        {
            if (string.IsNullOrWhiteSpace(reaStr))
            {
                return defaultStr;
            }
            return reaStr;
        }

        public static int? DefaultNumber(int? reaNum, int? defaultNum)
        {
            if (reaNum == null || reaNum == 0)
            {
                return defaultNum;
            }
            return reaNum;
        }

        public static string GetTimestamp()
        {
            return DateTime.UtcNow.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'");
        }

        public static string GetUserAgent(string userAgent)
        {
            return _defaultUserAgent + " " + userAgent;
        }

        public static string GetSignature(TeaRequest request, string secret)
        {
            return GetRpcSignedStr(request, secret);
        }

        public static Dictionary<string, object> Json(TeaResponse response)
        {
            string bodyStr = TeaCore.GetResponseBody(response);
            Dictionary<string, object> dic = new Dictionary<string, object>();
            Dictionary<string, object> dicBody = JsonConvert.DeserializeObject<Dictionary<string, object>>(bodyStr);
            dic = ObjToDictionary(dicBody);
            return dic;
        }

        public static bool HasError(Dictionary<string, object> body)
        {
            if (null == body)
            {
                return true;
            }
            object resultCode = DictUtils.GetDicValue(body, "Code");
            if (resultCode == null)
            {
                return false;
            }
            double code;
            if (double.TryParse(resultCode.ToSafeString(), out code))
            {
                return code > 0;
            }
            else
            {
                return true;
            }
        }

        public static Dictionary<string, string> Query(Dictionary<string, object> dict)
        {
            Dictionary<string, string> outDict = new Dictionary<string, string>();
            foreach (var keypair in dict)
            {
                outDict.Add(keypair.Key, keypair.Value.ToSafeString(""));
            }
            return outDict;
        }

        public static string GetNonce()
        {
            return Guid.NewGuid().ToString();
        }

        public static Dictionary<string, object> ParseXml(string content, Type type)
        {
            return XmlUtil.DeserializeXml(content, type);
        }

        public static bool Empty(string val)
        {
            return string.IsNullOrEmpty(val);
        }

        public static bool Equal(string val1, string val2)
        {
            return val1 == val2;
        }

        public static Dictionary<string, object> GetErrMessage(string bodyStr)
        {
            return (Dictionary<string, object>) DictUtils.GetDicValue(XmlUtil.DeserializeXml(bodyStr, typeof(ServiceError)), "Error");
        }

        public static bool IsFail(TeaResponse response)
        {
            return response.StatusCode < 200 || response.StatusCode >= 300;
        }

        public static Stream ToForm(Dictionary<string, object> dict, Stream sourceFile, string boundary)
        {
            if (dict == null)
            {
                return sourceFile;
            }
            MemoryStream formStream = new MemoryStream();

            StringBuilder stringBuilder = new StringBuilder();
            object file = DictUtils.GetDicValue(dict, "file");
            if (dict.ContainsKey("file"))
            {
                dict.Remove("file");
            }
            if (DictUtils.GetDicValue(dict, "UserMeta") != null)
            {
                Dictionary<string, string> userMeta = (Dictionary<string, string>) DictUtils.GetDicValue(dict, "UserMeta");
                foreach (var keypair in userMeta)
                {
                    stringBuilder.Append("--").Append(boundary).Append("\r\n");
                    stringBuilder.Append("Content-Disposition: form-data; name=\"x-oss-meta-").Append(keypair.Key).Append("\"\r\n\r\n");
                    stringBuilder.Append(keypair.Value).Append("\r\n");
                }
                dict.Remove("UserMeta");
            }
            foreach (var keypair in dict)
            {
                if (keypair.Value != null)
                {
                    stringBuilder.Append("--").Append(boundary).Append("\r\n");
                    stringBuilder.Append("Content-Disposition: form-data; name=\"").Append(keypair.Key).Append("\"\r\n\r\n");
                    stringBuilder.Append(keypair.Value).Append("\r\n");
                }
            }
            if (file != null)
            {
                Dictionary<string, object> headerFile = (Dictionary<string, object>) file;
                stringBuilder.Append("--").Append(boundary).Append("\r\n");
                stringBuilder.Append("Content-Disposition: form-data; name=\"file\"; filename=\"").Append(DictUtils.GetDicValue(headerFile, "filename")).Append("\"\r\n");
                stringBuilder.Append("Content-Type: ").Append(DictUtils.GetDicValue(headerFile, "content-type")).Append("\r\n\r\n");

                //write startStr in Stream
                byte[] sbByte = Encoding.UTF8.GetBytes(stringBuilder.ToString());
                formStream.Write(sbByte, 0, sbByte.Length);

                //write file in Stream
                byte[] buffer = new byte[4096];
                int bytesRFile;
                while ((bytesRFile = sourceFile.Read(buffer, 0, buffer.Length)) != 0)
                {
                    formStream.Write(buffer, 0, bytesRFile);
                }
                sourceFile.Flush();
                sourceFile.Close();

                byte[] bytesFileEnd = Encoding.UTF8.GetBytes("\r\n");
                formStream.Write(bytesFileEnd, 0, bytesFileEnd.Length);
            }
            else
            {
                //write stringBuilder in Stream
                byte[] sbByte = Encoding.UTF8.GetBytes(stringBuilder.ToString());
                formStream.Write(sbByte, 0, sbByte.Length);
            }

            //write endStr in Stream
            string endStr = string.Format("--{0}--\r\n", boundary);
            byte[] endBytes = Encoding.UTF8.GetBytes(endStr);
            formStream.Write(endBytes, 0, endBytes.Length);

            return formStream;
        }

        public static string GetDate()
        {
            return DateTime.UtcNow.ToUniversalTime().GetDateTimeFormats('r') [0];
        }

        public static string GetHost(string product, string regionid, string endpoint)
        {
            if (endpoint == null)
            {
                string serviceCode = product.Split('_') [0].ToLower();
                return string.Format("{0}.{1}.aliyuncs.com", serviceCode, regionid);
            }
            return endpoint;
        }

        public static string GetBoundary()
        {
            long num = (long) Math.Floor((new Random()).NextDouble() * 100000000000000D);;
            return num.ToSafeString();
        }

        internal static string GetDefaultUserAgent()
        {
            string defaultUserAgent = string.Empty;
            string OSVersion = Environment.OSVersion.ToString();
            string ClientVersion = GetRuntimeRegexValue(RuntimeEnvironment.GetRuntimeDirectory());
            string CoreVersion = Assembly.GetExecutingAssembly().GetName().Version.ToString();
            defaultUserAgent = "Alibaba Cloud (" + OSVersion + ") ";
            defaultUserAgent += ClientVersion;
            defaultUserAgent += " Core/" + CoreVersion;
            defaultUserAgent += " TeaDSL/1";
            return defaultUserAgent;
        }

        internal static string GetRuntimeRegexValue(string value)
        {
            var rx = new Regex(@"(\.NET).*(\\|\/).*(\d)", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            var matches = rx.Match(value);
            char[] separator = { '\\', '/' };

            if (matches.Success)
            {
                var clientValueArray = matches.Value.Split(separator);
                return BuildClientVersion(clientValueArray);
            }

            return "RuntimeNotFound";
        }

        internal static string BuildClientVersion(string[] value)
        {
            var finalValue = "";
            for (var i = 0; i < value.Length - 1; ++i)
            {
                finalValue += value[i].Replace(".", "").ToLower();
            }

            finalValue += "/" + value[value.Length - 1];

            return finalValue;
        }

        internal static string GetRpcSignedStr(TeaRequest request, string secret)
        {
            Dictionary<string, string> queries = new Dictionary<string, string>(request.Query);
            List<string> sortedKeys = queries.Keys.ToList();
            sortedKeys.Sort();
            StringBuilder canonicalizedQueryString = new StringBuilder();

            foreach (string key in sortedKeys)
            {
                if(!string.IsNullOrEmpty(queries[key]))
                {
                    canonicalizedQueryString.Append("&")
                    .Append(PercentEncode(key)).Append("=")
                    .Append(PercentEncode(queries[key]));
                }
            }
            StringBuilder stringToSign = new StringBuilder();
            stringToSign.Append(request.Method);
            stringToSign.Append(SEPARATOR);
            stringToSign.Append(PercentEncode("/"));
            stringToSign.Append(SEPARATOR);
            stringToSign.Append(PercentEncode(
                canonicalizedQueryString.ToString().Substring(1)));
            System.Diagnostics.Debug.WriteLine("Alibabacloud.Common.GetSignature:stringToSign is " + stringToSign.ToString());
            byte[] signData;
            using(KeyedHashAlgorithm algorithm = CryptoConfig.CreateFromName("HMACSHA1") as KeyedHashAlgorithm)
            {
                algorithm.Key = Encoding.UTF8.GetBytes(secret + SEPARATOR);
                signData = algorithm.ComputeHash(Encoding.UTF8.GetBytes(stringToSign.ToString().ToCharArray()));
            }
            string signedStr = System.Convert.ToBase64String(signData);
            return signedStr;

        }

        internal static string BuildUrl(TeaRequest request)
        {
            string url = request.Pathname.ToSafeString(string.Empty);
            Dictionary<string, string> hs = (from dic in request.Query orderby dic.Key ascending select dic).ToDictionary(p => p.Key, p => p.Value);

            if (hs.Count > 0 && !url.Contains("?"))
            {
                url += "?";
            }

            foreach (var keypair in hs)
            {
                if (!url.EndsWith("?"))
                {
                    url += "&";
                }
                url += keypair.Key + "=" + keypair.Value;
            }
            return url;
        }

        internal static string PercentEncode(string value)
        {
            if (value == null)
            {
                return null;
            }
            var stringBuilder = new StringBuilder();
            var text = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~";
            var bytes = Encoding.UTF8.GetBytes(value);
            foreach (char c in bytes)
            {
                if (text.IndexOf(c) >= 0)
                {
                    stringBuilder.Append(c);
                }
                else
                {
                    stringBuilder.Append("%").Append(string.Format(CultureInfo.InvariantCulture, "{0:X2}", (int) c));
                }
            }

            return stringBuilder.ToString().Replace("+", "%20")
                .Replace("*", "%2A").Replace("%7E", "~");
        }

        internal static Dictionary<string, object> ObjToDictionary(Dictionary<string, object> dicObj)
        {
            Dictionary<string, object> dic = new Dictionary<string, object>();
            foreach (string key in dicObj.Keys)
            {
                if (dicObj[key] is JArray)
                {
                    List<Dictionary<string, object>> dicObjList = ((JArray) dicObj[key]).ToObject<List<Dictionary<string, object>>>();
                    List<Dictionary<string, object>> dicList = new List<Dictionary<string, object>>();
                    foreach (Dictionary<string, object> objItem in dicObjList)
                    {
                        dicList.Add(ObjToDictionary(objItem));
                    }
                    dic.Add(key, dicList);
                }
                else if (dicObj[key] is JObject)
                {
                    Dictionary<string, object> dicJObj = ((JObject) dicObj[key]).ToObject<Dictionary<string, object>>();
                    dic.Add(key, dicJObj);
                }
                else
                {
                    dic.Add(key, dicObj[key]);
                }
            }
            return dic;
        }

        public static string GetOpenPlatFormEndpoint(string endpoint, string regionId)
        {
            string[] supportRegionId = { "ap-southeast-1", "ap-northeast-1", "eu-central-1", "cn-hongkong", "ap-south-1" };
            bool isExist = supportRegionId.Contains(regionId.ToLower());

            if (isExist)
            {
                string[] strs = endpoint.Split('.');
                strs[0] = strs[0] + "." + regionId;
                return string.Join(".", strs);
            }

            return endpoint;
        }

    }
}
