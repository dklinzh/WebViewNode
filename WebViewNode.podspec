#
# Be sure to run `pod lib lint WebViewNode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WebViewNode'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WebViewNode.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/dklinzh/WebViewNode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dklinzh' => 'linzhdk@gmail.com' }
  s.source           = { :git => 'https://github.com/dklinzh/WebViewNode.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = '4.1'

  s.default_subspecs = 'Web', 'JSBridge'
  
  s.subspec 'Web' do |web|
    web.ios.deployment_target = '8.0'
    web.frameworks = 'WebKit', 'UIKit', 'Foundation'
    web.source_files = 'WebViewNode/Classes/Web/*'
  end

  s.subspec 'JSBridge' do |js|
    js.ios.deployment_target = '8.0'
    js.dependency 'WebViewJavascriptBridge', '~> 6.0'
    js.dependency 'WebViewNode/Web'
    js.source_files = 'WebViewNode/Classes/JSBridge/*'
  end

end