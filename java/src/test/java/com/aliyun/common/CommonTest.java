package com.aliyun.common;

import com.aliyun.tea.TeaRequest;
import com.aliyun.tea.TeaResponse;
import org.junit.Assert;
import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.*;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;


public class CommonTest {
    @Test
    public void convertTest() throws Exception {
        SourceClass sourceClass = new SourceClass();
        TargetClass targetClass = new TargetClass();
        Common.convert(null, targetClass);
        Assert.assertNull(targetClass.test);
        Assert.assertNull(targetClass.empty);
        Assert.assertNull(targetClass.body);

        Common.convert(sourceClass, null);
        Assert.assertNull(targetClass.test);
        Assert.assertNull(targetClass.empty);
        Assert.assertNull(targetClass.body);

        Common.convert(sourceClass, targetClass);
        Assert.assertEquals("test", targetClass.test);
        Assert.assertNull(targetClass.empty);
        Assert.assertNull(targetClass.body);
    }

    @Test
    public void hasErrorTest() {
        Map<String, Object> map = new HashMap<>();
        Assert.assertTrue(Common.hasError(null));
        map.put("Code", "0");
        Assert.assertFalse(Common.hasError(map));

        map.put("Code", "400");
        Assert.assertTrue(Common.hasError(map));

        map.put("Code", "notFound");
        Assert.assertTrue(Common.hasError(map));

        map.put("Code", null);
        Assert.assertFalse(Common.hasError(map));
    }

    @Test
    public void jsonTest() throws Exception {
        TeaResponse teaResponse = mock(TeaResponse.class);
        when(teaResponse.getResponseBody()).thenReturn("{\"test\":\"test\"}");
        Map<String, Object> map = Common.json(teaResponse);
        Assert.assertEquals("test", map.get("test"));
    }

    @Test
    public void getHost() {
        Assert.assertEquals("testEndpoint", Common.getHost("", "", "testEndpoint"));
        Assert.assertEquals("cc.CN.aliyuncs.com", Common.getHost("CC_CN", "CN", null));
    }

    @Test
    public void percentEncodeTest() throws Exception {
        new Common();
        Assert.assertNull(Common.percentEncode(null));
    }

    @Test
    public void getSignatureTest() throws Exception {
        TeaRequest teaRequest = new TeaRequest();
        Map<String, String> map = new HashMap<>();
        map.put("query", "test");
        map.put("body", "test");
        teaRequest.query = map;
        String result = Common.getSignature(teaRequest, "secret");
        Assert.assertEquals("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", result);
    }

    @Test
    public void getUserAgentTest() {
        Assert.assertTrue(Common.getUserAgent().contains("Common"));
        Assert.assertTrue(Common.getUserAgent("test").contains("test"));
    }

    @Test
    public void getNonceTest() {
        Assert.assertFalse(Common.getNonce().equals(Common.getNonce()));
    }

    @Test
    public void getTimeStamp() throws Exception {
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        df.setTimeZone(new SimpleTimeZone(0, "UTC"));
        Date date = df.parse(Common.getTimestamp());
        Assert.assertNotNull(date);
    }

    @Test
    public void _defaultTest() {
        String result = Common._default("test", "default");
        Assert.assertEquals("test", result);

        result = Common._default(null, "default");
        Assert.assertEquals("default", result);

        Number number = Common.defaultNumber(3, 4L);
        Assert.assertEquals(3, number);

        number = Common.defaultNumber(null, 4L);
        Assert.assertEquals(4L, number);

        number = Common.defaultNumber(-1, 4L);
        Assert.assertEquals(4L, number);
    }

    @Test
    public void getBoundaryTest() {
        Assert.assertEquals(14, Common.getBoundary().length());
    }

    @Test
    public void getDateTest() throws Exception {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz", Locale.US);
        simpleDateFormat.setTimeZone(new SimpleTimeZone(0, "GMT"));
        Date date = simpleDateFormat.parse(Common.getDate());
        Assert.assertNotNull(date);
    }

    @Test
    public void toFormTest() throws Exception {
        InputStream result = Common.toForm(null, null,null);
        Assert.assertNull(result);
        Map<String, Object> map = new HashMap<>();
        map.put("nullTest", null);
        map.put("bodyTest", "test");
        result = Common.toForm(map, null,"123456");
        byte[] bytes = new byte[result.available()];
        result.read(bytes);
        Assert.assertEquals("--123456\r\nContent-Disposition: form-data; name=\"bodyTest\"\r\n\r\ntest\r\n" +
                "--123456--\r\n", new String(bytes, "UTF-8"));

        TargetClass targetClass = new TargetClass();
        map.put("file", targetClass);
        Map<String, String> userMeta = new HashMap<>();
        userMeta.put("meta", "test");
        map.put("UserMeta", userMeta);
        InputStream source = new ByteArrayInputStream("test".getBytes("UTF-8"));
        result = Common.toForm(map, source,"123456");
        bytes = new byte[result.available()];
        result.read(bytes);
        Assert.assertEquals("--123456\r\n" +
                "Content-Disposition: form-data; name=\"x-oss-meta-meta\"\r\n\r\n" +
                "test\r\n" +
                "--123456\r\n" +
                "Content-Disposition: form-data; name=\"bodyTest\"\r\n\r\n" +
                "test\r\n" +
                "--123456\r\n" +
                "Content-Disposition: form-data; name=\"file\"; filename=\"null\"\r\n" +
                "Content-Type: null\r\n\r\n" +
                "test\r\n" +
                "--123456--\r\n", new String(bytes, "utf-8"));
    }

    @Test
    public void isFailTest() {
        TeaResponse response = new TeaResponse();
        response.statusCode = 100;
        Assert.assertFalse(Common.isFail(null));
        Assert.assertTrue(Common.isFail(response));

        response.statusCode = 400;
        Assert.assertTrue(Common.isFail(response));

        response.statusCode = 200;
        Assert.assertFalse(Common.isFail(response));
    }

    @Test
    public void getErrMessageTest() throws Exception {
        String errMessage = "<?xml version='1.0' encoding='UTF-8'?><Error><Code>401</Code></Error>";
        Map result = Common.getErrMessage(errMessage);
        Assert.assertEquals("401", result.get("Code"));

        errMessage = "<?xml version='1.0' encoding='UTF-8'?><Code>401</Code>";
        result = Common.getErrMessage(errMessage);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void emptyTest() {
        String object = null;
        Assert.assertTrue(Common.empty(object));

        object = "12";
        Assert.assertFalse(Common.empty(object));
    }

    @Test
    public void equalTest() {
        Assert.assertFalse(Common.equal(null, "2"));
        Assert.assertFalse(Common.equal("1", null));
        Assert.assertFalse(Common.equal("1", "2"));
    }

    @Test
    public void getEndpointTest() {
        Assert.assertEquals("cc-internal.abc.com",
                Common.getEndpoint("cc.abc.com", false, "internal"));

        Assert.assertEquals("oss-accelerate.aliyuncs.com",
                Common.getEndpoint("", true, "accelerate"));

        Assert.assertEquals("test",
                Common.getEndpoint("test", true, "test"));
    }

    @Test
    public void readAsStringTest() throws IOException {
        TeaResponse teaResponse = mock(TeaResponse.class);
        when(teaResponse.getResponse()).thenReturn(new ByteArrayInputStream("test".getBytes()));
        Assert.assertEquals("", Common.readAsString(null));
        Assert.assertEquals("test", Common.readAsString(teaResponse.getResponse()));
    }

    @Test
    public void queryTest() throws Exception {
        Map<String, Object> query = new HashMap<>();
        query.put("test", "1");
        query.put("nulTest", null);
        Map<String, String> result = Common.query(null);
        Assert.assertEquals(0, result.size());

        result = Common.query(query);
        Assert.assertEquals("1", result.get("test"));
        Assert.assertFalse(result.containsKey("nullTest"));
    }

    @Test
    public void parseXmlTest() throws Exception{
        Assert.assertEquals(0, Common.parseXml(null, null).size());
    }
}
