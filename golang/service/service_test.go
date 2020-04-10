package service

import (
	"io"
	"reflect"
	"strings"
	"testing"

	"github.com/alibabacloud-go/tea/utils"
)

type validatorTest struct {
	Num  *int       `json:"num" require:"true"`
	Str  *string    `json:"str" pattern:"^[a-d]*$" maxLength:"4"`
	Test *errLength `json:"test"`
	List []*string  `json:"list" pattern:"^[a-d]*$" maxLength:"4"`
}

type errLength struct {
	Num *int `json:"num" maxLength:"a"`
}

func Test_GetEndpoint(t *testing.T) {
	endpoint := GetEndpoint("common.aliyuncs.com", true, "internal")
	utils.AssertEqual(t, "common-internal.aliyuncs.com", endpoint)

	endpoint = GetEndpoint("common.aliyuncs.com", true, "accelerate")
	utils.AssertEqual(t, "oss-accelerate.aliyuncs.com", endpoint)

	endpoint = GetEndpoint("common.aliyuncs.com", true, "")
	utils.AssertEqual(t, "common.aliyuncs.com", endpoint)
}

type TestCommon struct {
	Body io.Reader `json:"Body"`
	Test string    `json:"Test"`
}

func Test_Convert(t *testing.T) {
	in := &TestCommon{
		Body: strings.NewReader("common"),
		Test: "ok",
	}
	out := new(TestCommon)
	Convert(in, &out)
	utils.AssertEqual(t, "ok", out.Test)
}

func Test_GetTimestamp(t *testing.T) {
	stamp := GetTimestamp()
	utils.AssertNotNil(t, stamp)
}

func Test_GetSignature(t *testing.T) {
	signed := map[string]string{
		"test": "ok",
	}

	sign := GetSignature(signed, "", "accessKeySecret")
	utils.AssertEqual(t, "jHx/oHoHNrbVfhncHEvPdHXZwHU=", sign)
}

func Test_HasError(t *testing.T) {
	iserror := HasError(nil)
	utils.AssertEqual(t, true, iserror)

	body := map[string]interface{}{
		"Code": "200",
	}
	iserror = HasError(body)
	utils.AssertEqual(t, true, iserror)

	body = map[string]interface{}{
		"Code": 0,
	}
	iserror = HasError(body)
	utils.AssertEqual(t, false, iserror)

	body = map[string]interface{}{
		"Code": 0.00,
	}
	iserror = HasError(body)
	utils.AssertEqual(t, false, iserror)

	body = make(map[string]interface{})
	iserror = HasError(body)
	utils.AssertEqual(t, false, iserror)
}

func Test_Query(t *testing.T) {
	filter := map[string]interface{}{
		"client": "test",
		"tag": map[string]string{
			"key": "value",
		},
		"strs": []string{"str1", "str2"},
	}

	result := Query(filter)
	utils.AssertEqual(t, "test", result["client"])
	utils.AssertEqual(t, "value", result["tag.key"])
	utils.AssertEqual(t, "str1", result["strs.1"])
	utils.AssertEqual(t, "str2", result["strs.2"])
}

func Test_flatRepeatedList(t *testing.T) {
	filter := map[string]interface{}{
		"client":  "test",
		"version": "1",
		"null":    nil,
		"slice": []interface{}{
			map[string]interface{}{
				"map": "valid",
			},
			6,
		},
		"map": map[string]interface{}{
			"value": "ok",
		},
	}

	result := make(map[string]string)
	for key, value := range filter {
		filterValue := reflect.ValueOf(value)
		flatRepeatedList(filterValue, result, key)
	}
	utils.AssertEqual(t, result["slice.1.map"], "valid")
	utils.AssertEqual(t, result["slice.2"], "6")
	utils.AssertEqual(t, result["map.value"], "ok")
	utils.AssertEqual(t, result["client"], "test")
	utils.AssertEqual(t, result["slice.1.map"], "valid")
}

func Test_GetHost(t *testing.T) {
	endpoint := GetHost("", "", "client.aliyuncs.com")
	utils.AssertEqual(t, "client.aliyuncs.com", endpoint)
}

func Test_GetOpenPlatFormEndpoint(t *testing.T) {
	endpoint := GetOpenPlatFormEndpoint("openplatform.aliyuncs.com", "")
	utils.AssertEqual(t, `openplatform.aliyuncs.com`, endpoint)

	endpoint = GetOpenPlatFormEndpoint("openplatform.aliyuncs.com", "cn-hangzhou")
	utils.AssertEqual(t, `openplatform.aliyuncs.com`, endpoint)

	endpoint = GetOpenPlatFormEndpoint("openplatform.aliyuncs.com", "ap-northeast-1")
	utils.AssertEqual(t, `openplatform.ap-northeast-1.aliyuncs.com`, endpoint)
}
