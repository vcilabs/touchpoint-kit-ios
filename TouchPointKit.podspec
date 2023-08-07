Pod::Spec.new do |s|
    s.name = "TouchPointKit"
    s.version = "1.0.4"
    s.summary = "TouchPointKit enables easy integration with Alida Touchpoint."
    s.description = <<-DESC
    TouchPointKit enables easy integration with Alida Touchpoint.
    DESC
    s.homepage = "https://www.alida.com"
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'Alida' => 'mobileapp@alida.com' }
    s.source = { :git => "https://github.com/vcilabs/touchpoint-kit-ios", :tag => "#{s.version}" }
    s.public_header_files = "TouchPointKit.xcframework/*/TouchPointKit.framework/Headers/*.{h,m,swift}"
    s.source_files = "TouchPointKit.xcframework/*/TouchPointKit.framework/Headers/*.{h,m,swift}"
    s.vendored_frameworks = "TouchPointKit.xcframework"
    s.platform = :ios
    s.swift_version = "5.2.4"
    s.ios.deployment_target  = '10.0'
end
