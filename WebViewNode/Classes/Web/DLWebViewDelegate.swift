//
//  DLWebViewDelegate.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/6/20.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

import WebKit

public protocol DLWebViewDelegate: class {
    
    /// Invoked when URL request of the main frame navigation starts loading.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - url: The active URL of web view
    func webView(_ webView: DLWebView, didStartLoading url: URL?)
    
    /// Invoked when URL request of the main frame navigation completes.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - url: The active URL of web view
    func webView(_ webView: DLWebView, didFinishLoading url: URL?)
    
    /// Invoked when an error occurs while loading data for the main frame.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - url: The active URL of web view
    ///   - error: The error that occurred.
    func webView(_ webView: DLWebView, didFailToLoad url: URL?, error: Error?)
    
    /// Decides whether to allow or cancel a navigation while starting to load.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - navigationAction: Descriptive information about the action triggering the navigation request.
    /// - Returns: The policy to pass back to the decision handler from the webView(_:decidePolicyFor:decisionHandler:) method. Defaults to .allow
    func webView(_ webView: DLWebView, decidePolicyFor navigationAction: WKNavigationAction) -> WKNavigationActionPolicy
    
    /// Decides whether to allow or cancel a navigation after its response is known.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - navigationResponse: Descriptive information about the navigation response.
    /// - Returns: The policy to pass back to the decision handler from the webView(_:decidePolicyFor:decisionHandler:) method. Defaults to .allow
    func webView(_ webView: DLWebView, decidePolicyFor navigationResponse: WKNavigationResponse) -> WKNavigationResponsePolicy
    
    /// Decides whether a new web view should be created as a subframe of the website.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - configuration: The configuration to use when creating the new web view.
    ///   - navigationAction: The navigation action causing the new web view to be created.
    ///   - windowFeatures: Window features requested by the webpage.
    /// - Returns: Indicates whether a new web view should be created. Defaults to false.
    func webView(_ webView: DLWebView, shouldCreateNewWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> Bool
}

public extension DLWebViewDelegate {
    func webView(_ webView: DLWebView, didStartLoading url: URL?) {}
    func webView(_ webView: DLWebView, didFinishLoading url: URL?) {}
    func webView(_ webView: DLWebView, didFailToLoad url: URL?, error: Error?) {}
    func webView(_ webView: DLWebView, decidePolicyFor navigationAction: WKNavigationAction) -> WKNavigationActionPolicy { return .allow }
    func webView(_ webView: DLWebView, decidePolicyFor navigationResponse: WKNavigationResponse) -> WKNavigationResponsePolicy { return .allow }
    func webView(_ webView: DLWebView, shouldCreateNewWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> Bool { return false }
}
