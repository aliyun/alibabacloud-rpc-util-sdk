package service

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base64"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"reflect"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/alibabacloud-go/tea/tea"
	"github.com/aliyun/alibabacloud-rpc-util-sdk/golang/utils"
)

var defaultUserAgent = fmt.Sprintf("AlibabaCloud (%s; %s) Golang/%s Core/%s", runtime.GOOS, runtime.GOARCH, strings.Trim(runtime.Version(), "go"), "0.01")

type RuntimeObject struct {
	Autoretry      *bool   `json:"autoretry" xml:"autoretry"`
	IgnoreSSL      *bool   `json:"ignoreSSL" xml:"ignoreSSL"`
	MaxAttempts    *int    `json:"maxAttempts" xml:"maxAttempts"`
	BackoffPolicy  *string `json:"backoffPolicy" xml:"backoffPolicy"`
	BackoffPeriod  *int    `json:"backoffPeriod" xml:"backoffPeriod"`
	ReadTimeout    *int    `json:"readTimeout" xml:"readTimeout"`
	ConnectTimeout *int    `json:"connectTimeout" xml:"connectTimeout"`
	LocalAddr      *string `json:"localAddr" xml:"localAddr"`
	HttpProxy      *string `json:"httpProxy" xml:"httpProxy"`
	HttpsProxy     *string `json:"httpsProxy" xml:"httpsProxy"`
	NoProxy        *string `json:"noProxy" xml:"noProxy"`
	MaxIdleConns   *int    `json:"maxIdleConns" xml:"maxIdleConns"`
	Socks5Proxy    *string `json:"socks5Proxy" xml:"socks5Proxy"`
	Socks5NetWork  *string `json:"socks5NetWork" xml:"socks5NetWork"`
}

type ServiceError struct {
	Code      string `json:"Code" xml:"Code"`
	Message   string `json:"Message" xml:"Message"`
	RequestId string `json:"RequestId" xml:"RequestId"`
	HostId    string `json:"HostId" xml:"HostId"`
}

func ReadAsString(body io.Reader) (string, error) {
	byt, err := ioutil.ReadAll(body)
	if err != nil {
		return "", err
	}
	return string(byt), nil
}

func GetEndpoint(endpoint string, server bool, endpointType string) string {
	if endpointType == "internal" {
		strs := strings.Split(endpoint, ".")
		strs[0] += "-internal"
		endpoint = strings.Join(strs, ".")
	}
	if server && endpointType == "accelerate" {
		return "oss-accelerate.aliyuncs.com"
	}

	return endpoint
}

func Convert(input, output interface{}) {
	res := make(map[string]interface{})
	val := reflect.ValueOf(input).Elem()
	dataType := val.Type()
	for i := 0; i < dataType.NumField(); i++ {
		field := dataType.Field(i)
		name, _ := field.Tag.Lookup("json")
		_, ok := val.Field(i).Interface().(io.Reader)
		if !ok {
			res[name] = val.Field(i).Interface()
		}
	}
	byt, _ := json.Marshal(res)
	json.Unmarshal(byt, output)
}

func Default(reaStr, defaultStr string) string {
	if reaStr == "" {
		return defaultStr
	}
	return reaStr
}

func DefaultNumber(reaNum, defaultNum int) int {
	if reaNum == 0 {
		return defaultNum
	}
	return reaNum
}

func GetTimestamp() string {
	gmt := time.FixedZone("GMT", 0)
	return time.Now().In(gmt).Format("2006-01-02T15:04:05Z")
}

func GetUserAgent(useragent string) string {
	if useragent == "" {
		return defaultUserAgent
	}
	return defaultUserAgent + " " + useragent
}

func GetSignature(request *tea.Request, secret string) string {
	stringToSign := buildRpcStringToSign(request)
	signature := sign(stringToSign, secret, "&")
	return signature
}

func Json(response *tea.Response) (result map[string]interface{}, err error) {
	body, err := response.ReadBody()
	if err != nil {
		return
	}

	err = json.Unmarshal(body, &result)
	return
}

func HasError(body map[string]interface{}) bool {
	if body == nil {
		return true
	}
	if obj := body["Code"]; obj != nil {
		if statusCode := body["Code"].(string); statusCode != "" {
			return true
		}
	}
	return false
}

func Query(filter map[string]interface{}) map[string]string {
	tmp := make(map[string]interface{})
	byt, _ := json.Marshal(filter)
	_ = json.Unmarshal(byt, &tmp)

	result := make(map[string]string)
	for key, value := range tmp {
		filterValue := reflect.ValueOf(value)
		flatRepeatedList(filterValue, result, key)
	}

	return result
}

func GetNonce() string {
	return utils.GetUUID()
}

func IsFail(response *tea.Response) bool {
	return response.StatusCode < 200 || response.StatusCode >= 300
}

func ParseXml(val string, result interface{}) map[string]interface{} {
	resp := make(map[string]interface{})

	start := getStartElement([]byte(val))
	out, err := XmlUnmarshal([]byte(val), result)
	if err != nil {
		return resp
	}
	resp[start] = out
	return resp
}

func Empty(val string) bool {
	return val == ""
}

func Equal(val1, val2 string) bool {
	return val1 == val2
}

func GetErrMessage(bodyStr string) map[string]interface{} {
	resp := make(map[string]interface{})
	errMsg := &ServiceError{}
	err := xml.Unmarshal([]byte(bodyStr), errMsg)
	if err != nil {
		return resp
	}
	resp["Code"] = errMsg.Code
	resp["Message"] = errMsg.Message
	resp["RequestId"] = errMsg.RequestId
	resp["HostId"] = errMsg.HostId
	return resp
}

func ToForm(body map[string]interface{}, boundary string) string {
	if obj := body["UserMeta"]; obj != nil {
		meta := obj.(map[string]string)
		delete(body, "UserMeta")
		for key, value := range meta {
			body["x-oss-meta-"+key] = value
		}
	}
	line := "--" + boundary + "\r\n"
	reqBody := line
	for key, value := range body {
		if val, ok := value.(string); ok {
			if val != "" {
				reqBody = reqBody + "Content-Disposition: form-data; name=\"" + key + "\"" + "\r\n\r\n"
				reqBody = reqBody + val + "\r\n"
				reqBody = reqBody + line
			}
		}
	}
	if obj, ok := body["file"]; ok {
		file := make(map[string]string)
		byt, _ := json.Marshal(obj)
		json.Unmarshal(byt, &file)
		reqBody = reqBody + "Content-Disposition: form-data; name=\"file\"" + "; " + "filename=\"" + file["filename"] + "\"" + "\r\n"
		reqBody = reqBody + "Content-Type: " + file["content-type"] + "\r\n\r\n"
		reqBody = reqBody + file["content"] + "\r\n\r\n"
	}
	reqBody = reqBody + "--" + boundary + "--\r\n"
	return reqBody
}

func GetDate() string {
	return time.Now().UTC().Format(http.TimeFormat)
}

func GetHost(product string, regionid string, endpoint string) string {
	return endpoint
}

func GetBoundary() string {
	return utils.RandStringBytes(14)
}

func flatRepeatedList(dataValue reflect.Value, result map[string]string, prefix string) {
	if !dataValue.IsValid() {
		return
	}

	dataType := dataValue.Type()
	if dataType.Kind().String() == "slice" {
		handleRepeatedParams(dataValue, result, prefix)
	} else if dataType.Kind().String() == "map" {
		handleMap(dataValue, result, prefix)
	} else {
		result[prefix] = fmt.Sprintf("%v", dataValue.Interface())
	}
}

func handleRepeatedParams(repeatedFieldValue reflect.Value, result map[string]string, prefix string) {
	if repeatedFieldValue.IsValid() && !repeatedFieldValue.IsNil() {
		for m := 0; m < repeatedFieldValue.Len(); m++ {
			elementValue := repeatedFieldValue.Index(m)
			key := prefix + "." + strconv.Itoa(m+1)
			fieldValue := reflect.ValueOf(elementValue.Interface())
			if fieldValue.Kind().String() == "map" {
				handleMap(fieldValue, result, key)
			} else {
				result[key] = fmt.Sprintf("%v", fieldValue.Interface())
			}
		}
	}
}

func handleMap(valueField reflect.Value, result map[string]string, prefix string) {
	if valueField.IsValid() && valueField.String() != "" {
		valueFieldType := valueField.Type()
		if valueFieldType.Kind().String() == "map" {
			var byt []byte
			byt, _ = json.Marshal(valueField.Interface())
			cache := make(map[string]interface{})
			_ = json.Unmarshal(byt, &cache)
			for key, value := range cache {
				pre := ""
				if prefix != "" {
					pre = prefix + "." + key
				} else {
					pre = key
				}
				fieldValue := reflect.ValueOf(value)
				flatRepeatedList(fieldValue, result, pre)
			}
		}
	}
}

func sign(stringToSign, accessKeySecret, secretSuffix string) string {
	secret := accessKeySecret + secretSuffix
	signedBytes := shaHmac1(stringToSign, secret)
	signedString := base64.StdEncoding.EncodeToString(signedBytes)
	return signedString
}

func shaHmac1(source, secret string) []byte {
	key := []byte(secret)
	hmac := hmac.New(sha1.New, key)
	hmac.Write([]byte(source))
	return hmac.Sum(nil)
}

func buildRpcStringToSign(request *tea.Request) (stringToSign string) {
	signParams := make(map[string]string)
	for key, value := range request.Query {
		signParams[key] = value
	}

	stringToSign = utils.GetUrlFormedMap(signParams)
	stringToSign = strings.Replace(stringToSign, "+", "%20", -1)
	stringToSign = strings.Replace(stringToSign, "*", "%2A", -1)
	stringToSign = strings.Replace(stringToSign, "%7E", "~", -1)
	stringToSign = url.QueryEscape(stringToSign)
	stringToSign = request.Method + "&%2F&" + stringToSign
	return
}

func getStartElement(body []byte) string {
	d := xml.NewDecoder(bytes.NewReader(body))
	for {
		tok, err := d.Token()
		if err != nil {
			return ""
		}
		if t, ok := tok.(xml.StartElement); ok {
			return t.Name.Local
		}
	}
}

func XmlUnmarshal(body []byte, result interface{}) (interface{}, error) {
	start := getStartElement(body)
	dataValue := reflect.ValueOf(result).Elem()
	dataType := dataValue.Type()
	for i := 0; i < dataType.NumField(); i++ {
		field := dataType.Field(i)
		name, containsNameTag := field.Tag.Lookup("xml")
		if containsNameTag {
			if name == start {
				realType := dataValue.Field(i).Type()
				realValue := reflect.New(realType).Interface()
				err := xml.Unmarshal(body, realValue)
				if err != nil {
					return nil, err
				}
				return realValue, nil
			}
		}
	}
	return nil, nil
}
