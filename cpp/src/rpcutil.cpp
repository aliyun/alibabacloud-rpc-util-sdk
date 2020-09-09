#include "hmac.h"
#include "sha1.h"
#include "sha256.h"
#include <alibabacloud/rpcutil.hpp>
#include <boost/any.hpp>
#include <darabonba/core.hpp>
#include <iostream>
#include <map>
#include <utility>

using namespace Darabonba;
using namespace std;

std::vector<std::string> explode(const std::string &str,
                                 const std::string &delimiter) {
  int pos = str.find(delimiter, 0);
  int pos_start = 0;
  int split_n = pos;
  string line_text(delimiter);

  std::vector<std::string> dest;

  while (pos > -1) {
    line_text = str.substr(pos_start, split_n);
    pos_start = pos + 1;
    pos = str.find(delimiter, pos + 1);
    split_n = pos - pos_start;
    dest.push_back(line_text);
  }
  line_text = str.substr(pos_start, str.length() - pos_start);
  dest.push_back(line_text);
  return dest;
}
std::string implode(const std::vector<std::string> &vec,
                    const std::string &glue) {
  string res;
  int n = 0;
  for (const auto &str : vec) {
    if (n == 0) {
      res = str;
    } else {
      res += glue + str;
    }
    n++;
  }
  return res;
}
string Alibabacloud_RPCUtil::Client::getEndpoint(string endpoint,
                                                 bool serverUse,
                                                 const string &endpointType) {
  if (endpointType == string("internal")) {
    std::vector<std::string> tmp = explode(endpoint, ".");
    tmp.at(0) = tmp.at(0).append("-internal");
    endpoint = implode(tmp, ".");
  }
  if (serverUse && endpointType == string("accelerate")) {
    return string("oss-accelerate.aliyuncs.com");
  }
  return endpoint;
}

string lowercase(string str) {
  std::transform(str.begin(), str.end(), str.begin(),
                 [](unsigned char c) { return std::tolower(c); });
  return str;
}

string uppercase(string str) {
  std::transform(str.begin(), str.end(), str.begin(),
                 [](unsigned char c) { return std::toupper(c); });
  return str;
}

string Alibabacloud_RPCUtil::Client::getHost(string productId, string regionId,
                                             string endpoint) {
  if (endpoint.empty()) {
    std::string ss;
    ss = ss.append(lowercase(std::move(productId)))
             .append(".")
             .append(lowercase(std::move(regionId)))
             .append(".aliyuncs.com");
    return ss;
  }
  return endpoint;
}

string url_encode(const std::string &str) {
  std::stringstream escaped;
  escaped.fill('0');
  escaped << hex;

  for (char c : str) {
    if (isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
      escaped << c;
      continue;
    }
    escaped << std::uppercase;
    escaped << '%' << std::setw(2) << int((unsigned char)c);
    escaped << nouppercase;
  }

  return escaped.str();
}

std::string strToSign(std::string method, const map<string, string> &query) {
  std::vector<string> tmp;
  for (const auto &it : query) {
    std::string s;
    s = s.append(url_encode(it.first))
            .append("=")
            .append(url_encode(it.second));
    tmp.push_back(s);
  }
  std::string str = implode(tmp, "&");
  std::string res;
  return res.append(uppercase(std::move(method)))
      .append(url_encode("/"))
      .append("&")
      .append(url_encode(str));
}

string Alibabacloud_RPCUtil::Client::getSignature(Request request,
                                                  string secret) {
  std::string str = strToSign(request.method, request.query);
  std::string sign_method = "HMAC-SHA1";
  if (request.query.find("SignatureMethod") != request.query.end()) {
    sign_method = uppercase(request.query.at("SignatureMethod"));
  }
  secret = secret.append("&");
  if (sign_method == "HMAC-SHA1") {
    return hmac<sha1>::calc_hex(str, secret);
  } else {
    return hmac<sha256>::calc_hex(str, secret);
    ;
  }
}

string Alibabacloud_RPCUtil::Client::getSignatureV1(
    const map<string, string> &signedParams, string method, string secret) {
  std::string str = strToSign(std::move(method), signedParams);
  secret = secret.append("&");
  return hmac<sha1>::calc_hex(str, secret);
}

bool Alibabacloud_RPCUtil::Client::hasError(map<string, boost::any> obj) {
  if (obj.empty()) {
    return true;
  }
  if (obj.find("Code") == obj.end()) {
    return false;
  }
  std::string code = boost::any_cast<string>(obj.at("Code"));
  return lowercase(code) != "success";
}

string Alibabacloud_RPCUtil::Client::getTimestamp() {
  time_t time;
  char buf[80];
  std::strftime(buf, sizeof buf, "%FT%TZ", gmtime(&time));
  return buf;
}

void Alibabacloud_RPCUtil::Client::convert(Model body, Model content) {
  map<std::string, boost::any> properties = body.toMap();
  for (const auto &it : properties) {
    content.set(it.first, it.second);
  }
}

map<string, string>
Alibabacloud_RPCUtil::Client::query(const map<string, boost::any> &filter) {
  map<string, string> query;
  for (const auto &it : filter) {
    boost::any val = it.second;
    if (typeid(string) == val.type()) {
      std::string v = boost::any_cast<string>(val);
      query[it.first] = v;
    } else if (typeid(int) == val.type()) {
      int v = boost::any_cast<int>(val);
      query[it.first] = std::to_string(v);
    } else if (typeid(long) == val.type()) {
      long v = boost::any_cast<long>(val);
      query[it.first] = std::to_string(v);
    } else if (typeid(double) == val.type()) {
      auto v = boost::any_cast<double>(val);
      query[it.first] = std::to_string(v);
    } else if (typeid(float) == val.type()) {
      auto v = boost::any_cast<float>(val);
      query[it.first] = std::to_string(v);
    } else if (typeid(bool) == val.type()) {
      auto b = boost::any_cast<bool>(val);
      string c = b ? "true" : "false";
      query[it.first] = c;
    } else if (typeid(const char *) == val.type()) {
      const char *v = boost::any_cast<const char *>(val);
      query[it.first] = v;
    } else if (typeid(char *) == val.type()) {
      char *v = boost::any_cast<char *>(val);
      query[it.first] = v;
    }
  }
  return query;
}

string Alibabacloud_RPCUtil::Client::getOpenPlatFormEndpoint(string endpoint,
                                                             string regionId) {
  std::vector<string> supportedRegionId = {"ap-southeast-1", "ap-northeast-1",
                                           "eu-central-1", "cn-hongkong",
                                           "ap-south-1"};
  regionId = lowercase(regionId);
  if (!regionId.empty()) {
    bool exist = std::find(supportedRegionId.begin(), supportedRegionId.end(),
                           regionId) != supportedRegionId.end();
    if (exist) {
      vector<string> tmp = explode(endpoint, ".");
      tmp.at(0) = tmp.at(0).append(lowercase(regionId));
      return implode(tmp, ".");
    }
  }
  return endpoint;
}
