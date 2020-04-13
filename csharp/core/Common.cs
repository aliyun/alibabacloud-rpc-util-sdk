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

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

using Tea;
using Tea.Utils;

namespace AlibabaCloud.Commons
{
    public static class Common
    {

        internal static string _defaultUserAgent;
        internal static string SEPARATOR = "&";

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

        public static string GetTimestamp()
        {
            return DateTime.UtcNow.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'");
        }

        public static string GetSignature(TeaRequest request, string secret)
        {
            return GetRpcSignedStr(request.Query, request.Method, secret);
        }

        public static bool HasError(Dictionary<string, object> body)
        {
            if (null == body)
            {
                return true;
            }
            object resultCode = body.Get("Code");
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

        public static string GetHost(string product, string regionid, string endpoint)
        {
            if (endpoint == null)
            {
                string serviceCode = product.Split('_') [0].ToLower();
                return string.Format("{0}.{1}.aliyuncs.com", serviceCode, regionid);
            }
            return endpoint;
        }

        public static string GetSignatureV1(Dictionary<string,string> signedParams, string method, string secret)
        {
            return GetRpcSignedStr(signedParams, method, secret);
        }

        internal static string GetRpcSignedStr(Dictionary<string, string> queries, string method, string secret)
        {
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
            stringToSign.Append(method);
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
