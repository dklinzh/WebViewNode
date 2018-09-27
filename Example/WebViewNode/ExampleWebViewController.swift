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
        let webView = DLWebView(cookiesShared: true, userSelected: false, userScalable: .disable, contentFitStyle: .default)
        webView.progressBarShown = true
        webView.progressTintColor = .green
        webView.addCustomValidSchemes(["node"])
//        webView.scrollDecelerationRate = UIScrollViewDecelerationRateNormal
//        webView.allowsBackForwardNavigationGestures = true
        if #available(iOS 9.0, *) {
            webView.shouldPreviewElementBy3DTouch = true
        }
        webView.shouldDisplayAlertPanelByJavaScript = false
        if #available(iOS 9.0, *) {
            webView.shouldCloseByDOMWindow = true
        }
        
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _webView.bindJSBridge()
        
        self.view.addSubview(_webView)
        _webView.frame = self.view.bounds
        _webView.pageTitleDidChange { [weak self] (title) in
            guard let strongSelf = self else { return }
            
            strongSelf.title = title
        }
        _webView.webContentHeightDidChange({ (height) in
            print("Web content height: \(height)")
        }, sizeFlexible: false)
        _webView.delegate = self
        _webView.load("https://github.com/")
//        _webView.load("https://www.google.com/")
        
        //
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(moreAction))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("\(#function): \(self)")
    }

    @objc
    private func moreAction() {
//        _webView.scrollTo(offset: 1000)
        
//        _webView.getSelectedString { (string) in
//            print("selected: \(string)")
//        }
    }
}

extension ExampleWebViewController: DLWebViewDelegate {
    
}
