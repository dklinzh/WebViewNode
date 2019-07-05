#
# Be sure to run `pod lib lint WebViewNode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WebViewNode'
  s.version          = '0.2.0'
  s.summary          = 'A simple and useful WebView framework for iOS development on Swift.'
  s.description      = <<-DESC
    A simple and useful WebView framework for iOS development on Swift. 
    It is based on the subclass of WKWebView that bound with a JavaScript bridge. 
    And display supports for Texture(AsyncDisplayKit) with the custom web node.
                       DESC

  s.homepage         = 'https://github.com/dklinzh/WebViewNode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dklinzh' => 'linzhdk@gmail.com' }
  s.source           = { :git => 'https://github.com/dklinzh/WebViewNode.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'
  s.default_subspecs = 'Web', 'JSBridge'
  
  s.subspec 'Web' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.frameworks = 'WebKit', 'UIKit', 'Foundation'
    ss.source_files = 'WebViewNode/Classes/Web/*'
    ss.resources = 'WebViewNode/Assets/Web.xcassets'
  end

  s.subspec 'JSBridge' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.dependency 'WebViewJavascriptBridge', '~> 6.0'
    ss.dependency 'WebViewNode/Web'
    ss.source_files = 'WebViewNode/Classes/JSBridge/*'
    ss.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '-D WebViewNode_JSBridge'
    }
  end

  s.subspec 'Node' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.dependency 'Texture/Core', '~> 2.8'
    ss.dependency 'WebViewNode/Web'
    ss.source_files = 'WebViewNode/Classes/Node/*'
    ss.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '-D WebViewNode_Node'
    }
  end

end
