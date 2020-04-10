package service

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/url"
	"reflect"
	"strconv"
	"strings"
	"time"
)

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

func GetTimestamp() string {
	gmt := time.FixedZone("GMT", 0)
	return time.Now().In(gmt).Format("2006-01-02T15:04:05Z")
}

func GetSignature(signedParam map[string]string, method string, secret string) string {
	stringToSign := buildRpcStringToSign(signedParam, method)
	signature := sign(stringToSign, secret, "&")
	return signature
}

func HasError(body map[string]interface{}) bool {
	if body == nil {
		return true
	}
	if obj := body["Code"]; obj != nil {
		code := fmt.Sprintf("%v", body["Code"])
		if code != "" && code != "0" {
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

func GetHost(product string, regionid string, endpoint string) string {
	return endpoint
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

func buildRpcStringToSign(signedParam map[string]string, method string) (stringToSign string) {
	signParams := make(map[string]string)
	for key, value := range signedParam {
		signParams[key] = value
	}

	stringToSign = getUrlFormedMap(signParams)
	stringToSign = strings.Replace(stringToSign, "+", "%20", -1)
	stringToSign = strings.Replace(stringToSign, "*", "%2A", -1)
	stringToSign = strings.Replace(stringToSign, "%7E", "~", -1)
	stringToSign = url.QueryEscape(stringToSign)
	stringToSign = method + "&%2F&" + stringToSign
	return
}

func getUrlFormedMap(source map[string]string) (urlEncoded string) {
	urlEncoder := url.Values{}
	for key, value := range source {
		urlEncoder.Add(key, value)
	}
	urlEncoded = urlEncoder.Encode()
	return
}

func GetOpenPlatFormEndpoint(endpoint, regionId string) string {
	supportRegionId := []string{"ap-southeast-1", "ap-northeast-1", "eu-central-1", "cn-hongkong", "ap-south-1"}
	ifExist := false
	for _, value := range supportRegionId {
		if value == strings.ToLower(regionId) {
			ifExist = true
		}
	}
	if regionId != "" && ifExist {
		strs := strings.Split(endpoint, ".")
		strs[0] = strs[0] + "." + regionId
		return strings.Join(strs, ".")
	} else {
		return endpoint
	}
}
