//
//  DLWebNodeController.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2019/5/7.
//  Copyright (c) 2019 Daniel Lin. All rights reserved.
//

import AsyncDisplayKit

/// A view controller with web node container.
open class DLWebNodeController: ASViewController<DLWebNode>, WebNavigationItemDelegate {
    
    /// The root node of web node controller.
    public let webNode: DLWebNode
    
    /// The delegate of DLWebNode.
    public weak var delegate: DLWebNodeDelegate? {
        didSet {
            webNode.delegate = delegate
        }
    }
    
// MARK: - UI Appearance
    
    /// Determine whether or not the page title of web view should be shown on the navigation bar. Defaults to false.
    public var pageTitleNavigationShown: Bool = false {
        didSet {
            if oldValue != pageTitleNavigationShown {
                if pageTitleNavigationShown {
                    webNode.pageTitleDidChange { [weak self] (title) in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.navigationItem.title = title
                    }
                } else {
                    webNode.pageTitleDidChange(nil)
                }
            }
        }
    }
    
    /// Determine whether the web view can go back by the default back button on the navigation bar. Defaults to true.
    public var canGoBackByNavigationBackButton: Bool = true
    
    private var _canGoBack = false
    public var navigationItemCanClose: Bool = false {
        didSet {
            if oldValue != navigationItemCanClose {
                if navigationItemCanClose {
                    webNode.navigationCanGoBack { [weak self] (canGoBack) in
                        guard let strongSelf = self else { return }
                        
                        if strongSelf._canGoBack != canGoBack {
                            strongSelf._canGoBack = canGoBack
                            strongSelf.navigationItemCloseDidChange(canClose: canGoBack)
                        }
                    }
                } else {
                    webNode.navigationCanGoBack(nil)
                }
            }
        }
    }
    
    /// Determine whether or not the loading progress of web view should be shown. Defaults to true.
    public var progressBarShown: Bool = true {
        didSet {
            webNode.progressBarShown = progressBarShown
        }
    }
    
    /// The color shown for the portion of the web loading progress bar that is filled.
    public var progressTintColor: UIColor? {
        get {
            return webNode.progressTintColor
        }
        set {
            webNode.progressTintColor = newValue
        }
    }
    
    /// Determine whether or not the given element of web link should show a preview by 3D Touch. Defaults to false.
    @available(iOS 9.0, *)
    public var shouldPreviewElementBy3DTouch: Bool {
        get {
            return webNode.shouldPreviewElementBy3DTouch
        }
        set {
            webNode.shouldPreviewElementBy3DTouch = newValue
        }
    }
    
    /// Determine whether or not the app window should display an alert, confirm or text input view from JavaScript functions. Defaults to false.
    public var shouldDisplayAlertPanel: Bool = false {
        didSet {
            webNode.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        }
    }
    
    private let _url: String?
    
    /// A web node controller initialization.
    ///
    /// - Parameters:
    ///   - url: The initial URL of web node to load.
    ///   - configuration: A collection of properties used to initialize a web node.
    ///   - cookiesShared: Determine whether or not the initialized web node should be shared with cookies from the HTTP cookie storage. Defaults to false.
    ///   - userSelected: Determine whether or not the content of web page can be selected by user. Defaults to true.
    ///   - userScalable: Determine whether or not the frame of web view can be scaled by user. Defaults value is `default`.
    ///   - contentFitStyle: The style of viewport fit with web content. Default value is `default`.
    ///   - customUserAgent: The custom `User-Agent` of web node. Defaults to nil.
    public init(url: String? = nil,
                configuration: DLWebNodeConfiguration = DLWebNodeConfiguration(),
                cookiesShared: Bool = false,
                userSelected: Bool = true,
                userScalable: WebUserScalable = .default,
                contentFitStyle: WebContentFitStyle = .default,
                customUserAgent: String? = nil) {
        _url = url
        webNode = DLWebNode(configuration: configuration,
                            cookiesShared: cookiesShared,
                            userSelected: userSelected,
                            userScalable: userScalable,
                            contentFitStyle: contentFitStyle,
                            customUserAgent: customUserAgent)
        webNode.progressBarShown = progressBarShown
        webNode.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        
        super.init(node: webNode)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        _url = nil
        webNode = DLWebNode(configuration: DLWebNodeConfiguration(),
                            cookiesShared: false,
                            userSelected: true,
                            userScalable: .default,
                            contentFitStyle: .default,
                            customUserAgent: nil)
        webNode.progressBarShown = progressBarShown
        webNode.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        
        super.init(coder: aDecoder)
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
        webNode.scrollTo(offset: offset)
    }
}

// MARK: - DLNavigationControllerDelegate
extension DLWebNodeController: DLNavigationControllerDelegate {
    
    public func navigationConroller(_ navigationConroller: UINavigationController, shouldPop item: UINavigationItem) -> Bool {
        if canGoBackByNavigationBackButton,
            webNode.nodeView.canGoBack {
            webNode.nodeView.goBack()
            return false
        } else {
            return true
        }
    }
}

// MARK: - Web Loading
extension DLWebNodeController {
    
    /// Navigates to the back item in the back-forward list.
    public func goBack() {
        webNode.goBack()
    }
    
    /// Navigates to the forward item in the back-forward list.
    public func goForward() {
        webNode.goForward()
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter urlString: A string of the URL to navigate to.
    public func load(_ urlString: String) {
        webNode.load(urlString)
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    public func load(_ url: URL) {
        webNode.load(url)
    }
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter request: The request specifying the URL to navigate to.
    public func load(_ request: URLRequest) {
        webNode.load(request)
    }
    
    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        webNode.loadHTML(fileName: fileName, bundle: bundle)
    }
    
    /// Reloads the current page.
    public func reload() {
        webNode.reload()
    }
    
    /// Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
    public func reloadFromOrigin() {
        webNode.reloadFromOrigin()
    }
    
    /// Stops loading all resources on the current page.
    public func stopLoading() {
        webNode.stopLoading()
    }
}
