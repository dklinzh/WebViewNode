//
//  DLWebView.swift
//  WebViewNode
//
//  Created by Daniel Lin on 9/3/17.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.
//

import WebKit

open class DLWebView: WKWebView {
    
    /// The delegate of DLWebView.
    public weak var webViewDelegate: DLWebViewDelegate?
    
    /// The loading progress view on the top of web view.
    public lazy var progressView = WebLoadingProgressView(webView: self, progressAnimationStyle: .smooth)
    
    /// Determine whether or not the loading progress view should be shown. Defaults to false.
    public var isProgressShown: Bool = false {
        didSet {
            if oldValue == isProgressShown {
                return
            }
            
            if isProgressShown {
                self.addSubview(progressView)
            } else {
                progressView.removeFromSuperview()
            }
        }
    }
    
    /// A dictionary of the custom HTTP header fields for URL request.
    public var customHTTPHeaderFields: [String : String]?
    
    @available(iOS 10.0, *)
    /// Determine whether or not the given element should show a preview by 3D touch. Defaults to false.
    public var shouldPreviewElementBy3DTouch: Bool {
        get {
            return _shouldPreviewElementBy3DTouch
        }
        set {
            _shouldPreviewElementBy3DTouch = newValue
        }
    }
    private var _shouldPreviewElementBy3DTouch = false
    
    private var _validSchemes = Set<String>(["http", "https", "tel", "file"])
    
    private var _isCookiesShared = false
    private var _pageTitleDidChangeBlock: ((_ title: String?) -> Void)?
    private var _pageTitleContext = 0
    
//    private var _authenticated = false
//    private var _failedRequest: URLRequest?
    
    /// A web view initialization.
    ///
    /// - Parameters:
    ///   - isCookiesShared: Determine whether or not the initialized web view should be shared with cookies from the HTTP cookie storage. Defaults to false.
    ///   - isUserScalable: Determine whether or not the frame of web view can be scaled by user. Defaults to false.
    public convenience init(isCookiesShared: Bool = false, isUserScalable: Bool = false) {
        let webViewConfig = WKWebViewConfiguration()
        
        if isCookiesShared, let script = WebJavaScriptCookies() {
            let cookieScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webViewConfig.userContentController.addUserScript(cookieScript)
        }
        
        if !isUserScalable {
            let script = """
                var script = document.createElement('meta');
                script.name = 'viewport';
                script.content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";
                document.getElementsByTagName('head')[0].appendChild(script);
            """
            let scaleScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webViewConfig.userContentController.addUserScript(scaleScript)
        }
        
        self.init(frame: .zero, configuration: webViewConfig)
        _isCookiesShared = isCookiesShared
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        self.navigationDelegate = self
        self.uiDelegate = self
        self.isMultipleTouchEnabled = true
        self.scrollView.alwaysBounceVertical = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if _pageTitleDidChangeBlock != nil {
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if isProgressShown {
            var frame = self.bounds
            frame.size.height = progressView.frame.size.height
            frame.origin.y -= self.scrollView.bounds.origin.y
            progressView.frame = frame
        }
    }
    
    /// Add custom valid URL schemes for the web view navigation.
    ///
    /// - Parameter schemes: An array of URL scheme.
    public func addCustomValidSchemes(_ schemes: [String]) {
        schemes.forEach { (scheme) in
            self._validSchemes.insert(scheme.lowercased())
        }
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter urlString: A string of the URL to navigate to.
    public func load(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        load(url)
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    public func load(_ url: URL) {
        self.load(URLRequest(url: url))
    }
    
    @discardableResult
    open override func load(_ request: URLRequest) -> WKNavigation? {
        var mutableRequest = request
        if _isCookiesShared, let cookies = HTTPCookieStorage.shared.cookies {
            if let allHTTPHeaderFields = mutableRequest.allHTTPHeaderFields {
                if allHTTPHeaderFields.index(forKey: "Cookie") == nil {
                    HTTPCookie.requestHeaderFields(with: cookies).forEach { mutableRequest.allHTTPHeaderFields![$0] = $1 }
                }
            } else {
                mutableRequest.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
            }
        }
        if let httpHeaderFields = customHTTPHeaderFields {
            if mutableRequest.allHTTPHeaderFields != nil {
                httpHeaderFields.forEach { mutableRequest.allHTTPHeaderFields![$0] = $1 }
            } else {
                mutableRequest.allHTTPHeaderFields = httpHeaderFields
            }
        }
        
        return super.load(mutableRequest)
    }
    
    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        if let filePath = bundle.path(forResource: fileName, ofType: "html") {
            let html = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            self.loadHTMLString(html, baseURL: bundle.resourceURL)
        }
    }
    
    /// Add an observer to the page title of web view
    ///
    /// - Parameter block: Invoked when the page title has been changed.
    public func pageTitleDidChange(_ block: ((_ title: String?) -> Void)?) {
        if (_pageTitleDidChangeBlock == nil && block == nil) || (_pageTitleDidChangeBlock != nil && block != nil) {
            _pageTitleDidChangeBlock = block
            return
        }
        
        _pageTitleDidChangeBlock = block
        if block != nil {
            self.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: [], context: &_pageTitleContext)
        } else {
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.title) && context == &_pageTitleContext {
            _pageTitleDidChangeBlock?(self.title)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func externalAppRequiredToOpen(url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }
        
        return !_validSchemes.contains(scheme)
    }
    
    // FIXME: Strings Localization
    private func launchExternalApp(url: URL) {
        let alertController = UIAlertController(title: "Leave current app?", message: "This web page is trying to open an outside app. Are you sure you want to open it?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open App", style: .default) { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension DLWebView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewDelegate?.webView(webView as! DLWebView, didStartLoading: webView.url)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewDelegate?.webView(webView as! DLWebView, didFinishLoading: webView.url)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webViewDelegate?.webView(webView as! DLWebView, didFailToLoad: webView.url, error: error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webViewDelegate?.webView(webView as! DLWebView, didFailToLoad: webView.url, error: error)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if !externalAppRequiredToOpen(url: url) {
            if navigationAction.targetFrame == nil {
                load(url)
                decisionHandler(.cancel)
                return
            }
        } else if UIApplication.shared.canOpenURL(url) {
            launchExternalApp(url: url)
            decisionHandler(.cancel)
            return
        }
        
//        if let httpHeaderFields = customHTTPHeaderFields {
//            if let allHTTPHeaderFields = navigationAction.request.allHTTPHeaderFields {
//                if httpHeaderFields.contains(where: { (key, value) -> Bool in
//                    return allHTTPHeaderFields[key] != value
//                }) {
//                    decisionHandler(.cancel)
//                    self.load(navigationAction.request)
//                    return
//                }
//            } else {
//                decisionHandler(.cancel)
//                self.load(navigationAction.request)
//                return
//            }
//        }
        
        decisionHandler(webViewDelegate?.webView(webView as! DLWebView, decidePolicyFor: navigationAction) ?? .allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(webViewDelegate?.webView(webView as! DLWebView, decidePolicyFor: navigationResponse) ?? .allow)
    }
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload() // WebContent Process Crash & self.titile will be nil when it crash, then reload the webview
    }
    
// TODO: HTTPS request with self-signed certificate
}

// MARK: - WKUIDelegate
extension DLWebView: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let isMainFrame = navigationAction.targetFrame?.isMainFrame, isMainFrame else {
            guard let openNewWindow = webViewDelegate?.webView(webView as! DLWebView, shouldCreateNewWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures),
                openNewWindow else {
                    self.load(navigationAction.request)
                    return nil
            }
            
            return nil
        }
        
        return nil
    }
    
    @available(iOS 10.0, *)
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return _shouldPreviewElementBy3DTouch
    }
}

// MARK: - NSURLConnectionDataDelegate
//extension DLWebView: NSURLConnectionDataDelegate {
//
//    public func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            if let trust = challenge.protectionSpace.serverTrust {
//                let credential = URLCredential(trust: trust)
//                challenge.sender?.use(credential, for: challenge)
//            }
//        }
//        challenge.sender?.continueWithoutCredential(for: challenge)
//    }
//
//    public func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
//        _authenticated = true
//        connection.cancel()
//        if let failedRequest = _failedRequest {
//            _ = self.load(failedRequest)
//        }
//    }
//}
