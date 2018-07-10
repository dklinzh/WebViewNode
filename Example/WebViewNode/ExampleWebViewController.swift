//
//  ExampleWebViewController.swift
//  WebViewNode_Example
//
//  Created by Daniel Lin on 06/25/2018.
//  Copyright (c) 2018 dklinzh. All rights reserved.
//

import UIKit
import WebViewNode

class ExampleWebViewController: UIViewController {
    
    private let _webView: DLWebView = {
        let webView = DLWebView(isCookiesShared: true, isUserScalable: false, contentFitStyle: .default)
        webView.isProgressShown = true
        webView.progressTintColor = .green
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
        _webView.load("https://github.com/")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

