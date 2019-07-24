//
//  WebControllerProtocols.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2019/6/4.
//  Copyright (c) 2019 Daniel Lin. All rights reserved.
//

public protocol WebControllerAppearance {
    /// Determine whether the page title of web view should be shown on the navigation bar. Defaults to false.
    var pageTitleNavigationShown: Bool { get set }
    
    /// Determine whether the web view can go back by the default back button on the navigation bar. Defaults to true.
    var canGoBackByNavigationBackButton: Bool { get set }
    
    /// Determine whether the loading progress of web view should be shown. Defaults to true.
    var progressBarShown: Bool { get set }
    
    /// The color shown for the portion of the web loading progress bar that is filled.
    var progressTintColor: UIColor? { get set }
    
    /// Determine whether or not the app window should display an alert, confirm or text input view from JavaScript functions. Defaults to false.
    var shouldDisplayAlertPanel: Bool { get set }
    
    /// Determine whether or not the given element of web link should show a preview by 3D Touch. Defaults to false.
    @available(iOS 9.0, *)
    var shouldPreviewElementBy3DTouch: Bool { get set }
    
    /// Make web view scroll to the given offset of Y position.
    ///
    /// - Parameter offset: The offset of Y position.
    func scrollTo(offset: CGFloat)
    
    /// Setup the appearance of web view controller
    func setupAppearance()
}

public protocol WebControllerAction {
    /// Navigates to the back item in the back-forward list.
    func goBack()
    
    /// Navigates to the forward item in the back-forward list.
    func goForward()
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter urlString: A string of the URL to navigate to.
    func load(_ urlString: String)
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter url: The URL to navigate to.
    func load(_ url: URL)
    
    /// Navigates to a requested URL.
    ///
    /// - Parameter request: The request specifying the URL to navigate to.
    func load(_ request: URLRequest)
    
    /// Load local HTML file in the specifed bundle
    ///
    /// - Parameters:
    ///   - fileName: The name of HTML file.
    ///   - bundle: The specified bundle contains the HTML file. Defaults to main bundle.
    func loadHTML(fileName: String, bundle: Bundle)
    
    /// Reloads the current page.
    func reload()
    
    /// Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
    func reloadFromOrigin()
    
    /// Stops loading all resources on the current page.
    func stopLoading()
}

public protocol WebNavigationItemDelegate: class {
    /// Indicates whether the web close button should be displayed on the left (or leading) edge of the navigation bar. Defaults to false.
    var navigationItemCanClose: Bool { get set }
    
    /// The image of `UIBarButtonItem` for the web close button displayed on the left (or leading) edge of the navigation bar.
    var navigationItemCloseImage: UIImage { get }
    
    /// The `UIBarButtonItem` for the web close button displayed on the left (or leading) edge of the navigation bar.
    var navigationItemCloseButton: UIBarButtonItem { get }
    
    /// Invoked when the state of web close button has been changed.
    ///
    /// - Parameter canClose: Indicates whether the web close button should be displayed.
    func navigationItemCloseDidChange(canClose: Bool)
    
    /// Indicates whether the web refresh button should be displayed on the right (or trailing) edge of the navigation bar. Defaults to false.
    var navigationItemCanRefresh: Bool { get set }
    
    /// The image of `UIBarButtonItem` for the web refresh button displayed on the right (or trailing) edge of the navigation bar.
    var navigationItemRefreshImage: UIImage { get }
    
    /// The `UIBarButtonItem` for the web refresh button displayed on the right (or trailing) edge of the navigation bar.
    var navigationItemRefreshButton: UIBarButtonItem { get }
    
    /// Invoked when the state of web refresh button has been changed.
    ///
    /// - Parameter canRefresh: Indicates whether the web refresh button should be displayed.
    func navigationItemRefreshDidChange(canRefresh: Bool)
}

public extension WebNavigationItemDelegate {
    var navigationItemCloseImage: UIImage {
        return UIImage(named: "wvn_btn_web_close", in: Bundle(for: DLWebView.self), compatibleWith: nil)!
    }
    
    var navigationItemCloseButton: UIBarButtonItem {
        return UIBarButtonItem(image: self.navigationItemCloseImage, style: .plain, action: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if let viewController = strongSelf as? UIViewController {
                viewController.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func navigationItemCloseDidChange(canClose: Bool) {
        if let viewController = self as? UIViewController {
            if canClose {
                if let navigationController = viewController.navigationController,
                    navigationController.viewControllers.count > 1 {
                    if let leftBarButtonItems = viewController.navigationItem.leftBarButtonItems,
                        !leftBarButtonItems.isEmpty {
                        viewController.navigationItem.leftBarButtonItems!.append(self.navigationItemCloseButton)
                    } else {
                        viewController.navigationItem.leftBarButtonItem = self.navigationItemCloseButton
                    }
                }
            } else {
                if let leftBarButtonItems = viewController.navigationItem.leftBarButtonItems,
                    !leftBarButtonItems.isEmpty {
                    viewController.navigationItem.leftBarButtonItems!.removeLast()
                }
            }
        }
    }
    
    var navigationItemRefreshImage: UIImage {
        return UIImage(named: "wvn_btn_web_refresh", in: Bundle(for: DLWebView.self), compatibleWith: nil)!
    }
    
    var navigationItemRefreshButton: UIBarButtonItem {
        return UIBarButtonItem(image: self.navigationItemRefreshImage, style: .plain, action: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if let viewController = strongSelf as? WebControllerAction {
                viewController.reload()
            }
        })
    }
    
    func navigationItemRefreshDidChange(canRefresh: Bool) {
        if let viewController = self as? UIViewController {
            if canRefresh {
                if let rightBarButtonItems = viewController.navigationItem.rightBarButtonItems,
                    !rightBarButtonItems.isEmpty {
                    viewController.navigationItem.rightBarButtonItems!.append(self.navigationItemRefreshButton)
                } else {
                    viewController.navigationItem.rightBarButtonItem = self.navigationItemRefreshButton
                }
            } else {
                if let rightBarButtonItems = viewController.navigationItem.rightBarButtonItems,
                    !rightBarButtonItems.isEmpty {
                    viewController.navigationItem.rightBarButtonItems!.removeLast()
                }
            }
        }
    }
}
