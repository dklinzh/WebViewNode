//
//  JavaScriptBridge.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/9/6.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import WebViewJavascriptBridge

public typealias DLWebViewJavaScriptBridge = WKWebViewJavascriptBridge

extension DLWebViewJavaScriptBridge {
    public func registerHandler<T: RawRepresentable>(_ handlerType: T, handler: @escaping WVJBHandler) where T.RawValue == String {
        self.registerHandler(handlerType.rawValue, handler: handler)
    }
    
    public func removeHandler<T: RawRepresentable>(_ handlerType: T) where T.RawValue == String {
        self.removeHandler(handlerType.rawValue)
    }
    
    public func callHandler<T: RawRepresentable>(_ handlerType: T, data: Any? = nil, responseCallback: WVJBResponseCallback? = nil) where T.RawValue == String {
        self.callHandler(handlerType.rawValue, data: data, responseCallback: responseCallback)
    }
    
    public func removeAllHandlers() {
        if let base = self.value(forKey: "_base") as? WebViewJavascriptBridgeBase {
            base.messageHandlers.removeAllObjects()
        }
    }
}

// MARK: - JavaScript Bridge

public protocol JavaScriptBridge: class {
    /// JavaScript bridge object for a WKWebView.
    var jsBridge: DLWebViewJavaScriptBridge? { get set }
    
    /// Bind a JavaScript bridge for the given web view with its navigation delegate.
    ///
    /// - Parameters:
    ///   - webView: The given web view to bridge.
    ///   - delegate: The navigation delegate of web view.
    func bindJSBridge(webView: WKWebView, delegate: WKNavigationDelegate?)
    
    /// Register a handler called by JavaScript with the given key.
    ///
    /// - Parameters:
    ///   - handlerKey: The key name of handler.
    ///   - handler: The handler to be called by JavaScript.
    func registerJSHandler(_ handlerKey: String, handler: @escaping WVJBHandler)
    
    /// Remove the handler has been registered by JavaScript with the given key.
    ///
    /// - Parameter handlerKey: The key name of handler.
    func removeJSHandler(_ handlerKey: String)
    
    /// Call the JavaScript handler with the given key.
    ///
    /// - Parameters:
    ///   - handlerKey: The key name of handler.
    ///   - data: The data pass to the JavaScript handler argument.
    ///   - responseCallback: The call back block responded by the JavaScript handler.
    func callJSHandler(_ handlerKey: String, data: Any?, responseCallback: WVJBResponseCallback?)
    
    /// Register a handler called by JavaScript with the given key.
    ///
    /// - Parameters:
    ///   - handlerType: The handler type of String raw value.
    ///   - handler: The handler to be called by JavaScript.
    func registerJSHandler<T: RawRepresentable>(_ handlerType: T, handler: @escaping WVJBHandler) where T.RawValue == String
    
    /// Remove the handler has been registered by JavaScript with the given type.
    ///
    /// - Parameter handlerType: The handler type of String raw value.
    func removeJSHandler<T: RawRepresentable>(_ handlerType: T) where T.RawValue == String
    
    /// Call the JavaScript handler with the given type.
    ///
    /// - Parameters:
    ///   - handlerType: The handler type of String raw value.
    ///   - data: The data pass to the JavaScript handler argument.
    ///   - responseCallback: The call back block responded by the JavaScript handler.
    func callJSHandler<T: RawRepresentable>(_ handlerType: T, data: Any?, responseCallback: WVJBResponseCallback?) where T.RawValue == String
    
    /// Remove all handlers have been registered.
    func removeAllJSHandlers()
    
    /// Override this method to register JavaScript handlers with bridge.
    ///
    /// - Parameter bridge: JavaScript bridge object for a WKWebView.
    func registerJSHandlers(bridge: DLWebViewJavaScriptBridge)
}

private var _jsBridgeKey: Int = 0
extension JavaScriptBridge {
    public var jsBridge: DLWebViewJavaScriptBridge? {
        get {
            return objc_getAssociatedObject(self, &_jsBridgeKey) as? DLWebViewJavaScriptBridge
        }
        set {
            objc_setAssociatedObject(self, &_jsBridgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func bindJSBridge(webView: WKWebView, delegate: WKNavigationDelegate?) {
        if let _jsBridge = DLWebViewJavaScriptBridge(for: webView) {
            if let delegate = delegate {
                _jsBridge.setWebViewDelegate(delegate)
            }
            self.jsBridge = _jsBridge
        }
    }
    
    public func registerJSHandler(_ handlerKey: String, handler: @escaping WVJBHandler) {
        self.jsBridge?.registerHandler(handlerKey, handler: handler)
    }
    
    public func removeJSHandler(_ handlerKey: String) {
        self.jsBridge?.removeHandler(handlerKey)
    }
    
    public func callJSHandler(_ handlerKey: String, data: Any? = nil, responseCallback: WVJBResponseCallback? = nil) {
        self.jsBridge?.callHandler(handlerKey, data: data, responseCallback: responseCallback)
    }
    
    public func registerJSHandler<T: RawRepresentable>(_ handlerType: T, handler: @escaping WVJBHandler) where T.RawValue == String {
        self.jsBridge?.registerHandler(handlerType, handler: handler)
    }
    
    public func removeJSHandler<T: RawRepresentable>(_ handlerType: T) where T.RawValue == String {
        self.jsBridge?.removeHandler(handlerType)
    }
    
    public func callJSHandler<T: RawRepresentable>(_ handlerType: T, data: Any? = nil, responseCallback: WVJBResponseCallback? = nil) where T.RawValue == String {
        self.jsBridge?.callHandler(handlerType, data: data, responseCallback: responseCallback)
    }
    
    public func removeAllJSHandlers() {
        self.jsBridge?.removeAllHandlers()
    }
}

extension DLWebView: JavaScriptBridge {
    /// Bind a JavaScript bridge to the web view itself.
    public func bindJSBridge() {
        self.bindJSBridge(webView: self, delegate: self)
        self.registerJSHandlers(bridge: self.jsBridge!)
    }
    
    @objc
    open func registerJSHandlers(bridge: DLWebViewJavaScriptBridge) {}
}

extension DLWebViewController: JavaScriptBridge {
    /// Bind a JavaScript bridge to the web view of view controller.
    public func bindJSBridge() {
        self.webView.bindJSBridge()
        self.jsBridge = self.webView.jsBridge
        self.registerJSHandlers(bridge: self.jsBridge!)
    }
    
    @objc
    open func registerJSHandlers(bridge: DLWebViewJavaScriptBridge) {}
}

#if WebViewNode_Node

extension DLWebNode: JavaScriptBridge {
    /// Bind a JavaScript bridge to the web node itself.
    ///
    /// - Parameter completion: Invoked when the binding has completed.
    public func bindJSBridge(completion: ((DLWebViewJavaScriptBridge) -> Void)? = nil) {
        self.appendViewAssociation { [weak self] view in
            view.bindJSBridge()
            if let jsBridge = view.jsBridge {
                guard let strongSelf = self else { return }
                
                strongSelf.jsBridge = jsBridge
                strongSelf.registerJSHandlers(bridge: jsBridge)
                
                completion?(jsBridge)
            }
        }
    }
    
    @objc
    open func registerJSHandlers(bridge: DLWebViewJavaScriptBridge) {}
}

extension DLWebNodeController: JavaScriptBridge {
    /// Bind a JavaScript bridge to the web node of view controller.
    ///
    /// - Parameter completion: Invoked when the binding has completed.
    public func bindJSBridge(completion: ((DLWebViewJavaScriptBridge) -> Void)? = nil) {
        self.webNode.bindJSBridge { jsBridge in
            self.jsBridge = jsBridge
            self.registerJSHandlers(bridge: jsBridge)
            
            completion?(jsBridge)
        }
    }
    
    @objc
    open func registerJSHandlers(bridge: DLWebViewJavaScriptBridge) {}
}

#endif
