//
//  DLWebNodeDelegate.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2019/5/7.
//  Copyright (c) 2019 Daniel Lin. All rights reserved.
//

import WebKit

/// A WKWebViewConfiguration object is a collection of properties with which to initialize a web node.
public typealias DLWebNodeConfiguration = WKWebViewConfiguration

public protocol DLWebNodeDelegate: DLWebViewDelegate {
    /// Invoked when URL request of the main frame navigation starts loading.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - url: The active URL of web node
    func webNode(_ webNode: DLWebNode, didStartLoading url: URL?)
    
    /// Invoked when content starts arriving for the main frame.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - url: The active URL of web node
    func webNode(_ webNode: DLWebNode, didCommitLoading url: URL?)
    
    /// Invoked when URL request of the main frame navigation completes.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - url: The active URL of web node
    func webNode(_ webNode: DLWebNode, didFinishLoading url: URL?)
    
    /// Invoked when an error occurs while loading data for the main frame.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - url: The active URL of web node
    ///   - error: The error that occurred.
    func webNode(_ webNode: DLWebNode, didFailLoading url: URL?, error: Error?)
    
    /// Invoked when a server redirect is received for the main
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - url: The active URL of web node
    func webNode(_ webNode: DLWebNode, didRedirectForLoading url: URL?)
    
    /// Decides whether to allow or cancel a navigation while starting to load.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - navigationAction: Descriptive information about the action triggering the navigation request.
    /// - Returns: The policy to pass back to the decision handler from the webNode(_:decidePolicyFor:decisionHandler:) method. Defaults to .allow
    func webNode(_ webNode: DLWebNode, decidePolicyFor navigationAction: DLNavigationAction) -> DLNavigationActionPolicy
    
    /// Decides whether to allow or cancel a navigation after its response is known.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - navigationResponse: Descriptive information about the navigation response.
    /// - Returns: The policy to pass back to the decision handler from the webNode(_:decidePolicyFor:decisionHandler:) method. Defaults to .allow
    func webNode(_ webNode: DLWebNode, decidePolicyFor navigationResponse: DLNavigationResponse) -> DLNavigationResponsePolicy
    
    /// Decides whether a new web node should be created as a subframe of the website.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - configuration: The configuration to use when creating the new web node.
    ///   - navigationAction: The navigation action causing the new web node to be created.
    ///   - windowFeatures: Window features requested by the webpage.
    /// - Returns: Indicates whether a new web node should be created. Defaults to false.
    func webNode(_ webNode: DLWebNode, shouldCreateNewWebNodeWith configuration: DLWebNodeConfiguration, for navigationAction: DLNavigationAction, windowFeatures: DLWindowFeatures) -> Bool
    
    /// Notifies your app that the DOM window object's close() method completed successfully.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - webNodeController: The view controller nearest to the web node in the view hierarchy.
    @available(iOS 9.0, *)
    func webNodeDidClose(_ webNode: DLWebNode, webNodeController: UIViewController)
    
    /// Displays a JavaScript alert panel.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - webNodeController: The view controller nearest to the web node in the view hierarchy.
    ///   - message: The message to display.
    ///   - completionHandler: The completion handler to call after the alert panel has been dismissed.
    func webNode(_ webNode: DLWebNode, webNodeController: UIViewController, showAlertPanelWithMessage message: String, completionHandler: @escaping () -> Swift.Void)
    
    /// Displays a JavaScript confirm panel.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - webNodeController: The view controller nearest to the web node in the view hierarchy.
    ///   - message: The message to display.
    ///   - completionHandler: The completion handler to call after the confirm panel has been dismissed. Pass true if the user chose OK, false if the user chose Cancel.
    func webNode(_ webNode: DLWebNode, webNodeController: UIViewController, showConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Swift.Void)
    
    /// Displays a JavaScript text input panel.
    ///
    /// - Parameters:
    ///   - webNode: The web node invoking the delegate method.
    ///   - webNodeController: The view controller nearest to the web node in the view hierarchy.
    ///   - prompt: The message to display.
    ///   - defaultText: The initial text to display in the text entry field.
    ///   - completionHandler: The completion handler to call after the text input panel has been dismissed. Pass the entered text if the user chose OK, otherwise nil.
    func webNode(_ webNode: DLWebNode, webNodeController: UIViewController, showTextInputPanelWithPrompt prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Swift.Void)
}

public extension DLWebNodeDelegate {
    func webNode(_ webNode: DLWebNode, didStartLoading url: URL?) {
        self.webView(webNode.nodeView, didStartLoading: url)
    }
    
    func webNode(_ webNode: DLWebNode, didCommitLoading url: URL?) {
        self.webView(webNode.nodeView, didCommitLoading: url)
    }
    
    func webNode(_ webNode: DLWebNode, didFinishLoading url: URL?) {
        self.webView(webNode.nodeView, didFinishLoading: url)
    }
    
    func webNode(_ webNode: DLWebNode, didFailLoading url: URL?, error: Error?) {
        self.webView(webNode.nodeView, didFailLoading: url, error: error)
    }
    
    func webNode(_ webNode: DLWebNode, didRedirectForLoading url: URL?) {
        self.webView(webNode.nodeView, didRedirectForLoading: url)
    }
    
    func webNode(_ webNode: DLWebNode, decidePolicyFor navigationAction: DLNavigationAction) -> DLNavigationActionPolicy {
        return self.webView(webNode.nodeView, decidePolicyFor: navigationAction)
    }
    
    func webNode(_ webNode: DLWebNode, decidePolicyFor navigationResponse: DLNavigationResponse) -> DLNavigationResponsePolicy {
        return self.webView(webNode.nodeView, decidePolicyFor: navigationResponse)
    }
    
    func webNode(_ webNode: DLWebNode, shouldCreateNewWebNodeWith configuration: DLWebNodeConfiguration, for navigationAction: DLNavigationAction, windowFeatures: DLWindowFeatures) -> Bool {
        return self.webView(webNode.nodeView, shouldCreateNewWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
    }
    
    func webNodeDidClose(_ webNode: DLWebNode, webNodeController: UIViewController) {
        self.webViewDidClose(webNode.nodeView, webViewController: webNodeController)
    }
    
    func webNode(_ webNode: DLWebNode, webNodeController: UIViewController, showAlertPanelWithMessage message: String, completionHandler: @escaping () -> Swift.Void) {
        self.webView(webNode.nodeView, webViewController: webNodeController, showAlertPanelWithMessage: message, completionHandler: completionHandler)
    }
    
    func webNode(_ webNode: DLWebNode, webNodeController: UIViewController, showConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Swift.Void) {
        self.webView(webNode.nodeView, webViewController: webNodeController, showConfirmPanelWithMessage: message, completionHandler: completionHandler)
    }
    
    func webNode(_ webNode: DLWebNode, webNodeController: UIViewController, showTextInputPanelWithPrompt prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Swift.Void) {
        self.webView(webNode.nodeView, webViewController: webNodeController, showTextInputPanelWithPrompt: prompt, defaultText: defaultText, completionHandler: completionHandler)
    }
}
