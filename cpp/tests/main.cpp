#include "gtest/gtest.h"
#include <alibabacloud/rpcutil.hpp>
#include <darabonba/core.hpp>
#include <map>
#include <utility>

using namespace std;
using namespace Alibabacloud_RPCUtil;

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

class TestModel : public Darabonba::Model {
public:
  void validate() override {
    cout << "test validate";
  }
};

TEST(tests, getEndpoint) {
  auto *endpoint = new string("ecs.cn-hangzhou.aliyuncs.com");
  bool *serverUse = new bool(false);
  auto *endpointType = new string("public");
  ASSERT_EQ(string("ecs.cn-hangzhou.aliyuncs.com"),
            *Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, serverUse, endpointType));
  *endpointType = "internal";
  ASSERT_EQ(string("ecs-internal.cn-hangzhou.aliyuncs.com"),
            *Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, serverUse, endpointType));
  *serverUse = true;
  *endpointType = "accelerate";
  ASSERT_EQ(string("oss-accelerate.aliyuncs.com"),
            *Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, serverUse, endpointType));
}

TEST(tests, getHost) {
  string *productId = nullptr;
  string *regionId = nullptr;
  auto *endpoint = new string("testEndpoint");
  ASSERT_EQ(*endpoint, *Client::getHost(productId, regionId, endpoint));

  productId = new string("CC_CN");
  regionId = new string("CN-Hangzhou");
  *endpoint = "";
  ASSERT_EQ(string("cc.cn-hangzhou.aliyuncs.com"), *Client::getHost(productId, regionId, endpoint));
}

TEST(tests, getSignature) {
  auto *TeaRequest = new Request();
  map<string, string> query = {
      {"query", "test"},
      {"body", "test"}
  };
  TeaRequest->query = query;
  auto *secret = new string("secret");
  ASSERT_EQ(string("XlUyV4sXjOuX5FnjUz9IF9tm5rU="), *Client::getSignature(TeaRequest, secret));
}

TEST(tests, getSignatureV1) {
  auto *query = new map<string, string>({
                                            {"query", "test"},
                                            {"body", "test"}
                                        });
  auto *method = new string("GET");
  auto *secret = new string("secret");
  ASSERT_EQ(string("XlUyV4sXjOuX5FnjUz9IF9tm5rU="), *Client::getSignatureV1(query, method, secret));
}

TEST(tests, hasError) {
  map<string, boost::any> *m = nullptr;
  ASSERT_TRUE(*Client::hasError(m));

  m = new map<string, boost::any>();
  ASSERT_FALSE(*Client::hasError(m));

  auto *m1 = new map<string, boost::any>({{"Code", "a"}});
  ASSERT_TRUE(*Client::hasError(m1));
}

TEST(tests, getTimestamp) {
  ASSERT_EQ(20, Client::getTimestamp()->size());
}

TEST(tests, convert) {
  auto *iModel = new TestModel();
  auto *oModel = new TestModel();
  string name = "name";
  string test = "test";
  iModel->set("name", name);
  iModel->set("test", test);
  Client::convert(iModel, oModel);
  ASSERT_EQ(name, boost::any_cast<string>(oModel->get("name")));
  ASSERT_EQ(test, boost::any_cast<string>(oModel->get("test")));
  delete iModel;
  delete oModel;
}

TEST(tests, query) {
  auto *m = new map<string, boost::any>({
                                            {"str_test", "test"},
                                            {"int_test", 1}
                                        });
  map<string, string> *result = Client::query(m);
  ASSERT_EQ("test", result->at("str_test"));
  ASSERT_EQ("1", result->at("int_test"));

  vector<boost::any> sl = {1, 2};
  map<string, boost::any> sub_map_fd = {
      {"int_test", 2},
      {"str_test", "test"}
  };
  auto *fd = new map<string, boost::any>({
                                             {"first_map_map", sub_map_fd},
                                             {"first_map_list", sl},
                                             {"int_test", 2},
                                             {"str_test", "test"}
                                         });

  map<string, string> *res = Client::query(fd);
  ASSERT_EQ("1", res->at("first_map_list.1"));
  ASSERT_EQ("2", res->at("first_map_list.2"));
  ASSERT_EQ("2", res->at("first_map_map.int_test"));
  ASSERT_EQ("test", res->at("first_map_map.str_test"));
  ASSERT_EQ("2", res->at("int_test"));
  ASSERT_EQ("test", res->at("str_test"));

  delete res;
  delete fd;
}

TEST(tests, getOpenPlatFormEndpoint) {
  auto *endpoint = new string("openplatform.aliyuncs.com");
  auto *region_id = new string("");
  ASSERT_EQ(
      string("openplatform.aliyuncs.com"),
      *Client::getOpenPlatFormEndpoint(endpoint, region_id)
  );
  *region_id = "cn-hangzhou";
  ASSERT_EQ(
      string("openplatform.aliyuncs.com"),
      *Client::getOpenPlatFormEndpoint(endpoint, region_id)
  );
  *region_id = "ap-northeast-1";
  ASSERT_EQ(
      string("openplatform.ap-northeast-1.aliyuncs.com"),
      *Client::getOpenPlatFormEndpoint(endpoint, region_id)
  );
}