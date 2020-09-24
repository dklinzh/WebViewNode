# WebViewNode

[![CI Status](https://img.shields.io/travis/dklinzh/WebViewNode.svg?style=flat)](https://travis-ci.org/dklinzh/WebViewNode)
[![Version](https://img.shields.io/cocoapods/v/WebViewNode.svg?style=flat)](https://cocoapods.org/pods/WebViewNode)
[![License](https://img.shields.io/cocoapods/l/WebViewNode.svg?style=flat)](https://cocoapods.org/pods/WebViewNode)
[![Platform](https://img.shields.io/cocoapods/p/WebViewNode.svg?style=flat)](https://cocoapods.org/pods/WebViewNode)

## Example

To run the [example](/Example) project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Xcode 12+
* Swift 5+
* iOS Supports

| Submodule | iOS Target | Dependency |
|:---------:|:----------:|:----------:|
| Default   | iOS 8+     | /Web & /JSBridge |
| /Web      | iOS 8+     |  |
| /JSBridge | iOS 8+     | [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) & /Web |
| /Node     | iOS 9+     | [Texture/Core](https://github.com/TextureGroup/Texture) & /Web |

## Installation

WebViewNode is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WebViewNode', '~> 0.3'
```

## Author

dklinzh, linzhdk@gmail.com

## License

WebViewNode is available under the MIT license. See the LICENSE file for more info.
