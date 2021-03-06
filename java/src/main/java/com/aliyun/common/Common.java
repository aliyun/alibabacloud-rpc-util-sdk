package com.aliyun.common;

import com.aliyun.common.models.ErrorResponse;
import com.aliyun.common.utils.XmlUtil;
import com.aliyun.tea.TeaModel;
import com.aliyun.tea.TeaRequest;
import com.aliyun.tea.TeaResponse;
import com.aliyun.tea.utils.StringUtils;
import com.google.gson.Gson;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;
import java.io.*;
import java.lang.reflect.Field;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.*;

public class Common {

    public static final String defaultUserAgent;
    public final static String SEPARATOR = "&";
    public final static String URL_ENCODING = "UTF-8";
    public static final String ALGORITHM_NAME = "HmacSHA1";
    public static final String coreVersion = "0.1.0";

    static {
        Properties sysProps = System.getProperties();
        defaultUserAgent = String.format("AlibabaCloud (%s; %s) Java/%s %s/%s TeaDSL/1", sysProps.getProperty("os.name"), sysProps
                .getProperty("os.arch"), sysProps.getProperty("java.runtime.version"), "Common", coreVersion);
    }

    public static Map<String, String> query(Map<String, ?> map) {
        Map<String, String> outMap = new HashMap<>();
        if (null != map) {
            processeObject(outMap, "", map);
        }
        return outMap;
    }

    private static void processeObject(Map<String, String> map, String key, Object value) {
        if (StringUtils.isEmpty(value)) {
            return;
        }
        if (value instanceof List) {
            List list = (List) value;
            for (int i = 0; i < list.size(); i++) {
                processeObject(map, key + "." + (i + 1), list.get(i));
            }
        } else if (value instanceof Map) {
            Map<String, Object> subMap = (Map<String, Object>) value;
            for (Map.Entry<String, Object> entry : subMap.entrySet()) {
                processeObject(map, key + "." + (entry.getKey()), entry.getValue());
            }
        } else {
            if (key.startsWith(".")) {
                key = key.substring(1);
            }
            map.put(key, String.valueOf(value));
        }
    }

    public static String readAsString(InputStream input) {
        try {
            if (input == null) {
                return "";
            }
            byte[] bcache = new byte[4096];
            int index;
            ByteArrayOutputStream infoStream = new ByteArrayOutputStream();
            while ((index = input.read(bcache)) > 0) {
                infoStream.write(bcache, 0, index);
            }
            return infoStream.toString("UTF-8");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    public static String getEndpoint(String endpoint, boolean useAccelerate, String endpointType) {
        if ("internal".equals(endpointType)) {
            String[] strs = endpoint.split("\\.");
            strs[0] += "-internal";
            endpoint = StringUtils.join(".", Arrays.asList(strs));
        }
        if (useAccelerate && "accelerate".equals(endpointType)) {
            return "oss-accelerate.aliyuncs.com";
        }
        return endpoint;
    }

    public static boolean equal(String hostModel, String ip) {
        if (hostModel == null || ip == null) {
            return false;
        }
        return hostModel.equals(ip);
    }

    public static boolean empty(String bucketName) {
        return StringUtils.isEmpty(bucketName);
    }

    public static Map<String, Object> parseXml(String bodyStr, Class<?> clazz) {
        try {
            return XmlUtil.DeserializeXml(bodyStr, clazz);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static Map<String, Object> getErrMessage(String bodyStr) {
        Map<String, Object> result = null;
        try {
            result = XmlUtil.DeserializeXml(bodyStr, ErrorResponse.class);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        result = result.get("Error") == null ? result : (Map<String, Object>) result.get("Error");
        return result;
    }

    public static boolean isFail(TeaResponse response_) {
        if (null == response_) {
            return false;
        }
        if (200 > response_.statusCode || 300 <= response_.statusCode) {
            return true;
        }
        return false;
    }

    public static InputStream toForm(Map<String, ?> map, InputStream sourceFile, String boundary) {
        InputStream is;
        OutputStream os = new ByteArrayOutputStream();
        if (null == map) {
            return sourceFile;
        }
        StringBuilder stringBuilder = new StringBuilder();
        Object file = map.remove("file");
        if (!StringUtils.isEmpty(map.get("UserMeta"))) {
            Map<String, String> userMeta = (Map<String, String>) map.remove("UserMeta");
            for (Map.Entry<String, String> meta : userMeta.entrySet()) {
                stringBuilder.append("--").append(boundary).append("\r\n");
                stringBuilder.append("Content-Disposition: form-data; name=\"x-oss-meta-").append(meta.getKey()).append("\"\r\n\r\n");
                stringBuilder.append(meta.getValue()).append("\r\n");
            }

        }
        for (Map.Entry<String, ?> entry : map.entrySet()) {
            if (!StringUtils.isEmpty(entry.getValue())) {
                stringBuilder.append("--").append(boundary).append("\r\n");
                stringBuilder.append("Content-Disposition: form-data; name=\"").append(entry.getKey()).append("\"\r\n\r\n");
                stringBuilder.append(entry.getValue()).append("\r\n");
            }
        }
        try {
            if (null != file) {
                Map<String, Object> headerFile = ((TeaModel) file).toMap();
                stringBuilder.append("--").append(boundary).append("\r\n");
                stringBuilder.append("Content-Disposition: form-data; name=\"file\"; filename=\"").append(headerFile.get("filename")).append("\"\r\n");
                stringBuilder.append("Content-Type: ").append(headerFile.get("content-type")).append("\r\n\r\n");
                os.write(stringBuilder.toString().getBytes("UTF-8"));
                int index;
                byte[] bufferOut = new byte[4096];
                while ((index = sourceFile.read(bufferOut)) != -1) {
                    os.write(bufferOut, 0, index);
                }
                sourceFile.close();
                os.write("\r\n".getBytes("UTF-8"));
            } else {
                os.write(stringBuilder.toString().getBytes("UTF-8"));
            }
            byte[] endData = ("--" + boundary + "--\r\n").getBytes();
            os.write(endData);
            os.flush();
            byte[] bytes = ((ByteArrayOutputStream) os).toByteArray();
            is = new ByteArrayInputStream(bytes);
            return is;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static String getDate() {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz", Locale.US);
        simpleDateFormat.setTimeZone(new SimpleTimeZone(0, "GMT"));
        return simpleDateFormat.format(new Date());
    }

    public static String getBoundary() {
        double num = Math.random() * 100000000000000D;
        return String.format("%014d", (long) num);
    }

    public static Number defaultNumber(Integer maxAttempts, long defaultNumber) {
        if (maxAttempts != null && maxAttempts >= 0) {
            return maxAttempts;
        }
        return defaultNumber;
    }

    public static String _default(String maxAttempts, String defaultStr) {
        if (!StringUtils.isEmpty(maxAttempts)) {
            return maxAttempts;
        }
        return defaultStr;
    }

    public static String getTimestamp() {
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        df.setTimeZone(new SimpleTimeZone(0, "UTC"));
        return df.format(new Date());
    }

    public static String getNonce() {
        StringBuffer uniqueNonce = new StringBuffer();
        UUID uuid = UUID.randomUUID();
        uniqueNonce.append(uuid.toString());
        uniqueNonce.append(System.currentTimeMillis());
        uniqueNonce.append(Thread.currentThread().getId());
        return uniqueNonce.toString();
    }

    public static String getUserAgent() {
        return getUserAgent(null);
    }

    public static String getUserAgent(String a) {
        if (StringUtils.isEmpty(a)) {
            return defaultUserAgent;
        }
        return defaultUserAgent + " " + a;
    }

    public static String getSignature(TeaRequest request, String secret) {
        return getSignature(request.query, request.method, secret);
    }

    public static String percentEncode(String value) {
        try {
            return value != null ? URLEncoder.encode(value, URL_ENCODING).replace("+", "%20")
                    .replace("*", "%2A").replace("%7E", "~") : null;
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }

    public static String getHost(String str, String regionId, String _endpoint) {
        if (null == _endpoint) {
            String serviceCode = str.split("\\_")[0].toLowerCase();
            return String.format("%s.%s.aliyuncs.com", serviceCode, regionId);
        } else {
            return _endpoint;
        }
    }

    public static Map<String, Object> json(TeaResponse response) {
        Gson gson = new Gson();
        Map<String, Object> map = null;
        try {
            map = gson.fromJson(response.getResponseBody(), Map.class);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return map;
    }

    public static boolean hasError(Map<String, ?> body) {
        if (null == body) {
            return true;
        }
        try {
            Object resultCode = body.get("Code");
            if (null == resultCode) {
                return false;
            }
            String code = String.valueOf(resultCode);
            return Double.parseDouble(code) > 0;
        } catch (Exception e) {
            return true;
        }
    }

    public static void convert(TeaModel source, TeaModel target) {
        if (source == null || target == null) {
            return;
        }
        try {

            Class sourceClass = source.getClass();
            Class targetClass = target.getClass();
            Field[] fields = sourceClass.getDeclaredFields();
            TeaModel teaModel = (TeaModel) sourceClass.newInstance();
            for (Field field : fields) {
                field.setAccessible(true);
                if (InputStream.class.isAssignableFrom(field.getType())) {
                    continue;
                }
                field.set(teaModel, field.get(source));
            }
            Gson gson = new Gson();
            String jsonString = gson.toJson(teaModel);
            Object outPut = gson.fromJson(jsonString, targetClass);
            fields = outPut.getClass().getFields();
            for (Field field : fields) {
                field.setAccessible(true);
                field.set(target, field.get(outPut));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static String getOpenPlatFormEndpoint(String endpoint, String regionId) {
        if (StringUtils.isEmpty(regionId)) {
            return endpoint;
        }
        final List<String> regionIds = Arrays.asList("ap-southeast-1", "ap-northeast-1", "eu-central-1", "cn-hongkong", "ap-south-1");
        boolean ifExist = false;
        for (String region : regionIds) {
            if (region.equals(regionId.toLowerCase())) {
                ifExist = true;
            }
        }
        if (ifExist) {
            String[] strs = endpoint.split("\\.");
            strs[0] = strs[0] + "." + regionId;
            return StringUtils.join(".", Arrays.asList(strs));
        } else {
            return endpoint;
        }
    }

    public static String getSignatureV1(java.util.Map<String, String> signedParams, String method, String secret) {
        return getSignature(signedParams, method, secret);
    }

    private static String getSignature(java.util.Map<String, String> signedParams, String method, String secret) {
        Map<String, String> queries = signedParams;
        String[] sortedKeys = queries.keySet().toArray(new String[]{});
        Arrays.sort(sortedKeys);
        StringBuilder canonicalizedQueryString = new StringBuilder();

        for (String key : sortedKeys) {
            if (StringUtils.isEmpty(queries.get(key))) {
                continue;
            }
            canonicalizedQueryString.append("&")
                    .append(percentEncode(key)).append("=")
                    .append(percentEncode(queries.get(key)));
        }
        StringBuilder stringToSign = new StringBuilder();
        stringToSign.append(method);
        stringToSign.append(SEPARATOR);
        stringToSign.append(percentEncode("/"));
        stringToSign.append(SEPARATOR);
        stringToSign.append(percentEncode(
                canonicalizedQueryString.toString().substring(1)));
        try {
            Mac mac = Mac.getInstance(ALGORITHM_NAME);
            mac.init(new SecretKeySpec((secret + SEPARATOR).getBytes(URL_ENCODING), ALGORITHM_NAME));
            byte[] signData = mac.doFinal(stringToSign.toString().getBytes(URL_ENCODING));
            return DatatypeConverter.printBase64Binary(signData);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
