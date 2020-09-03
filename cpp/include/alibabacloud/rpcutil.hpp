// This file is auto-generated, don't edit it. Thanks.

#ifndef ALIBABACLOUD_RPCUTIL_H_
#define ALIBABACLOUD_RPCUTIL_H_

#include <boost/any.hpp>
#include <darabonba/core.hpp>
#include <iostream>
#include <map>

using namespace Darabonba;
using namespace std;

namespace Alibabacloud_RPCUtil {
class Client {
public:
  Client();
  ~Client();

  string getEndpoint(string endpoint, bool serverUse, string endpointType);
  string getHost(string productId, string regionId, string endpoint);
  string getSignature(Request request, string secret);
  string getSignatureV1(map<string, string> signedParams, string method, string secret);
  bool hasError(map<string, boost::any> obj);
  string getTimestamp();
  void convert(Model body, Model content);
  map<string, string> query(map<string, boost::any> filter);
  string getOpenPlatFormEndpoint(string endpoint, string regionId);
};
} // namespace Alibabacloud_RPCUtil

#endif
