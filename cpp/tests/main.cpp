#include "gtest/gtest.h"
#include <memory>
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

class TestModel: public Model
{
public:
  string getName() {
    return name;
  }

  string getTest() {
    return test;
  }

  void setName(string n) {
    name = std::move(n);
  }

  void setTest(string t) {
    test = std::move(t);
  }

  void validate() override {
    cout << "test validate";
  }

  map<string, boost::any> toMap() override{
    map<string, boost::any> result;
    result["name"] = name;
    result["test"] = test;
    return result;
  };

  void fromMap(map<string, boost::any> m) override{
    name = boost::any_cast<string>(m.at("name"));
    test = boost::any_cast<string>(m.at("test"));
  }
private:
  string name;
  string test;
};

TEST(tests, getEndpoint) {
  shared_ptr<string> endpoint(new string("ecs.cn-hangzhou.aliyuncs.com"));
  shared_ptr<bool> serverUse(new bool(false));
  shared_ptr<string> endpointType(new string("public"));

  ASSERT_EQ(string("ecs.cn-hangzhou.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, serverUse, endpointType));
  *endpointType = "internal";
  ASSERT_EQ(string("ecs-internal.cn-hangzhou.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, serverUse, endpointType));
  *serverUse = true;
  *endpointType = "accelerate";
  ASSERT_EQ(string("oss-accelerate.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, serverUse, endpointType));
}

TEST(tests, getHost) {
  shared_ptr<string> productId;
  shared_ptr<string> regionId;
  shared_ptr<string> endpoint(new string("testEndpoint"));
  ASSERT_EQ(*endpoint, Client::getHost(productId, regionId, endpoint));

  productId = std::make_shared<string>("CC_CN");
  regionId = std::make_shared<string>("CN-Hangzhou");
  *endpoint = "";
  ASSERT_EQ(string("cc.cn-hangzhou.aliyuncs.com"), Client::getHost(productId, regionId, endpoint));
}

TEST(tests, getSignature) {
  shared_ptr<string> secret(new string("secret"));
  shared_ptr<Request> TeaRequest(new Request());
  map<string, string> query = {
      {"query", "test"},
      {"body", "test"}
  };
  TeaRequest->query = query;

  ASSERT_EQ(string("XlUyV4sXjOuX5FnjUz9IF9tm5rU="), Client::getSignature(TeaRequest, secret));
}

TEST(tests, getSignatureV1) {
  shared_ptr<map<string, string>> query(new map<string, string>({
                                                                    {"query", "test"},
                                                                    {"body", "test"}
                                                                }));

  shared_ptr<string> method(new string("GET"));
  shared_ptr<string> secret(new string("secret"));
  ASSERT_EQ(string("XlUyV4sXjOuX5FnjUz9IF9tm5rU="), Client::getSignatureV1(query, method, secret));
}

TEST(tests, hasError) {
  shared_ptr<map<string, boost::any>> m;
  ASSERT_TRUE(Client::hasError(m));

  m = std::make_shared<map<string, boost::any>>();
  ASSERT_FALSE(Client::hasError(m));

  ASSERT_TRUE(Client::hasError(
      shared_ptr<map<string, boost::any>>(new map<string, boost::any>({{"Code", "a"}}))
      ));
}

TEST(tests, getTimestamp) {
  ASSERT_EQ(20, Client::getTimestamp().size());
}

TEST(tests, convert) {
  string name = "name";
  string test = "test";
  shared_ptr<TestModel> iModel(new TestModel);
  shared_ptr<TestModel> oModel(new TestModel);
  iModel->setName(name);
  iModel->setTest(test);
  Alibabacloud_RPCUtil::Client::convert(iModel, oModel);
  ASSERT_EQ(name, oModel->getName());
  ASSERT_EQ(test, oModel->getTest());
}

TEST(tests, query) {
  shared_ptr<map<string, boost::any>> m(new map<string, boost::any>({
                                                                    {"str_test", "test"},
                                                                    {"int_test", 1}
                                                                }));
  map<string, string> result = Client::query(m);
  ASSERT_EQ("test", result.at("str_test"));
  ASSERT_EQ("1", result.at("int_test"));

  vector<boost::any> sl = {1, 2};
  map<string, boost::any> sub_map_fd = {
      {"int_test", 2},
      {"str_test", "test"}
  };
  shared_ptr<map<string, boost::any>> fd(new map<string, boost::any>({
                                             {"first_map_map", sub_map_fd},
                                             {"first_map_list", sl},
                                             {"int_test", 2},
                                             {"str_test", "test"}
                                         }));

  map<string, string> res = Client::query(fd);
  ASSERT_EQ("1", res.at("first_map_list.1"));
  ASSERT_EQ("2", res.at("first_map_list.2"));
  ASSERT_EQ("2", res.at("first_map_map.int_test"));
  ASSERT_EQ("test", res.at("first_map_map.str_test"));
  ASSERT_EQ("2", res.at("int_test"));
  ASSERT_EQ("test", res.at("str_test"));
}

TEST(tests, getOpenPlatFormEndpoint) {
  shared_ptr<string> endpoint(new string("openplatform.aliyuncs.com"));
  shared_ptr<string> region_id(new string(""));
  ASSERT_EQ(
      string("openplatform.aliyuncs.com"),
      Client::getOpenPlatFormEndpoint(endpoint, region_id)
  );
  *region_id = "cn-hangzhou";
  ASSERT_EQ(
      string("openplatform.aliyuncs.com"),
      Client::getOpenPlatFormEndpoint(endpoint, region_id)
  );
  *region_id = "ap-northeast-1";
  ASSERT_EQ(
      string("openplatform.ap-northeast-1.aliyuncs.com"),
      Client::getOpenPlatFormEndpoint(endpoint, region_id)
  );
}