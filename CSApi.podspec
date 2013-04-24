Pod::Spec.new do |s|
  s.name         = "CSApi"
  s.version      = "0.0.1"
  s.summary      = "Client library for using the Cogenta Shopping API."
  s.homepage     = "http://EXAMPLE/CSApi"
  s.license      = 'MIT'
  s.author       = { "Will Harris" => "will@greatlibrary.net" }
  s.source       = { :local => "." }
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.7'
  s.source_files = 'Classes', 'CSApi/**/*.{h,m}'
  s.public_header_files = 'CSApi/CSApi.h'
  s.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'Foundation'
  s.requires_arc = true
  s.dependency 'AFNetworking'
  s.dependency 'HyperBek', :local => '../hyperbek'
  s.dependency 'Base64'
  s.dependency 'NSArray+Functional'
  s.dependency 'ISO8601DateFormatter'
end
