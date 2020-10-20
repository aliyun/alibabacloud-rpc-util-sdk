// This file is auto-generated, don't edit it. Thanks.

#ifndef ALIBABACLOUD_RPCUTIL_H_
#define ALIBABACLOUD_RPCUTIL_H_

#include <boost/any.hpp>
#include <boost/shared_ptr.hpp>
#include <darabonba/core.hpp>
#include <iostream>
#include <map>

using namespace Darabonba;
using namespace std;


namespace Alibabacloud_RPCUtil {
class Client {
public:
  static string getEndpoint(shared_ptr<string> endpoint,
                            shared_ptr<bool> serverUse,
                            shared_ptr<string> endpointType);
  static string getHost(shared_ptr<string> productId,
                        shared_ptr<string> regionId,
                        shared_ptr<string> endpoint);
  static string getSignature(shared_ptr<Request> request,
                             shared_ptr<string> secret);
  static string getSignatureV1(shared_ptr<map<string, string>> signedParams,
                               shared_ptr<string> method,
                               shared_ptr<string> secret);
  static bool hasError(shared_ptr<map<string, boost::any>> obj);
  static string getTimestamp();
  static void convert(const shared_ptr<Model>& body,
                      const shared_ptr<Model>& content);
  static map<string, string> query(shared_ptr<map<string, boost::any>> filter);
  static string getOpenPlatFormEndpoint(shared_ptr<string> endpoint,
                                        shared_ptr<string> regionId);

  Client(){};
  ~Client(){};
};
} // namespace Alibabacloud_RPCUtil

#endif
