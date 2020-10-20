#include "crypt/base64.h"
#include "crypt/hmac.h"
#include "crypt/sha1.h"
#include "crypt/sha256.h"
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

string Alibabacloud_RPCUtil::Client::getEndpoint(shared_ptr<string> endpoint,
                                                 shared_ptr<bool> serverUse,
                                                 shared_ptr<string> endpointType) {
  string e = !endpoint ? "" : *endpoint;
  bool s;
  if (!serverUse) {
    s = false;
  } else {
    s = *serverUse;
  }
  string et = !endpointType ? "" : *endpointType;
  if (et == string("internal")) {
    std::vector<std::string> tmp = explode(e, ".");
    tmp.at(0) = tmp.at(0).append("-internal");
    e = implode(tmp, ".");
  }
  if (s && et == string("accelerate")) {
    e = "oss-accelerate.aliyuncs.com";
  }
  return e;
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

string Alibabacloud_RPCUtil::Client::getHost(shared_ptr<string> productId,
                                             shared_ptr<string> regionId,
                                             shared_ptr<string> endpoint) {
  string p = !productId ? "" : *productId;
  string r = !regionId ? "" : *regionId;
  string e = !endpoint ? "" : *endpoint;
  p = p.substr(0, p.find('_'));
  if (e.empty()) {
    e = lowercase(std::move(p)) + "." + lowercase(std::move(r)) +
        ".aliyuncs.com";
  }
  return e;
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
      .append("&%2F&")
      .append(url_encode(str));
}

string Alibabacloud_RPCUtil::Client::getSignature(shared_ptr<Request> request,
                                                  shared_ptr<string> secret) {
  Request r = !request ? Request() : *request;
  std::string s = !secret ? "" : *secret;

  std::string str = strToSign(r.method, r.query);
  std::string sign_method = "HMAC-SHA1";
  if (r.query.find("SignatureMethod") != r.query.end()) {
    sign_method = uppercase(r.query.at("SignatureMethod"));
  }
  s = s + "&";
  if (sign_method == "HMAC-SHA1") {
    boost::uint8_t hash_val[sha1::HASH_SIZE];
    hmac<sha1>::calc(str, s, hash_val);
    return base64::encode_from_array(hash_val, sha1::HASH_SIZE);
  } else {
    boost::uint8_t hash_val[sha256::HASH_SIZE];
    hmac<sha256>::calc(str, s, hash_val);
    return base64::encode_from_array(hash_val, sha256::HASH_SIZE);
  }
}

string
Alibabacloud_RPCUtil::Client::getSignatureV1(shared_ptr<map<string, string>> signedParams,
                                             shared_ptr<string> method,
                                             shared_ptr<string> secret) {
  map<string, string> sp;
  if (!signedParams) {
    sp = map<string, string>();
  } else {
    sp = *signedParams;
  }
  string m = !method ? "" : *method;
  string s = !secret ? "" : *secret;

  std::string str = strToSign(std::move(m), sp);
  s = s + "&";
  boost::uint8_t hash_val[sha1::HASH_SIZE];
  hmac<sha1>::calc(str, s, hash_val);
  return base64::encode_from_array(hash_val, sha1::HASH_SIZE);
}

bool Alibabacloud_RPCUtil::Client::hasError(shared_ptr<map<string, boost::any>> obj) {
  if (!obj) {
    return true;
  }
  map<string, boost::any> o = *obj;
  if (o.empty()) {
    return false;
  }
  if (o.find("Code") == o.end()) {
    return false;
  }
  if (o.at("Code").type() == typeid(string)) {
    string r = boost::any_cast<string>(o.at("Code"));
    if (!r.empty() && r != "0") {
      return true;
    }
  } else if (o.at("Code").type() == typeid(char *)) {
    char *r = boost::any_cast<char *>(o.at("Code"));
    if (std::strncmp(r, "", 1) != 0 && std::strncmp(r, "0", 1) != 0) {
      return true;
    }
  } else if (o.at("Code").type() == typeid(const char *)) {
    const char *r = boost::any_cast<const char *>(o.at("Code"));
    if (std::strncmp(r, "", 1) != 0 && std::strncmp(r, "0", 1) != 0) {
      return true;
    }
  } else if (o.at("Code").type() == typeid(int)) {
    int r = boost::any_cast<int>(o.at("Code"));
    if (r != 0) {
      return true;
    }
  }
  return false;
}

string Alibabacloud_RPCUtil::Client::getTimestamp() {
  auto now = std::chrono::system_clock::now();
  auto itt = std::chrono::system_clock::to_time_t(now);

  std::ostringstream ss;
  ss << std::put_time(gmtime(&itt), "%FT%TZ");
  return ss.str();
}

void Alibabacloud_RPCUtil::Client::convert(const shared_ptr<Model>& body,
                                           const shared_ptr<Model>& content) {
  map<string, boost::any> props;
  map<std::string, boost::any> properties = body->toMap();
  for (const auto &it : properties) {
    props[it.first] = it.second;
  }
  content->fromMap(props);
}

void flatten(map<string, string> &res, std::string prefix, boost::any curr) {
  if (typeid(map<string, boost::any>) == curr.type()) {
    map<string, boost::any> m = boost::any_cast<map<string, boost::any>>(curr);
    for (const auto &it : m) {
      std::string p;
      if (prefix.empty()) {
        p = prefix + it.first;
      } else {
        p = prefix + "." + it.first;
      }
      flatten(res, p, it.second);
    }
  } else if (typeid(vector<boost::any>) == curr.type()) {
    vector<boost::any> v = boost::any_cast<vector<boost::any>>(curr);
    int n = 0;
    for (const auto &it : v) {
      std::string p;
      if (prefix.empty()) {
        p = prefix + to_string(n + 1);
      } else {
        p = prefix + "." + to_string(n + 1);
      }
      flatten(res, p, it);
      n++;
    }
  } else {
    if (typeid(string) == curr.type()) {
      std::string v = boost::any_cast<string>(curr);
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(int) == curr.type()) {
      string v = std::to_string(boost::any_cast<int>(curr));
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(long) == curr.type()) {
      string v = std::to_string(boost::any_cast<long>(curr));
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(double) == curr.type()) {
      string v = std::to_string(boost::any_cast<double>(curr));
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(float) == curr.type()) {
      string v = std::to_string(boost::any_cast<float>(curr));
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(bool) == curr.type()) {
      auto b = boost::any_cast<bool>(curr);
      string v = b ? "true" : "false";
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(const char *) == curr.type()) {
      const char *v = boost::any_cast<const char *>(curr);
      res.insert(pair<string, string>(prefix, v));
    } else if (typeid(char *) == curr.type()) {
      char *v = boost::any_cast<char *>(curr);
      res.insert(pair<string, string>(prefix, v));
    }
  }
}

map<string, string>
Alibabacloud_RPCUtil::Client::query(shared_ptr<map<string, boost::any>> filter) {
  map<string, string> flat;
  flatten(flat, string(""), boost::any(*filter));
  map<string, string> res;
  for (auto it : flat) {
    res.insert(pair<string, string>(it.first, it.second));
  }
  return res;
}

string Alibabacloud_RPCUtil::Client::getOpenPlatFormEndpoint(shared_ptr<string> endpoint,
                                                             shared_ptr<string> regionId) {
  std::vector<string> supportedRegionId = {"ap-southeast-1", "ap-northeast-1",
                                           "eu-central-1", "cn-hongkong",
                                           "ap-south-1"};
  string region_id = nullptr == regionId ? "" : *regionId;
  string e = nullptr == endpoint ? "" : *endpoint;
  region_id = lowercase(region_id);
  if (!regionId->empty()) {
    bool exist = std::find(supportedRegionId.begin(), supportedRegionId.end(),
                           region_id) != supportedRegionId.end();

    if (exist) {
      vector<string> tmp = explode(e, ".");
      tmp.at(0) = tmp.at(0).append(".").append(lowercase(region_id));
      return implode(tmp, ".");
    }
  }
  return e;
}
