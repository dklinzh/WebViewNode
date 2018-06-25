//
//  DLWebViewDelegate.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/6/20.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

import WebKit

public protocol DLWebViewDelegate: class {
    func dl_webView(_ webView: DLWebView, didStartLoading url: URL?)
    func dl_webView(_ webView: DLWebView, didFinishLoading url: URL?)
    func dl_webView(_ webView: DLWebView, didFailToLoad url: URL?, error: Error?)
    func dl_webView(_ webView: DLWebView, decidePolicyFor navigationResponse: WKNavigationResponse) -> WKNavigationResponsePolicy
    func dl_webView(_ webView: DLWebView, decidePolicyFor navigationAction: WKNavigationAction) -> WKNavigationActionPolicy
}

public extension DLWebViewDelegate {
    func dl_webView(_ webView: DLWebView, didStartLoading url: URL?) {}
    func dl_webView(_ webView: DLWebView, didFinishLoading url: URL?) {}
    func dl_webView(_ webView: DLWebView, didFailToLoad url: URL?, error: Error?) {}
    func dl_webView(_ webView: DLWebView, decidePolicyFor navigationResponse: WKNavigationResponse) -> WKNavigationResponsePolicy { return .allow }
    func dl_webView(_ webView: DLWebView, decidePolicyFor navigationAction: WKNavigationAction) -> WKNavigationActionPolicy { return .allow }
}
