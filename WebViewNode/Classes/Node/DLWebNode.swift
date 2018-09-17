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

    /// The delegate of DLWebView.
    public weak var delegate: DLWebViewDelegate? {
        get {
            return self.nodeView.delegate
        }
        set {
            self.nodeView.delegate = newValue
        }
    }
    
    /// Determine whether or not the loading progress view should be shown. Defaults to false.
    public var progressBarShown: Bool {
        get {
            return self.nodeView.progressBarShown
        }
        set {
            self.appendViewAssociation { (view) in
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
            self.appendViewAssociation { (view) in
                view.progressTintColor = newValue
            }
        }
    }
    
    /// A dictionary of the custom HTTP header fields for URL request.
    public var customHTTPHeaderFields: [String : String]? {
        get {
            return self.nodeView.customHTTPHeaderFields
        }
        set {
            self.appendViewAssociation { (view) in
                view.customHTTPHeaderFields = newValue
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
            self.appendViewAssociation { (view) in
                view.shouldPreviewElementBy3DTouch = newValue
            }
        }
    }
    
    /// Determine whether or not the app window should display an alert, confirm or text input view from JavaScript functions. Defaults to true.
    public var shouldDisplayAlertPanelByJavaScript: Bool {
        get {
            return self.nodeView.shouldDisplayAlertPanelByJavaScript
        }
        set {
            self.appendViewAssociation { (view) in
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
            self.appendViewAssociation { (view) in
                view.shouldCloseByDOMWindow = newValue
            }
        }
    }
    
    /// A floating-point value that determines the rate of deceleration after the user lifts their finger on the scroll view of web node. You can use the UIScrollViewDecelerationRateNormal or UIScrollViewDecelerationRateFast constants as reference points for reasonable deceleration rates. Defaults to UIScrollViewDecelerationRateNormal.
    public var scrollDecelerationRate: CGFloat {
        get {
            return self.nodeView.scrollDecelerationRate
        }
        set {
            self.appendViewAssociation { (view) in
                view.scrollDecelerationRate = newValue
            }
        }
    }
    
    /// A web node initialization.
    ///
    /// - Parameters:
    ///   - configuration: A collection of properties used to initialize a web view.
    ///   - cookiesShared: Determine whether or not the initialized web view should be shared with cookies from the HTTP cookie storage. Defaults to false.
    ///   - userScalable: Determine whether or not the frame of web view can be scaled by user. Defaults value is `default`.
    ///   - contentFitStyle: The style of viewport fit with web content. Default value is `default`.
    ///   - customUserAgent: The custom user agent string of web view. Defaults to nil.
    public init(configuration: DLWebViewConfiguration = DLWebViewConfiguration(), cookiesShared: Bool = false, userScalable: WebUserScalable = .default, contentFitStyle: WebContentFitStyle = .default, customUserAgent: String? = nil) {
        super.init()
        
        self.setViewBlock { () -> UIView in
            let webView = DLWebView(configuration: configuration, cookiesShared: cookiesShared, userScalable: userScalable, contentFitStyle: contentFitStyle, customUserAgent: customUserAgent)
            return webView
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
        self.appendViewAssociation { (view) in
            view.load(urlString)
        }
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    public func load(_ url: URL) {
        self.appendViewAssociation { (view) in
            view.load(url)
        }
    }
    
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter request: The request specifying the URL to navigate to.
    public func load(_ request: URLRequest) {
        self.appendViewAssociation { (view) in
            view.load(request)
        }
    }
    
    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        self.appendViewAssociation { (view) in
            view.loadHTML(fileName: fileName, bundle: bundle)
        }
    }
    
    /// Reloads the current page.
    public func reload() {
        self.appendViewAssociation { (view) in
            view.reload()
        }
    }
    
    /// Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
    public func reloadFromOrigin() {
        self.appendViewAssociation { (view) in
            view.reloadFromOrigin()
        }
    }
    
    /// Stops loading all resources on the current page.
    public func stopLoading() {
        self.appendViewAssociation { (view) in
            view.stopLoading()
        }
    }
    
    /// Evaluates a JavaScript string.
    ///
    /// - Parameters:
    ///   - javaScriptString: The JavaScript string to evaluate.
    ///   - completionHandler: A block to invoke when script evaluation completes or fails.
    public func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        self.appendViewAssociation { (view) in
            view.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
        }
    }
    
    /// Add custom valid URL schemes for the web view navigation.
    ///
    /// - Parameter schemes: An array of URL scheme.
    public func addCustomValidSchemes(_ schemes: [String]) {
        self.appendViewAssociation { (view) in
            view.addCustomValidSchemes(schemes)
        }
    }
    
    /// The user agent of a web view.
    ///
    /// - Parameter block: A block with user agent string
    public func userAgent(_ block: @escaping (_ result: String?) -> Void) {
        self.appendViewAssociation { (view) in
            view.userAgent(block)
        }
    }
    
    /// Add an observer for the page title of web view
    ///
    /// - Parameter block: Invoked when the page title has been changed.
    public func pageTitleDidChange(_ block: ((_ title: String?) -> Void)?) {
        self.appendViewAssociation { (view) in
            view.pageTitleDidChange(block)
        }
    }
    
    /// Add an observer for the height of web content.
    ///
    /// - Parameters:
    ///   - block: Invoked when the height of web content has been changed.
    ///   - sizeFlexible: Determine whether or not the size of web view should be flexible to fit its content size. Defaults to false.
    public func webContentHeightDidChange(_ block: ((_ height: CGFloat) -> Void)? = { (height) in }, sizeFlexible: Bool = false) {
        self.appendViewAssociation { (view) in
            view.webContentHeightDidChange(block, sizeFlexible: sizeFlexible)
        }
    }
}
