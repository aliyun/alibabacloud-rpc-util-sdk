Pod::Spec.new do |spec|

  spec.name         = "AlibabaCloudRpcUtils"
  spec.version      = "0.1.0"
  spec.license      = "Apache 2.0"
  spec.summary      = "Alibaba Cloud RPC Util SDK for Swift"
  spec.homepage     = "https://github.com/alibabacloud-sdk-swift/rpc-utils" 
  spec.author       = { "Alibaba Cloud SDK" => "sdk-team@alibabacloud.com" }

  spec.source       = { :git => spec.homepage + '.git', :tag => spec.version }
  spec.source_files = 'Sources/**/*.swift'

  spec.ios.framework   = 'Foundation'

  spec.osx.deployment_target = "10.11"
  spec.ios.deployment_target = "8.0"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target = "9.0"

  spec.dependency 'Tea',  '~> 0.3'
  spec.dependency 'SWXMLHash',  '~> 5.0.1'
  spec.dependency 'SwiftyJSON',  '~> 5.0'
  spec.dependency 'CryptoSwift',  '~> 1.3'
  spec.swift_version = '5.1'

end
