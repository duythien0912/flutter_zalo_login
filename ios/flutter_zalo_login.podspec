#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_zalo_login.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_zalo_login'
  s.version          = '0.2.0'
  s.summary          = 'A Flutter plugin for native Zalo login on Android & iOS.'
  s.description      = <<-DESC
A Flutter plugin for allowing users to authenticate with native Android & iOS Zalo login SDKs.
                       DESC
  s.homepage         = 'https://github.com/duythien0912/flutter_zalo_login'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'duythien0912' => 'duythien0912@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'ZaloSDK', '~> 4.1'
  s.static_framework = true
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
