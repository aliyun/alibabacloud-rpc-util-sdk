#include "gtest/gtest.h"
#include "alibabacloud/rpcutil.hpp"

using namespace std;

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

TEST(tests, getEndpoint) {
  string endpoint = "ecs.cn-hangzhou.aliyuncs.com";;
  ASSERT_EQ(string("ecs.cn-hangzhou.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, false, "public"));
  ASSERT_EQ(string("ecs-internal.cn-hangzhou.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, false, "internal"));
  ASSERT_EQ(string("oss-accelerate.aliyuncs.com"),
            Alibabacloud_RPCUtil::Client::getEndpoint(endpoint, true, "accelerate"));
}