//
//  DLWebNode.swift
//  WebViewNode
//
//  Created by Linzh on 9/15/18.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import AsyncDisplayKit

/// A web container of ASDisplayNode.
open class DLWebNode: DLViewNode<DLWebView> {
    /// The delegate of DLViewNode.
    public weak var delegate: DLWebNodeDelegate? {
        didSet {
            if self.delegate == nil {
                self.appendViewAssociation { view in
                    view.delegate = nil
                }
            } else {
                self.appendViewAssociation { [weak self] view in
                    view.delegate = self
                }
            }
        }
    }
    
    /// A web node initialization.
    ///
    /// - Parameters:
    ///   - configuration: A collection of properties used to initialize a web node.
    ///   - cookiesShared: Determine whether or not the initialized web node should be shared with cookies from the HTTP cookie storage. Defaults to false.
    ///   - userSelected: Determine whether or not the content of web page can be selected by user. Defaults to true.
    ///   - userScalable: Determine whether or not the frame of web node can be scaled by user. Defaults value is `default`.
    ///   - contentFitStyle: The style of viewport fit with web content. Default value is `default`.
    ///   - customUserAgent: The custom user agent string of web node. Defaults to nil.
    public init(configuration: DLWebNodeConfiguration = DLWebNodeConfiguration(),
                cookiesShared: Bool = false,
                userSelected: Bool = true,
                userScalable: WebUserScalable = .default,
                contentFitStyle: WebContentFitStyle = .default,
                customUserAgent: String? = nil) {
        super.init()
        
        self.setViewBlock { () -> UIView in
            let webView = DLWebView(configuration: configuration,
                                    cookiesShared: cookiesShared,
                                    userSelected: userSelected,
                                    userScalable: userScalable,
                                    contentFitStyle: contentFitStyle,
                                    customUserAgent: customUserAgent)
            return webView
        }
    }
    
    deinit {}
    
    // MARK: - UI Appearance
    
    /// Determine whether or not the loading progress view should be shown. Defaults to false.
    public var progressBarShown: Bool {
        get {
            return self.nodeView.progressBarShown
        }
        set {
            self.appendViewAssociation { view in
                view.progressBarShown = newValue
            }
        }
    }
    
    /// The color shown for the portion of the web loading progress bar that is filled.
    public var progressTintColor: UIColor? {
        get {
            return self.nodeView.progressTintColor
        }
        set {
            self.appendViewAssociation { view in
                view.progressTintColor = newValue
            }
        }
    }
    
    /// Add an observer for the page title of web node
    ///
    /// - Parameter block: Invoked when the page title has been changed.
    public func pageTitleDidChange(_ block: ((_ title: String?) -> Void)?) {
        self.appendViewAssociation { view in
            view.pageTitleDidChange(block)
        }
    }
    
    /// Add an observer to indicate whether there is a back item in the back-forward list that can be navigated to.
    ///
    /// - Parameter block: Invoked when the value of key `canGoBack` has been changed.
    public func navigationCanGoBack(_ block: ((_ canGoBack: Bool) -> Void)?) {
        self.appendViewAssociation { view in
            view.navigationCanGoBack(block)
        }
    }
    
    /// Add an observer to indicate whether there is a forward item in the back-forward list that can be navigated to.
    ///
    /// - Parameter block: Invoked when the value of key `canGoForward` has been changed.
    public func navigationCanGoForward(_ block: ((_ canGoForward: Bool) -> Void)?) {
        self.appendViewAssociation { view in
            view.navigationCanGoForward(block)
        }
    }
    
    /// Add an observer for the height of web content.
    ///
    /// - Parameters:
    ///   - block: Invoked when the height of web content has been changed.
    ///   - sizeFlexible: Determine whether or not the size of web node should be flexible to fit its content size. Defaults to false.
    public func webContentHeightDidChange(_ block: ((_ height: CGFloat) -> Void)? = { _ in }, sizeFlexible: Bool = false) {
        self.appendViewAssociation { view in
            view.webContentHeightDidChange(block, sizeFlexible: sizeFlexible)
        }
    }
    
    /// Make web node scroll to the given offset of Y position.
    ///
    /// - Parameter offset: The offset of Y position.
    public func scrollTo(offset: CGFloat) {
        self.appendViewAssociation { view in
            view.scrollTo(offset: offset)
        }
    }
    
    /// A floating-point value that determines the rate of deceleration after the user lifts their finger. Use the normal and fast constants as reference points for reasonable deceleration rates. Defaults to normal.
    public var scrollDecelerationRate: UIScrollView.DecelerationRate {
        get {
            return self.nodeView.scrollDecelerationRate
        }
        set {
            self.appendViewAssociation { view in
                view.scrollDecelerationRate = newValue
            }
        }
    }
    
    /// Determine whether or not the given element of web link should show a preview by 3D Touch. Defaults to false.
    @available(iOS 9.0, *)
    public var shouldPreviewElementBy3DTouch: Bool {
        get {
            return self.nodeView.shouldPreviewElementBy3DTouch
        }
        set {
            self.appendViewAssociation { view in
                view.shouldPreviewElementBy3DTouch = newValue
            }
        }
    }
    
    // MARK: - Web Loading
    
    /// A Boolean value indicating whether there is a back item in the back-forward list that can be navigated to.
    public var canGoBack: Bool {
        return self.nodeView.canGoBack
    }
    
    /// Navigates to the back item in the back-forward list.
    public func goBack() {
        self.appendViewAssociation { view in
            view.goBack()
        }
    }
    
    /// A Boolean value indicating whether there is a forward item in the back-forward list that can be navigated to.
    public var canGoForward: Bool {
        return self.nodeView.canGoForward
    }
    
    /// Navigates to the forward item in the back-forward list.
    public func goForward() {
        self.appendViewAssociation { view in
            view.goForward()
        }
    }
    
    /// A Boolean value indicating whether the web is currently loading content.
    public var isLoading: Bool {
        return self.nodeView.isLoading
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter urlString: A string of the URL to navigate to.
    public func load(_ urlString: String) {
        self.appendViewAssociation { view in
            view.load(urlString)
        }
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    public func load(_ url: URL) {
        self.appendViewAssociation { view in
            view.load(url)
        }
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter request: The request specifying the URL to navigate to.
    public func load(_ request: URLRequest) {
        self.appendViewAssociation { view in
            view.load(request)
        }
    }
    
    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        self.appendViewAssociation { view in
            view.loadHTML(fileName: fileName, bundle: bundle)
        }
    }
    
    /// Reloads the current page.
    public func reload() {
        self.appendViewAssociation { view in
            view.reload()
        }
    }
    
    /// Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
    public func reloadFromOrigin() {
        self.appendViewAssociation { view in
            view.reloadFromOrigin()
        }
    }
    
    /// Stops loading all resources on the current page.
    public func stopLoading() {
        self.appendViewAssociation { view in
            view.stopLoading()
        }
    }
    
    // MARK: - JavaScript
    
    /// Evaluates a JavaScript string.
    ///
    /// - Parameters:
    ///   - javaScriptString: The JavaScript string to evaluate.
    ///   - completionHandler: A block to invoke when script evaluation completes or fails.
    public func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        self.appendViewAssociation { view in
            view.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
        }
    }
    
    /// Determine whether or not the app window should display an alert, confirm or text input view from JavaScript functions. Defaults to true.
    public var shouldDisplayAlertPanelByJavaScript: Bool {
        get {
            return self.nodeView.shouldDisplayAlertPanelByJavaScript
        }
        set {
            self.appendViewAssociation { view in
                view.shouldDisplayAlertPanelByJavaScript = newValue
            }
        }
    }
    
    /// Determine whether or not the web node controller should be closed by DOM window.close(). Defaults to false.
    @available(iOS 9.0, *)
    public var shouldCloseByDOMWindow: Bool {
        get {
            return self.nodeView.shouldCloseByDOMWindow
        }
        set {
            self.appendViewAssociation { view in
                view.shouldCloseByDOMWindow = newValue
            }
        }
    }
    
    // MARK: - URL Request
    
    /// A dictionary of the custom HTTP header fields for URL request.
    public var customHTTPHeaderFields: [String: String]? {
        get {
            return self.nodeView.customHTTPHeaderFields
        }
        set {
            self.appendViewAssociation { view in
                view.customHTTPHeaderFields = newValue
            }
        }
    }
    
    /// Add custom valid URL schemes for the web node navigation.
    ///
    /// - Parameter schemes: An array of URL scheme.
    public func addCustomValidSchemes(_ schemes: [String]) {
        self.appendViewAssociation { view in
            view.addCustomValidSchemes(schemes)
        }
    }
    
    /// The user agent of a web node.
    ///
    /// - Parameter block: A block with user agent string
    public func userAgent(_ block: @escaping (_ result: String?) -> Void) {
        self.appendViewAssociation { view in
            view.userAgent(block)
        }
    }
}

// MARK: - DLWebViewDelegate

extension DLWebNode: DLWebViewDelegate {
    public func webView(_ webView: DLWebView, didStartLoading url: URL?) {
        self.delegate?.webNode(self, didStartLoading: url)
    }
    
    public func webView(_ webView: DLWebView, didCommitLoading url: URL?) {
        self.delegate?.webNode(self, didCommitLoading: url)
    }
    
    public func webView(_ webView: DLWebView, didFinishLoading url: URL?) {
        self.delegate?.webNode(self, didFinishLoading: url)
    }
    
    public func webView(_ webView: DLWebView, didFailLoading url: URL?, error: Error?) {
        self.delegate?.webNode(self, didFailLoading: url, error: error)
    }
    
    public func webView(_ webView: DLWebView, didRedirectForLoading url: URL?) {
        self.delegate?.webNode(self, didRedirectForLoading: url)
    }
    
    public func webView(_ webView: DLWebView, decidePolicyFor navigationAction: DLNavigationAction) -> DLNavigationActionPolicy {
        return self.delegate?.webNode(self, decidePolicyFor: navigationAction) ?? .allow
    }
    
    public func webView(_ webView: DLWebView, decidePolicyFor navigationResponse: DLNavigationResponse) -> DLNavigationResponsePolicy {
        return self.delegate?.webNode(self, decidePolicyFor: navigationResponse) ?? .allow
    }
    
    public func webView(_ webView: DLWebView, shouldCreateNewWebViewWith configuration: DLWebViewConfiguration, for navigationAction: DLNavigationAction, windowFeatures: DLWindowFeatures) -> Bool {
        return self.delegate?.webNode(self, shouldCreateNewWebNodeWith: configuration, for: navigationAction, windowFeatures: windowFeatures) ?? false
    }
    
    public func webViewDidClose(_ webView: DLWebView, webViewController: UIViewController) {
        self.delegate?.webNodeDidClose(self, webNodeController: webViewController)
    }
    
    public func webView(_ webView: DLWebView, webViewController: UIViewController, showAlertPanelWithMessage message: String, completionHandler: @escaping () -> Swift.Void) {
        self.delegate?.webNode(self, webNodeController: webViewController, showAlertPanelWithMessage: message, completionHandler: completionHandler)
    }
    
    public func webView(_ webView: DLWebView, webViewController: UIViewController, showConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Swift.Void) {
        self.delegate?.webNode(self, webNodeController: webViewController, showConfirmPanelWithMessage: message, completionHandler: completionHandler)
    }
    
    public func webView(_ webView: DLWebView, webViewController: UIViewController, showTextInputPanelWithPrompt prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Swift.Void) {
        self.delegate?.webNode(self, webNodeController: webViewController, showTextInputPanelWithPrompt: prompt, defaultText: defaultText, completionHandler: completionHandler)
    }
}
