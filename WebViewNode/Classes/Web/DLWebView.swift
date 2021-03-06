//
//  DLWebView.swift
//  WebViewNode
//
//  Created by Daniel Lin on 9/3/17.
//  Copyright (c) 2017 Daniel Lin. All rights reserved.
//

import WebKit

/// The style of viewport fit with web content.
///
/// - `default`: The default value by itself.
/// - contain: The viewport should fully contain the web content.
/// - cover: The web content should fully cover the viewport.
public enum WebContentFitStyle: String {
    case `default`
    case contain
    case cover
}

/// Determine whether or not the frame of web view can be scaled by user.
///
/// - `default`: The default value by itself.
/// - disable: Disable the web view scaling.
/// - enable: Enable the web view scaling.
public enum WebUserScalable: String {
    case `default`
    case disable = "no"
    case enable = "yes"
}

/// Subclass of WKWebView
open class DLWebView: WKWebView {
    // MARK: Lifecycle

    /// A web view initialization.
    ///
    /// - Parameters:
    ///   - configuration: A collection of properties used to initialize a web view.
    ///   - cookiesShared: Determine whether or not the initialized web view should be shared with cookies from the HTTP cookie storage. Defaults to false.
    ///   - userSelected: Determine whether or not the content of web page can be selected by user. Defaults to true.
    ///   - userScalable: Determine whether or not the frame of web view can be scaled by user. Defaults value is `default`.
    ///   - contentFitStyle: The style of viewport fit with web content. Default value is `default`.
    ///   - customUserAgent: The custom user agent string of web view. Defaults to nil.
    public convenience init(configuration: DLWebViewConfiguration = DLWebViewConfiguration(),
                            cookiesShared: Bool = false,
                            userSelected: Bool = true,
                            userScalable: WebUserScalable = .default,
                            contentFitStyle: WebContentFitStyle = .default,
                            customUserAgent: String? = nil)
    {
        if cookiesShared, let script = WebKit.formatJavaScriptCookies() {
            let cookieScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(cookieScript)
        }

        if !userSelected {
            let script: String = """
            document.documentElement.style.webkitTouchCallout='none';
            document.documentElement.style.webkitUserSelect='none';
            """
            let selectedScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(selectedScript)
        }

        var viewportContents = [String]()
        if userScalable != .default {
            viewportContents.append("user-scalable=\(userScalable.rawValue)")
        }
        if contentFitStyle != .default {
            viewportContents.append("viewport-fit=\(contentFitStyle.rawValue)")
        }
        if !viewportContents.isEmpty {
            let script: String = """
            var script = document.createElement('meta');
            script.name = 'viewport';
            script.content= 'width=device-width, initial-scale=1.0, \(viewportContents.joined(separator: ", "))';
            document.getElementsByTagName('head')[0].appendChild(script);
            """
            let scaleScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(scaleScript)
        }

        if let customUserAgent = customUserAgent {
            if #available(iOS 9.0, *) {} else {
                UserDefaults.standard.register(defaults: ["UserAgent": customUserAgent])
            }
        }

        self.init(frame: .zero, configuration: configuration)
        self._cookiesShared = cookiesShared

        if let customUserAgent = customUserAgent {
            if #available(iOS 9.0, *) {
                self.customUserAgent = customUserAgent
            }
        }
    }

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        self.navigationDelegate = self
        self.uiDelegate = self
        self.isMultipleTouchEnabled = true
        scrollView.alwaysBounceVertical = true

        addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: [], context: &_urlContext)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))

        if _pageTitleDidChangeBlock != nil {
            _pageTitleDidChangeBlock = nil
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        }

        if _navigationCanGoBackBlock != nil {
            _navigationCanGoBackBlock = nil
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        }

        if _navigationCanGoForwardBlock != nil {
            _navigationCanGoForwardBlock = nil
            self.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        }

        if _webContentHeightDidChangeBlock != nil {
            _webContentHeightDidChangeBlock = nil
            self.scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        }

        if progressBarShown {
            self.removeObserver(progressBar, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        }
    }

    // MARK: Open

    override open func layoutSubviews() {
        super.layoutSubviews()

        if progressBarShown {
            progressBar.frame.origin.y -= scrollView.bounds.origin.y
        }
    }

    // MARK: - Web Loading

    @discardableResult
    override open func load(_ request: URLRequest) -> WKNavigation? {
        var mutableRequest = request
        if _cookiesShared, let cookies = HTTPCookieStorage.shared.cookies {
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

        //        mutableRequest.cachePolicy = .returnCacheDataElseLoad
        return super.load(mutableRequest)
    }

    @discardableResult
    override open func reload() -> WKNavigation? {
        if url != nil {
            return super.reload()
        } else if let url = _copyURL {
            return load(url)
        } else {
            return nil
        }
    }

    @discardableResult
    override open func reloadFromOrigin() -> WKNavigation? {
        if url != nil {
            return super.reloadFromOrigin()
        } else if let url = _copyURL {
            return load(url)
        } else {
            return nil
        }
    }

    // MARK: - JavaScript

    override open func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        if #available(iOS 9.0, *) {
            super.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
        } else {
            super.evaluateJavaScript(javaScriptString) { [weak self] result, error in
                guard let _ = self else { return } // Retain the weak referenc of self to keep completionHandler on iOS 8.

                completionHandler?(result, error)
            }
        }
    }

    // MARK: - Observe

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.title), context == &_pageTitleContext { // Page title did change.
            _pageTitleDidChangeBlock?(self.title)
        } else if keyPath == #keyPath(WKWebView.canGoBack), context == &_navigationCanGoBackContext { // Navigation canGoBack did change
            _navigationCanGoBackBlock?(self.canGoBack)
        } else if keyPath == #keyPath(WKWebView.canGoForward), context == &_navigationCanGoForwardContext { // Navigation canGoForward did change
            _navigationCanGoForwardBlock?(self.canGoForward)
        } else if keyPath == #keyPath(UIScrollView.contentSize), context == &_webContentHeightContext { // Height of content view did change.
            self.evaluateJavaScript("document.body.offsetHeight") { [weak self] result, _ in // != self.scrollView.contentSize.height
                guard let strongSelf = self else { return }

                if let height = result as? CGFloat,
                    height != strongSelf._webContentHeightHeight
                {
                    strongSelf._webContentHeightHeight = height

                    if strongSelf._webContentSizeFlexible {
                        strongSelf.frame.size.height = height
                    }

                    strongSelf._webContentHeightDidChangeBlock?(height)
                }
                // FIXME: Is it necessary to make scrollView.contentSize equal frame.size?
                //                if strongSelf.scrollView.contentSize != strongSelf.frame.size {
                //                    strongSelf.scrollView.contentSize = strongSelf.frame.size
                //                }
            }
        } else if keyPath == #keyPath(WKWebView.url), context == &_urlContext { // URL of web view did change.
            guard let url = self.url else {
                if !_provisionalNavigationFailed {
                    self.reload()
                }
                return
            }

            _copyURL = url
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: Public

    /// The delegate of DLWebView.
    public weak var delegate: DLWebViewDelegate?

    // MARK: - UI Appearance

    /// The loading progress view on the top of web view.
    public lazy var progressBar = WebLoadingProgressBar(webView: self, progressAnimationStyle: .smooth)

    // MARK: - JavaScript

    /// Determine whether or not the app window should display an alert, confirm or text input view from JavaScript functions. Defaults to true.
    public var shouldDisplayAlertPanelByJavaScript: Bool = true

    // MARK: - URL Request

    /// A dictionary of the custom HTTP header fields for URL request.
    public var customHTTPHeaderFields: [String: String]?

    /// Determine whether or not the loading progress view should be shown. Defaults to false.
    public var progressBarShown: Bool = false {
        didSet {
            if oldValue == progressBarShown {
                return
            }

            if progressBarShown {
                addSubview(progressBar)
            } else {
                progressBar.removeFromSuperview()
            }
        }
    }

    /// The color shown for the portion of the web loading progress bar that is filled.
    public var progressTintColor: UIColor? {
        get {
            return progressBar.progressTintColor
        }
        set {
            progressBar.progressTintColor = newValue
        }
    }

    /// A floating-point value that determines the rate of deceleration after the user lifts their finger. Use the normal and fast constants as reference points for reasonable deceleration rates. Defaults to normal.
    public var scrollDecelerationRate = UIScrollView.DecelerationRate.normal {
        didSet {
            scrollView.decelerationRate = scrollDecelerationRate
        }
    }

    /// Determine whether or not the given element of web link should show a preview by 3D Touch. Defaults to false.
    @available(iOS 9.0, *)
    public var shouldPreviewElementBy3DTouch: Bool {
        get {
            return _shouldPreviewElementBy3DTouch && allowsLinkPreview
        }
        set {
            allowsLinkPreview = newValue
            _shouldPreviewElementBy3DTouch = newValue
        }
    }

    /// Determine whether or not the web view controller should be closed by DOM window.close(). Defaults to false.
    @available(iOS 9.0, *)
    public var shouldCloseByDOMWindow: Bool {
        get {
            return _shouldCloseByDOMWindow
        }
        set {
            _shouldCloseByDOMWindow = newValue
        }
    }

    // MARK: - UI Appearance

    /// Add an observer for the page title of web view
    ///
    /// - Parameter block: Invoked when the page title has been changed.
    public func pageTitleDidChange(_ block: ((_ title: String?) -> Void)?) {
        if (_pageTitleDidChangeBlock == nil && block == nil) || (_pageTitleDidChangeBlock != nil && block != nil) {
            _pageTitleDidChangeBlock = block
            return
        }

        _pageTitleDidChangeBlock = block
        if block != nil {
            addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: [], context: &_pageTitleContext)
        } else {
            removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        }
    }

    /// Add an observer to indicate whether there is a back item in the back-forward list that can be navigated to.
    ///
    /// - Parameter block: Invoked when the value of key `canGoBack` has been changed.
    public func navigationCanGoBack(_ block: ((_ canGoBack: Bool) -> Void)?) {
        if (_navigationCanGoBackBlock == nil && block == nil) || (_navigationCanGoBackBlock != nil && block != nil) {
            _navigationCanGoBackBlock = block
            return
        }

        _navigationCanGoBackBlock = block
        if block != nil {
            addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: [], context: &_navigationCanGoBackContext)
        } else {
            removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        }
    }

    /// Add an observer to indicate whether there is a forward item in the back-forward list that can be navigated to.
    ///
    /// - Parameter block: Invoked when the value of key `canGoForward` has been changed.
    public func navigationCanGoForward(_ block: ((_ canGoForward: Bool) -> Void)?) {
        if (_navigationCanGoForwardBlock == nil && block == nil) || (_navigationCanGoForwardBlock != nil && block != nil) {
            _navigationCanGoForwardBlock = block
            return
        }

        _navigationCanGoForwardBlock = block
        if block != nil {
            addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: [], context: &_navigationCanGoForwardContext)
        } else {
            removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        }
    }

    /// Add an observer for the height of web content.
    ///
    /// - Parameters:
    ///   - block: Invoked when the height of web content has been changed.
    ///   - sizeFlexible: Determine whether or not the size of web view should be flexible to fit its content size. Defaults to false.
    public func webContentHeightDidChange(_ block: ((_ height: CGFloat) -> Void)? = { _ in }, sizeFlexible: Bool = false) {
        _webContentSizeFlexible = sizeFlexible

        if (_webContentHeightDidChangeBlock == nil && block == nil) || (_webContentHeightDidChangeBlock != nil && block != nil) {
            _webContentHeightDidChangeBlock = block
            return
        }

        _webContentHeightDidChangeBlock = block
        if block != nil {
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [], context: &_webContentHeightContext)
        } else {
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        }
    }

    /// Make web view scroll to the given offset of Y position.
    ///
    /// - Parameter offset: The offset of Y position.
    public func scrollTo(offset: CGFloat) {
        if isLoading {
            _scrollOffset = offset
        } else {
            _scrollTo(offset: offset)
        }
    }

    // MARK: - Web Loading

    /// Navigates to a requested URL.
    ///
    /// - Parameter urlString: A string of the URL to navigate to.
    /// - Returns: A new navigation for the given request.
    @discardableResult
    public func load(_ urlString: String) -> WKNavigation? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        return load(url)
    }

    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    /// - Returns: A new navigation for the given request.
    @discardableResult
    public func load(_ url: URL) -> WKNavigation? {
        return load(URLRequest(url: url))
    }

    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    /// - Returns: A new navigation for the given request.
    @discardableResult
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) -> WKNavigation? {
        guard let filePath = bundle.path(forResource: fileName, ofType: "html") else {
            return nil
        }

        guard let html = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8) else {
            return nil
        }

        return loadHTMLString(html, baseURL: bundle.resourceURL)
    }

    // MARK: - JavaScript

    /// Get the selected string from web page.
    ///
    /// - Parameter block: A block to invoke when pick up the selected string from html.
    public func getSelectedString(_ block: @escaping (String?) -> Void) {
        evaluateJavaScript("window.getSelection().toString();") { result, _ in
            if let string = result as? String, !string.isEmpty {
                block(string)
            } else {
                block(nil)
            }
        }
    }

    // MARK: - URL Request

    /// Add custom valid URL schemes for the web view navigation.
    ///
    /// - Parameter schemes: An array of URL scheme.
    public func addCustomValidSchemes(_ schemes: [String]) {
        if _customValidSchemes == nil {
            _customValidSchemes = Set<String>()
        }
        schemes.forEach { scheme in
            self._customValidSchemes!.insert(scheme.lowercased())
        }
    }

    /// The user agent of a web view.
    ///
    /// - Parameter block: A block with user agent string
    public func userAgent(_ block: @escaping (_ result: String?) -> Void) {
        evaluateJavaScript("navigator.userAgent") { result, _ in
            block(result as? String)
        }
    }

    // MARK: Private

    private var _copyURL: URL?
    private var _urlContext: Int = 0
    private var _provisionalNavigationFailed: Bool = false

    private var _cookiesShared: Bool = false

    private var _shouldPreviewElementBy3DTouch = false

    private var _shouldCloseByDOMWindow = false

    private var _pageTitleDidChangeBlock: ((_ title: String?) -> Void)?
    private var _pageTitleContext: Int = 0

    private var _navigationCanGoBackBlock: ((_ canGoBack: Bool) -> Void)?
    private var _navigationCanGoBackContext: Int = 0

    private var _navigationCanGoForwardBlock: ((_ canGoForward: Bool) -> Void)?
    private var _navigationCanGoForwardContext: Int = 0

    private var _webContentHeightDidChangeBlock: ((_ height: CGFloat) -> Void)?
    private var _webContentHeightContext: Int = 0
    private var _webContentHeightHeight: CGFloat = 0.0
    private var _webContentSizeFlexible: Bool = false

    private var _scrollOffset: CGFloat = -1.0
    private var _customValidSchemes: Set<String>?

    private func _scrollTo(offset: CGFloat) {
        if offset >= 0.0 {
            _scrollOffset = -1.0
            evaluateJavaScript("window.scrollTo(0, \(offset))")
        }
    }

    //    private var _authenticated = false
    //    private var _failedRequest: URLRequest?

    private func _externalAppRequiredToOpen(url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }

        let validSchemes: [String] = ["http", "https", "file"]
        if validSchemes.contains(scheme) {
            return false
        }

        if let customValidSchemes = _customValidSchemes,
            customValidSchemes.contains(scheme)
        {
            return false
        }

        return true
    }

    // TODO: Strings Localization
    private func _launchExternalApp(url: URL) {
        let systemSchemes: [String] = ["tel", "sms", "mailto"]
        if let scheme = url.scheme,
            systemSchemes.contains(scheme)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            let alertController = UIAlertController(title: "Leave current app?", message: "This web page is trying to open an outside app. Are you sure you want to open it?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title: "Open App", style: .default) { _ in
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
}

// MARK: - WKNavigationDelegate

extension DLWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webView(self, didStartLoading: webView.url)
    }

    // FIXME: Not be called if the web view bind with a javascript bridge.
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        _scrollTo(offset: _scrollOffset)

        delegate?.webView(self, didCommitLoading: webView.url)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        _scrollTo(offset: _scrollOffset)

        _provisionalNavigationFailed = false
        delegate?.webView(self, didFinishLoading: webView.url)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        _provisionalNavigationFailed = true
        delegate?.webView(self, didFailLoading: webView.url, error: error)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(self, didFailLoading: webView.url, error: error)
    }

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webView(self, didRedirectForLoading: webView.url)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if _externalAppRequiredToOpen(url: url),
            UIApplication.shared.canOpenURL(url)
        {
            _launchExternalApp(url: url)
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

        decisionHandler(delegate?.webView(self, decidePolicyFor: navigationAction) ?? .allow)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(delegate?.webView(self, decidePolicyFor: navigationResponse) ?? .allow)
    }

    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        reload() // WebContent Process Crash & self.titile will be nil when it crash, then reload the webview
    }

    // TODO: HTTPS request with self-signed certificate
}

// MARK: - WKUIDelegate

extension DLWebView: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let isMainFrame = navigationAction.targetFrame?.isMainFrame, isMainFrame else {
            guard let openNewWindow = delegate?.webView(self, shouldCreateNewWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures),
                openNewWindow
            else {
                load(navigationAction.request)
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

    @available(iOS 9.0, *)
    public func webViewDidClose(_ webView: WKWebView) {
        if !_shouldCloseByDOMWindow || !_isAvailable {
            return
        }

        if let closestViewController = dl_closestViewController {
            delegate?.webViewDidClose(self, webViewController: closestViewController)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if !shouldDisplayAlertPanelByJavaScript || !_isAvailable || (frame.request.url?.host != url?.host) {
            completionHandler()
            return
        }

        if let closestViewController = dl_closestViewController {
            delegate?.webView(self, webViewController: closestViewController, showAlertPanelWithMessage: message, completionHandler: completionHandler)
        } else {
            completionHandler()
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if !shouldDisplayAlertPanelByJavaScript || !_isAvailable || (frame.request.url?.host != url?.host) {
            completionHandler(false)
            return
        }

        if let closestViewController = dl_closestViewController {
            delegate?.webView(self, webViewController: closestViewController, showConfirmPanelWithMessage: message, completionHandler: completionHandler)
        } else {
            completionHandler(false)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if !shouldDisplayAlertPanelByJavaScript || !_isAvailable || (frame.request.url?.host != url?.host) {
            completionHandler(nil)
            return
        }

        if let closestViewController = dl_closestViewController {
            delegate?.webView(self, webViewController: closestViewController, showTextInputPanelWithPrompt: prompt, defaultText: defaultText, completionHandler: completionHandler)
        } else {
            completionHandler(nil)
        }
    }

    private var _isAvailable: Bool {
        return superview != nil && window != nil
    }
}

// MARK: - NSURLConnectionDataDelegate

// extension DLWebView: NSURLConnectionDataDelegate {
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
// }
