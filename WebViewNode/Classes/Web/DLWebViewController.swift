//
//  DLWebViewController.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/9/13.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import UIKit

/// A view controller with web view container.
open class DLWebViewController: UIViewController {
    
    /// The root view of web view controller
    public let webView: DLWebView
    
    /// The delegate of DLWebView.
    public weak var delegate: DLWebViewDelegate? {
        didSet {
            webView.webDelegate = delegate
        }
    }
    
    /// Determine whether or not the page title of web view should be shown on the navigation bar. Defaults to false.
    public var pageTitleNavigationShown = false {
        didSet {
            if oldValue != pageTitleNavigationShown {
                if pageTitleNavigationShown {
                    webView.pageTitleDidChange { [weak self] (title) in
                        guard let strongSelf = self else { return }
                        strongSelf.navigationItem.title = title
                    }
                } else {
                    webView.pageTitleDidChange(nil)
                }
            }
        }
    }
    
    /// Determine whether or not the loading progress of web view should be shown. Defaults to true.
    public var progressBarShown = true {
        didSet {
            webView.progressBarShown = progressBarShown
        }
    }
    
    /// The color shown for the portion of the web loading progress bar that is filled.
    public var progressTintColor: UIColor? {
        get {
            return webView.progressTintColor
        }
        set {
            webView.progressTintColor = newValue
        }
    }
    
    /// Determine whether or not the given element of web link should show a preview by 3D Touch. Defaults to false.
    @available(iOS 9.0, *)
    public var shouldPreviewElementBy3DTouch: Bool {
        get {
            return webView.shouldPreviewElementBy3DTouch
        }
        set {
            webView.shouldPreviewElementBy3DTouch = newValue
        }
    }
    
    /// Determine whether or not the app window should display an alert, confirm or text input view from JavaScript functions. Defaults to false.
    public var shouldDisplayAlertPanel = false {
        didSet {
            webView.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        }
    }
    
    private var _url: String?
    
    public init(url: String? = nil, configuration: DLWebViewConfiguration = DLWebViewConfiguration(), cookiesShared: Bool = false, userScalable: WebUserScalable = .default, contentFitStyle: WebContentFitStyle = .default, customUserAgent: String? = nil) {
        _url = url
        webView = DLWebView(configuration: configuration, cookiesShared: cookiesShared, userScalable: userScalable, contentFitStyle: contentFitStyle, customUserAgent: customUserAgent)
        webView.progressBarShown = progressBarShown
        webView.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    open override func loadView() {
        self.view = webView
        #if WebViewNode_JSBridge
        self.bindJSBridge()
        #endif
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if let url = _url {
            load(url)
        }
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Make web view scroll to the given offset of Y position.
    ///
    /// - Parameter offset: The offset of Y position.
    public func scrollTo(offset: CGFloat) {
        webView.scrollTo(offset: offset)
    }
    
}

// MARK: - Web Loading
extension DLWebViewController {
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter urlString: A string of the URL to navigate to.
    public func load(_ urlString: String) {
        webView.load(urlString)
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    public func load(_ url: URL) {
        webView.load(url)
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter request: The request specifying the URL to navigate to.
    public func load(_ request: URLRequest) {
        webView.load(request)
    }
    
    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        webView.loadHTML(fileName: fileName, bundle: bundle)
    }
    
    /// Reloads the current page.
    public func reload() {
        webView.reload()
    }
    
    /// Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
    public func reloadFromOrigin() {
        webView.reloadFromOrigin()
    }
    
    /// Stops loading all resources on the current page.
    public func stopLoading() {
        webView.stopLoading()
    }
}
