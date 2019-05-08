//
//  DLWebViewDelegate.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/6/20.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import WebKit

/// A WKWebViewConfiguration object is a collection of properties with which to initialize a web view.
public typealias DLWebViewConfiguration = WKWebViewConfiguration

/// A WKWindowFeatures object specifies optional attributes for the containing window when a new web view is requested.
public typealias DLWindowFeatures = WKWindowFeatures

/// A WKNavigationAction object contains information about an action that may cause a navigation, used for making policy decisions.
public typealias DLNavigationAction = WKNavigationAction

/// The policy to pass back to the decision handler from the webView(_:decidePolicyFor:decisionHandler:) method.
public typealias DLNavigationActionPolicy = WKNavigationActionPolicy

/// A WKNavigationResponse object contains information about a navigation response, used for making policy decisions.
public typealias DLNavigationResponse = WKNavigationResponse

/// The policy to pass back to the decision handler from the webView(_:decidePolicyFor:decisionHandler:) method.
public typealias DLNavigationResponsePolicy = WKNavigationResponsePolicy

public protocol DLWebViewDelegate: class {
    
    /// Invoked when URL request of the main frame navigation starts loading.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - url: The active URL of web view
    func webView(_ webView: DLWebView, didStartLoading url: URL?)
    
    /// Invoked when content starts arriving for the main frame.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - url: The active URL of web view
    func webView(_ webView: DLWebView, didCommitLoading url: URL?)
    
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
    func webView(_ webView: DLWebView, didFailLoading url: URL?, error: Error?)
    
    /// Invoked when a server redirect is received for the main
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - url: The active URL of web view
    func webView(_ webView: DLWebView, didRedirectForLoading url: URL?)
    
    /// Decides whether to allow or cancel a navigation while starting to load.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - navigationAction: Descriptive information about the action triggering the navigation request.
    /// - Returns: The policy to pass back to the decision handler from the webView(_:decidePolicyFor:decisionHandler:) method. Defaults to .allow
    func webView(_ webView: DLWebView, decidePolicyFor navigationAction: DLNavigationAction) -> DLNavigationActionPolicy
    
    /// Decides whether to allow or cancel a navigation after its response is known.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - navigationResponse: Descriptive information about the navigation response.
    /// - Returns: The policy to pass back to the decision handler from the webView(_:decidePolicyFor:decisionHandler:) method. Defaults to .allow
    func webView(_ webView: DLWebView, decidePolicyFor navigationResponse: DLNavigationResponse) -> DLNavigationResponsePolicy
    
    /// Decides whether a new web view should be created as a subframe of the website.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - configuration: The configuration to use when creating the new web view.
    ///   - navigationAction: The navigation action causing the new web view to be created.
    ///   - windowFeatures: Window features requested by the webpage.
    /// - Returns: Indicates whether a new web view should be created. Defaults to false.
    func webView(_ webView: DLWebView, shouldCreateNewWebViewWith configuration: DLWebViewConfiguration, for navigationAction: DLNavigationAction, windowFeatures: DLWindowFeatures) -> Bool
    
    /// Notifies your app that the DOM window object's close() method completed successfully.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - webViewController: The view controller nearest to the web view in the view hierarchy.
    @available(iOS 9.0, *)
    func webViewDidClose(_ webView: DLWebView, webViewController: UIViewController)
    
    /// Displays a JavaScript alert panel.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - webViewController: The view controller nearest to the web view in the view hierarchy.
    ///   - message: The message to display.
    ///   - completionHandler: The completion handler to call after the alert panel has been dismissed.
    func webView(_ webView: DLWebView, webViewController: UIViewController, showAlertPanelWithMessage message: String, completionHandler: @escaping () -> Swift.Void)
    
    /// Displays a JavaScript confirm panel.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - webViewController: The view controller nearest to the web view in the view hierarchy.
    ///   - message: The message to display.
    ///   - completionHandler: The completion handler to call after the confirm panel has been dismissed. Pass true if the user chose OK, false if the user chose Cancel.
    func webView(_ webView: DLWebView, webViewController: UIViewController, showConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Swift.Void)
    
    /// Displays a JavaScript text input panel.
    ///
    /// - Parameters:
    ///   - webView: The web view invoking the delegate method.
    ///   - webViewController: The view controller nearest to the web view in the view hierarchy.
    ///   - prompt: The message to display.
    ///   - defaultText: The initial text to display in the text entry field.
    ///   - completionHandler: The completion handler to call after the text input panel has been dismissed. Pass the entered text if the user chose OK, otherwise nil.
    func webView(_ webView: DLWebView, webViewController: UIViewController, showTextInputPanelWithPrompt prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Swift.Void)
}

public extension DLWebViewDelegate {
    func webView(_ webView: DLWebView, didStartLoading url: URL?) {}
    
    func webView(_ webView: DLWebView, didCommitLoading url: URL?) {}
    
    func webView(_ webView: DLWebView, didFinishLoading url: URL?) {}
    
    func webView(_ webView: DLWebView, didFailLoading url: URL?, error: Error?) {}
    
    func webView(_ webView: DLWebView, didRedirectForLoading url: URL?) {}
    
    func webView(_ webView: DLWebView, decidePolicyFor navigationAction: DLNavigationAction) -> DLNavigationActionPolicy { return .allow }
    
    func webView(_ webView: DLWebView, decidePolicyFor navigationResponse: DLNavigationResponse) -> DLNavigationResponsePolicy { return .allow }
    
    func webView(_ webView: DLWebView, shouldCreateNewWebViewWith configuration: DLWebViewConfiguration, for navigationAction: DLNavigationAction, windowFeatures: DLWindowFeatures) -> Bool { return false }
    
    func webViewDidClose(_ webView: DLWebView, webViewController: UIViewController) {
        if let navigationController = webViewController.navigationController {
            navigationController.popViewController(animated: true)
        } else if let presentingViewController = webViewController.presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // TODO: Strings Localization
    func webView(_ webView: DLWebView, webViewController: UIViewController, showAlertPanelWithMessage message: String, completionHandler: @escaping () -> Swift.Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            completionHandler()
        }
        alertController.addAction(action)
        webViewController.present(alertController, animated: true, completion: nil)
    }
    
    // TODO: Strings Localization
    func webView(_ webView: DLWebView, webViewController: UIViewController, showConfirmPanelWithMessage message: String, completionHandler: @escaping (Bool) -> Swift.Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            completionHandler(true)
        }
        alertController.addAction(yesAction)
        let noAction = UIAlertAction(title: "NO", style: .cancel) { (action) in
            completionHandler(false)
        }
        alertController.addAction(noAction)
        webViewController.present(alertController, animated: true, completion: nil)
    }
    
    // TODO: Strings Localization
    func webView(_ webView: DLWebView, webViewController: UIViewController, showTextInputPanelWithPrompt prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Swift.Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = defaultText
        }
        let action = UIAlertAction(title: "Commit", style: .default) { (action) in
            completionHandler(alertController.textFields?.first?.text)
        }
        alertController.addAction(action)
        webViewController.present(alertController, animated: true, completion: nil)
    }
}
