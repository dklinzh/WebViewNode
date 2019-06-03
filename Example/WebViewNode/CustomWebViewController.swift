//
//  CustomWebViewController.swift
//  WebViewNode_Example
//
//  Created by Daniel Lin on 2018/9/13.
//  Copyright © 2018 dklinzh. All rights reserved.
//

import WebViewNode

class CustomWebViewController: DLWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pageTitleNavigationShown = true
        self.navigationItemCanClose = true
        self.progressTintColor = .green
        self.delegate = self
//        self.load("https://github.com/")
        self.load("https://www.baidu.com/")
        
        //
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("\(#function): \(self)")
    }

    @objc
    private func refreshAction() {
        self.reload()
    }
    
    override func registerJSHandlers(bridge: DLWebViewJavaScriptBridge) {
        // Regisger JS handlers with bridge
    }
}

extension CustomWebViewController: DLWebViewDelegate {
    
    func webView(_ webView: DLWebView, didStartLoading url: URL?) {
        
    }
    
    func webView(_ webView: DLWebView, didCommitLoading url: URL?) {
        
    }
    
    func webView(_ webView: DLWebView, didFinishLoading url: URL?) {
        
    }
    
    func webView(_ webView: DLWebView, didFailLoading url: URL?, error: Error?) {
        
    }
    
    func webView(_ webView: DLWebView, didRedirectForLoading url: URL?) {
        
    }
    
}
