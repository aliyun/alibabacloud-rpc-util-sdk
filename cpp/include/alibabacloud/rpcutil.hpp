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

  static string getEndpoint(string endpoint, bool serverUse,
                            const string &endpointType);
  static string getHost(string productId, string regionId, string endpoint);
  static string getSignature(Request request, string secret);
  static string getSignatureV1(const map<string, string> &signedParams,
                               string method, string secret);
  static bool hasError(map<string, boost::any> obj);
  static string getTimestamp();
  static void convert(Model& body, Model& content);
  static map<string, string> query(map<string, boost::any> filter);
  static string getOpenPlatFormEndpoint(string endpoint, string regionId);
};
} // namespace Alibabacloud_RPCUtil

#endif
