//
//  DLWebNodeController.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2019/5/7.
//  Copyright (c) 2019 Daniel Lin. All rights reserved.
//

import AsyncDisplayKit

/// A view controller with web node container.
open class DLWebNodeController: ASViewController<DLWebNode>, WebControllerAppearance, WebNavigationItemDelegate {
    
// MARK: - WebNavigationItemDelegate
    
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
    
    public var navigationItemCanRefresh: Bool = false {
        didSet {
            if oldValue != navigationItemCanRefresh {
                self.navigationItemRefreshDidChange(canRefresh: navigationItemCanRefresh)
            }
        }
    }
    
// MARK: - WebControllerAppearance
    
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
    
    public var canGoBackByNavigationBackButton: Bool = true
    
    public var progressBarShown: Bool = true {
        didSet {
            webNode.progressBarShown = progressBarShown
        }
    }
    
    public var progressTintColor: UIColor? {
        get {
            return webNode.progressTintColor
        }
        set {
            webNode.progressTintColor = newValue
        }
    }
    
    public var shouldDisplayAlertPanel: Bool = false {
        didSet {
            webNode.shouldDisplayAlertPanelByJavaScript = shouldDisplayAlertPanel
        }
    }
    
    @available(iOS 9.0, *)
    public var shouldPreviewElementBy3DTouch: Bool {
        get {
            return webNode.shouldPreviewElementBy3DTouch
        }
        set {
            webNode.shouldPreviewElementBy3DTouch = newValue
        }
    }
    
    public func scrollTo(offset: CGFloat) {
        webNode.scrollTo(offset: offset)
    }
    
    open func setupAppearance() {}
    
// MARK: - Init
    
    /// The root node of web node controller.
    public let webNode: DLWebNode
    
    /// The delegate of DLWebNode.
    public weak var delegate: DLWebNodeDelegate? {
        didSet {
            webNode.delegate = delegate
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
        self.setupAppearance()
        
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

// MARK: - WebControllerAction
extension DLWebNodeController: WebControllerAction {
    
    public func goBack() {
        webNode.goBack()
    }
    
    public func goForward() {
        webNode.goForward()
    }
    
    public func load(_ urlString: String) {
        webNode.load(urlString)
    }
    
    public func load(_ url: URL) {
        webNode.load(url)
    }
    
    public func load(_ request: URLRequest) {
        webNode.load(request)
    }
    
    public func loadHTML(fileName: String, bundle: Bundle = Bundle.main) {
        webNode.loadHTML(fileName: fileName, bundle: bundle)
    }
    
    public func reload() {
        webNode.reload()
    }
    
    public func reloadFromOrigin() {
        webNode.reloadFromOrigin()
    }
    
    public func stopLoading() {
        webNode.stopLoading()
    }
}
