//
//  ExampleWebViewController.swift
//  WebViewNode_Example
//
//  Created by Daniel Lin on 06/25/2018.
//  Copyright (c) 2018 dklinzh. All rights reserved.
//

import UIKit
import WebViewNode
import WebKit

class ExampleWebViewController: UIViewController {
    
    private let _webView: DLWebView = {
        let webView = DLWebView(cookiesShared: true, userScalable: .disable, contentFitStyle: .default)
        webView.isProgressShown = true
        webView.progressTintColor = .green
        webView.addCustomValidSchemes(["node"])
//        webView.scrollDecelerationRate = UIScrollViewDecelerationRateNormal
//        webView.allowsBackForwardNavigationGestures = true
        if #available(iOS 9.0, *) {
            webView.allowsLinkPreview = true
        }
        if #available(iOS 10.0, *) {
            webView.shouldPreviewElementBy3DTouch = true
        }
        webView.shouldDisplayJavaScriptPanel = false
        if #available(iOS 9.0, *) {
            webView.shouldCloseByDOMWindow = true
        }
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(_webView)
        _webView.frame = self.view.bounds
        _webView.pageTitleDidChange { [weak self] (title) in
            guard let strongSelf = self else { return }
            
            strongSelf.title = title
        }
        _webView.webDelegate = self
        _webView.load("https://github.com/")
        
        //
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(moreAction))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    private func moreAction() {
        
    }
}

extension ExampleWebViewController: DLWebViewDelegate {
    
}
