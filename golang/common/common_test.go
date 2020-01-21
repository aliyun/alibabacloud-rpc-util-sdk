package common

import (
	"encoding/json"
	"io"
	"io/ioutil"
	"net/http"
	"reflect"
	"strings"
	"testing"

	"github.com/alibabacloud-go/tea/tea"
	"github.com/aliyun/alibabacloud-rpc-util-sdk/golang/utils"
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

func Test_ReadAsString(t *testing.T) {
	str, err := ReadAsString(strings.NewReader("common"))
	utils.AssertNil(t, err)
	utils.AssertEqual(t, "common", str)
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

func Test_DefaultNumber(t *testing.T) {
	num := DefaultNumber(0, 1)
	utils.AssertEqual(t, 1, num)

	num = DefaultNumber(2, 1)
	utils.AssertEqual(t, 2, num)
}

func Test_Default(t *testing.T) {
	str := Default("", "1")
	utils.AssertEqual(t, "1", str)

	str = Default("2", "1")
	utils.AssertEqual(t, "2", str)
}

func Test_GetTimestamp(t *testing.T) {
	stamp := GetTimestamp()
	utils.AssertNotNil(t, stamp)
}

func Test_GetUserAgent(t *testing.T) {
	ua := GetUserAgent("")
	utils.AssertContains(t, ua, "Core/0.01")

	ua = GetUserAgent("ua")
	utils.AssertContains(t, ua, "Core/0.01 ua")
}

func Test_GetSignature(t *testing.T) {
	req := tea.NewRequest()
	req.Query["test"] = "ok"

	sign := GetSignature(req, "accessKeySecret")
	utils.AssertEqual(t, "jHx/oHoHNrbVfhncHEvPdHXZwHU=", sign)
}

func Test_Json(t *testing.T) {
	httpresp := &http.Response{
		Body: ioutil.NopCloser(strings.NewReader(`{"cleint":"test"}`)),
	}
	resp := tea.NewResponse(httpresp)
	result, err := Json(resp)
	utils.AssertNil(t, err)
	utils.AssertEqual(t, "test", result["cleint"])
}

func Test_HasError(t *testing.T) {
	iserror := HasError(nil)
	utils.AssertEqual(t, true, iserror)

	body := map[string]interface{}{
		"Code": "200",
	}
	iserror = HasError(body)
	utils.AssertEqual(t, true, iserror)

	body = make(map[string]interface{})
	iserror = HasError(body)
	utils.AssertEqual(t, false, iserror)
}

func Test_Query(t *testing.T) {
	filter := map[string]interface{}{
		"client": "test",
	}

	result := Query(filter)
	utils.AssertEqual(t, "test", result["client"])
}

func Test_GetNonce(t *testing.T) {
	nonce := GetNonce()
	utils.AssertEqual(t, 32, len(nonce))
}

func Test_IsFail(t *testing.T) {
	httpresp := &http.Response{
		StatusCode: 300,
	}
	resp := tea.NewResponse(httpresp)
	isfail := IsFail(resp)
	utils.AssertEqual(t, true, isfail)
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

func Test_ParseXml(t *testing.T) {
	str := `<?xml version="1.0" encoding="utf-8" standalone="no"?>
	<num>10</num>`
	result := ParseXml(str, new(validatorTest))
	utils.AssertEqual(t, 1, len(result))

	str = `<?xml version="1.0" encoding="utf-8" standalone="no"?>
	<num/num>`
	result = ParseXml(str, new(validatorTest))
	utils.AssertEqual(t, 1, len(result))
}

func Test_Empty(t *testing.T) {
	ok := Empty("")
	utils.AssertEqual(t, true, ok)

	ok = Empty("oss")
	utils.AssertEqual(t, false, ok)
}

func Test_Equal(t *testing.T) {
	ok := Equal("v1", "v1")
	utils.AssertEqual(t, true, ok)

	ok = Equal("v1", "v2")
	utils.AssertEqual(t, false, ok)
}

func Test_GetErrmessage(t *testing.T) {
	result := GetErrMessage("")
	utils.AssertEqual(t, len(result), 0)

	str := `<?xml version="1.0" encoding="utf-8" standalone="no"?>
	<num>10</num>`
	result = GetErrMessage(str)
	utils.AssertEqual(t, result["Code"].(string), "")

}

func Test_GetDate(t *testing.T) {
	time := GetDate()
	utils.AssertEqual(t, 29, len(time))
}

func Test_GetHost(t *testing.T) {
	endpoint := GetHost("", "", "client.aliyuncs.com")
	utils.AssertEqual(t, "client.aliyuncs.com", endpoint)
}

type GetBucketLocationResponse struct {
	RequestId          *string `json:"x-oss-request-id" xml:"x-oss-request-id" require:"true"`
	LocationConstraint *string `json:"LocationConstraint" xml:"LocationConstraint" require:"true"`
}

func Test_XmlUnmarshal(t *testing.T) {
	result := new(GetBucketLocationResponse)
	xmlVal := `<?xml version="1.0" encoding="UTF-8"?>
<LocationConstraint>oss-cn-hangzhou</LocationConstraint >`
	out, err := XmlUnmarshal([]byte(xmlVal), result)
	utils.AssertNil(t, err)

	byt, _ := json.Marshal(out)
	utils.AssertEqual(t, `"oss-cn-hangzhou"`, string(byt))
}

func Test_ToForm(t *testing.T) {
	body := map[string]interface{}{
		"UserMeta": map[string]string{
			"common": "ok",
		},
		"ak": "accesskey",
		"file": map[string]string{
			"filename": "common",
		},
	}
	res := ToForm(body, GetBoundary())
	utils.AssertContains(t, res, `name="x-oss-meta-common"`)
}
