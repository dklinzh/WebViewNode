//
//  CustomWebViewController.swift
//  WebViewNode_Example
//
//  Created by Daniel Lin on 2018/9/13.
//  Copyright © 2018 dklinzh. All rights reserved.
//

import WebViewNode

class CustomWebViewController: DLWebViewController {
    // MARK: Lifecycle

    deinit {
        print("\(#function): \(self)")
    }

    // MARK: Internal

    override func setupAppearance() {
        super.setupAppearance()

        self.pageTitleNavigationShown = true
        self.navigationItemCanClose = true
        self.navigationItemCanRefresh = true
        self.progressTintColor = .green

        self.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.load("https://github.com/")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func registerJSHandlers(bridge: DLWebViewJavaScriptBridge) {
        // Regisger JS handlers with bridge
    }
}

extension CustomWebViewController: DLWebViewDelegate {
    func webView(_ webView: DLWebView, didStartLoading url: URL?) {}

    func webView(_ webView: DLWebView, didCommitLoading url: URL?) {}

    func webView(_ webView: DLWebView, didFinishLoading url: URL?) {}

    func webView(_ webView: DLWebView, didFailLoading url: URL?, error: Error?) {}

    func webView(_ webView: DLWebView, didRedirectForLoading url: URL?) {}
}
