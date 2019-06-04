//
//  WebControllerProtocols.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2019/6/4.
//  Copyright (c) 2019 Daniel Lin. All rights reserved.
//

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

public protocol WebNavigationItemDelegate {
    
    /// Indicates whether the web close button should be displayed on the left (or leading) edge of the navigation bar.
    var navigationItemCanClose: Bool { get set }
    
    /// The image of `UIBarButtonItem` for the web close button displayed on the left (or leading) edge of the navigation bar.
    var navigationItemCloseImage: UIImage { get }
    
    /// The `UIBarButtonItem` for the web close button displayed on the left (or leading) edge of the navigation bar.
    var navigationItemCloseButton: UIBarButtonItem { get }
    
    /// Invoked when the state of web close button has been changed.
    ///
    /// - Parameter canClose: Indicates whether the web close button should be displayed.
    func navigationItemCloseDidChange(canClose: Bool)
    
    /// Indicates whether the web refresh button should be displayed on the right (or trailing) edge of the navigation bar.
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
        return UIBarButtonItem(image: self.navigationItemCloseImage, style: .plain, action: { (sender) in
            if let viewController = self as? UIViewController {
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
                        leftBarButtonItems.count > 0 {
                        viewController.navigationItem.leftBarButtonItems!.append(self.navigationItemCloseButton)
                    } else {
                        viewController.navigationItem.leftBarButtonItem = self.navigationItemCloseButton
                    }
                }
            } else {
                if let leftBarButtonItems = viewController.navigationItem.leftBarButtonItems,
                    leftBarButtonItems.count > 0 {
                    viewController.navigationItem.leftBarButtonItems!.removeLast()
                }
            }
        }
    }
    
    var navigationItemRefreshImage: UIImage {
        return UIImage(named: "wvn_btn_web_refresh", in: Bundle(for: DLWebView.self), compatibleWith: nil)!
    }
    
    var navigationItemRefreshButton: UIBarButtonItem {
        return UIBarButtonItem(image: self.navigationItemRefreshImage, style: .plain, action: { (sender) in
            if let viewController = self as? WebControllerAction {
                viewController.reload()
            }
        })
    }
    
    func navigationItemRefreshDidChange(canRefresh: Bool) {
        if let viewController = self as? UIViewController {
            if canRefresh {
                if let rightBarButtonItems = viewController.navigationItem.rightBarButtonItems,
                    rightBarButtonItems.count > 0 {
                    viewController.navigationItem.rightBarButtonItems!.append(self.navigationItemRefreshButton)
                } else {
                    viewController.navigationItem.rightBarButtonItem = self.navigationItemRefreshButton
                }
            } else {
                if let rightBarButtonItems = viewController.navigationItem.rightBarButtonItems,
                    rightBarButtonItems.count > 0 {
                    viewController.navigationItem.rightBarButtonItems!.removeLast()
                }
            }
        }
    }
}
