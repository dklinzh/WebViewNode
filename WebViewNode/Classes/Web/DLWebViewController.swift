//
//  DLWebViewController.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/9/13.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import UIKit

/// A view controller with web view container.
open class DLWebViewController: UIViewController, WebNavigationItemDelegate {
    
    /// The root view of web view controller.
    public let webView: DLWebView
    
    /// The delegate of DLWebView.
    public weak var delegate: DLWebViewDelegate? {
        didSet {
            webView.delegate = delegate
        }
    }
    
// MARK: - WebNavigationItemDelegate
    
    private var _canGoBack = false
    public var navigationItemCanClose: Bool = false {
        didSet {
            if oldValue != navigationItemCanClose {
                if navigationItemCanClose {
                    webView.navigationCanGoBack { [weak self] (canGoBack) in
                        guard let strongSelf = self else { return }
                        
                        if strongSelf._canGoBack != canGoBack {
                            strongSelf._canGoBack = canGoBack
                            strongSelf.navigationItemCloseDidChange(canClose: canGoBack)
                        }
                    }
                } else {
                    webView.navigationCanGoBack(nil)
                }
            }
        }
    }
    
    public var navigationItemCanRefresh: Bool = false {
        didSet {
            if oldValue != navigationItemCanRefresh {
                self.navigationItemRefreshDidChange(canRefresh: navigationItemCanRefresh)
            }
        }
    }
    
// MARK: - UI Appearance
    
    /// Determine whether or not the page title of web view should be shown on the navigation bar. Defaults to false.
    public var pageTitleNavigationShown: Bool = false {
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
    
    /// Determine whether the web view can go back by the default back button on the navigation bar. Defaults to true.
    public var canGoBackByNavigationBackButton: Bool = true
    
    /// Determine whether or not the loading progress of web view should be shown. Defaults to true.
    public var progressBarShown: Bool = true {
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
    public var shouldDisplayAlertPanel: Bool = false {
        didSet {
            webView.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        }
    }
    
    private let _url: String?
    
    /// A web view controller initialization.
    ///
    /// - Parameters:
    ///   - url: The initial URL of web view to load.
    ///   - configuration: A collection of properties used to initialize a web view.
    ///   - cookiesShared: Determine whether or not the initialized web view should be shared with cookies from the HTTP cookie storage. Defaults to false.
    ///   - userSelected: Determine whether or not the content of web page can be selected by user. Defaults to true.
    ///   - userScalable: Determine whether or not the frame of web view can be scaled by user. Defaults value is `default`.
    ///   - contentFitStyle: The style of viewport fit with web content. Default value is `default`.
    ///   - customUserAgent: The custom `User-Agent` of web view. Defaults to nil.
    public init(url: String? = nil,
                configuration: DLWebViewConfiguration = DLWebViewConfiguration(),
                cookiesShared: Bool = false,
                userSelected: Bool = true,
                userScalable: WebUserScalable = .default,
                contentFitStyle: WebContentFitStyle = .default,
                customUserAgent: String? = nil) {
        _url = url
        webView = DLWebView(configuration: configuration,
                            cookiesShared: cookiesShared,
                            userSelected: userSelected,
                            userScalable: userScalable,
                            contentFitStyle: contentFitStyle,
                            customUserAgent: customUserAgent)
        webView.progressBarShown = progressBarShown
        webView.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        _url = nil
        webView = DLWebView(configuration: DLWebViewConfiguration(),
                            cookiesShared: false,
                            userSelected: true,
                            userScalable: .default,
                            contentFitStyle: .default,
                            customUserAgent: nil)
        webView.progressBarShown = progressBarShown
        webView.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        
        super.init(coder: aDecoder)
    }
    
    open override func loadView() {
        self.view = webView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftItemsSupplementBackButton = canGoBackByNavigationBackButton
        
        #if WebViewNode_JSBridge
        self.bindJSBridge()
        #endif

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

// MARK: - DLNavigationControllerDelegate
extension DLWebViewController: DLNavigationControllerDelegate {
    
    public func navigationConroller(_ navigationConroller: UINavigationController, shouldPop item: UINavigationItem) -> Bool {
        if canGoBackByNavigationBackButton,
            webView.canGoBack {
            webView.goBack()
            return false
        } else {
            return true
        }
    }
}

// MARK: - WebControllerAction
extension DLWebViewController: WebControllerAction {
    
    public func goBack() {
        webView.goBack()
    }
    
    public func goForward() {
        webView.goForward()
    }
    
    public func load(_ urlString: String) {
        webView.load(urlString)
    }
    
    public func load(_ url: URL) {
        webView.load(url)
    }
    
    public func load(_ request: URLRequest) {
        webView.load(request)
    }
    
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        webView.loadHTML(fileName: fileName, bundle: bundle)
    }
    
    public func reload() {
        webView.reload()
    }
    
    public func reloadFromOrigin() {
        webView.reloadFromOrigin()
    }
    
    public func stopLoading() {
        webView.stopLoading()
    }
}
