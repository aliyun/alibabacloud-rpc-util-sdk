#include "gtest/gtest.h"
#include "alibabacloud/rpcutil.hpp"
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
  string endpoint = "ecs.cn-hangzhou.aliyuncs.com";;
  ASSERT_EQ(string("ecs.cn-hangzhou.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, false, "public"));
  ASSERT_EQ(string("ecs-internal.cn-hangzhou.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, false, "internal"));
  ASSERT_EQ(string("oss-accelerate.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, true, "accelerate"));
}

TEST(tests, getHost) {
  ASSERT_EQ("testEndpoint", Client::getHost("", "", "testEndpoint"));
  ASSERT_EQ("cc.cn.aliyuncs.com", Client::getHost("CC_CN", "CN", ""));
}

TEST(tests, getSignature) {
  Darabonba::Request TeaRequest;
  map<string, string> query = {
      {"query", "test"},
      {"body", "test"}
  };
  TeaRequest.query = query;
  ASSERT_EQ("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", Client::getSignature(TeaRequest, "secret"));
}

TEST(tests, getSignatureV1) {
  map<string, string> query = {
      {"query", "test"},
      {"body", "test"}
  };
  ASSERT_EQ("XlUyV4sXjOuX5FnjUz9IF9tm5rU=", Client::getSignatureV1(query, "GET", "secret"));
}

TEST(tests, hasError) {
//  ASSERT_TRUE()
  map<string, boost::any> m = {};
  ASSERT_FALSE(Client::hasError(m));

  map<string, boost::any> m1 = {
      {"Code", "a"}
  };
  ASSERT_TRUE(Client::hasError(m1));
}

TEST(tests, getTimestamp) {
  ASSERT_EQ(20, Client::getTimestamp().size());
}

TEST(tests, convert) {
  TestModel iModel;
  TestModel oModel;
  string name = "name";
  string test = "test";
  iModel.set("name", name);
  iModel.set("test", test);
  Client::convert(iModel, oModel);
  ASSERT_EQ(name, boost::any_cast<string>(oModel.get("name")));
  ASSERT_EQ(test, boost::any_cast<string>(oModel.get("test")));
}

TEST(tests, query) {
  const map<string, boost::any> m = {
      {"str_test", "test"},
      {"int_test", 1}
  };
  map<string, string> result = Client::query(m);
  ASSERT_EQ("test", result.at("str_test"));
  ASSERT_EQ("1", result.at("int_test"));

  vector<boost::any> sl = {1, 2};
  map<string, boost::any> sub_map_fd = {
      {"int_test", 2},
      {"str_test", "test"}
  };
  map<string, boost::any> fd = {
      {"first_map_map", sub_map_fd},
      {"first_map_list", sl},
      {"int_test", 2},
      {"str_test", "test"}
  };

  map<string, string> res = Client::query(fd);
  ASSERT_EQ("1", res.at("first_map_list.1"));
  ASSERT_EQ("2", res.at("first_map_list.2"));
  ASSERT_EQ("2", res.at("first_map_map.int_test"));
  ASSERT_EQ("test", res.at("first_map_map.str_test"));
  ASSERT_EQ("2", res.at("int_test"));
  ASSERT_EQ("test", res.at("str_test"));
}

TEST(tests, getOpenPlatFormEndpoint) {
  ASSERT_EQ(
      "openplatform.aliyuncs.com",
      Client::getOpenPlatFormEndpoint("openplatform.aliyuncs.com", "")
  );

  ASSERT_EQ(
      "openplatform.aliyuncs.com",
      Client::getOpenPlatFormEndpoint("openplatform.aliyuncs.com", "cn-hangzhou")
  );

  ASSERT_EQ(
      "openplatform.ap-northeast-1.aliyuncs.com",
      Client::getOpenPlatFormEndpoint("openplatform.aliyuncs.com", "ap-northeast-1")
  );
}