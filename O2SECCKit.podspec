Pod::Spec.new do |s|
  s.name             = 'O2SECCKit'
  s.version          = "1.0.0"
  s.summary          = 'iOS 椭圆曲线SM2加解密、签验及SM3摘要，不依赖第三方OpenSSL'
  s.license          = 'MIT'
  s.author           = { "o2space" => "o2space@163.com" }

  s.homepage         = 'http://www.by2code.com'
  s.source           = { :git => 'https://github.com/o2space/O2SECCKit.git', :tag => s.version.to_s }
  s.platform         = :ios
  s.ios.deployment_target = "8.0"
  s.libraries        = 'c++'
  s.default_subspecs = 'O2SECCKit'

  # 核心模块
  s.subspec 'O2SECCKit' do |sp|
      sp.vendored_frameworks = 'O2SPACE_SDK/O2SECCSDK/O2SECCKit.framework'
  end

end
