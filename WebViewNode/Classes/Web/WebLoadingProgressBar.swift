//
//  WebLoadingProgressBar.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/6/27.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import WebKit

/// The style of loading progress animation
///
/// - `default`: progress bar with default animation
/// - smooth: progress bar with smooth animation
public enum WebLoadingProgressAnimationStyle {
    case `default`
    case smooth
}

/// A custom style progress view for web loading.
open class WebLoadingProgressBar: UIProgressView {
    
    /// The style of web loading progress animation. Defaults to WebLoadingProgressAnimationStyle.default.
    public var progressAnimationStyle: WebLoadingProgressAnimationStyle {
        didSet {
            if oldValue == .smooth, progressAnimationStyle == .default {
                _cancelProgressTimer()
            }
        }
    }
    
    private weak var _webView: WKWebView?
    private var _progressContext = 0
    private var _estimatedProgress: Float = 1.0
    
//    private lazy var _progressQueue = DispatchQueue(label: "com.dklinzh.framework.WebViewNode.WebLoadingProgressQueue", target: DispatchQueue.main)
    private var _progressTimer: DispatchSourceTimer?
    
    /// A web loading progress view initialization.
    ///
    /// - Parameters:
    ///   - webView: A web view should be observed by the progress view.
    ///   - progressAnimationStyle: The style of web loading progress animation. Defaults to WebLoadingProgressAnimationStyle.default.
    public init(webView: WKWebView, progressAnimationStyle: WebLoadingProgressAnimationStyle = .default) {
        self.progressAnimationStyle = progressAnimationStyle
        super.init(frame: .zero)
        
        _webView = webView
        self.trackTintColor = UIColor(white: 1.0, alpha: 0.0)
        self.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        _cancelProgressTimer()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil {
            _removeProgressObserver()
        } else {
            _addProgressObserver()
        }
    }
    
    private func _addProgressObserver() {
        _webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [], context: &_progressContext)
    }
    
    private func _removeProgressObserver() {
        _webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) && context == &_progressContext {
            guard let _progress = _webView?.estimatedProgress, _progress > 0 else {
                self.alpha = 0.0
                self.setProgress(0.0, animated: false)
                return
            }
            
            self.alpha = 1.0
            let progress = Float(_progress)
            if progressAnimationStyle == .smooth {
                if _estimatedProgress >= progress {
                    self.setProgress(progress, animated: self.progress == 0)
                    _startSmoothProgressTimer()
                } else if progress > self.progress {
                    self.setProgress(progress, animated: true)
                }
                _estimatedProgress = progress
            } else {
                let animated: Bool = progress > self.progress
                self.setProgress(progress, animated: animated)
            }
            
            if progress >= 1.0 {
                _stopSmoothProgressTimer()
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.alpha = 0.0
                }, completion: { (finished: Bool) in
                    self.setProgress(0.0, animated: false)
                })
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func _startSmoothProgressTimer() {
        if progressAnimationStyle == .smooth {
            _cancelProgressTimer()
            
            let progressTimer = DispatchSource.makeTimerSource(queue: .main)
            let interval: Double = 0.02
            progressTimer.schedule(deadline: .now() + interval, repeating: interval)
            progressTimer.setEventHandler(handler: { [weak self] in
                guard let strongSelf = self else { return }
                
                let progress = strongSelf.progress + 0.002
                let maxProgress: Float = 0.95
                if progress >= maxProgress {
                    strongSelf._cancelProgressTimer()
                    strongSelf.setProgress(maxProgress, animated: false)
                } else {
                    strongSelf.setProgress(progress, animated: false)
                }
            })
            progressTimer.resume()
            _progressTimer = progressTimer
        }
    }
    
    private func _stopSmoothProgressTimer() {
        if progressAnimationStyle == .smooth {
            _cancelProgressTimer()
        }
    }
    
    private func _cancelProgressTimer() {
        if let progressTimer = _progressTimer {
            progressTimer.cancel()
            _progressTimer = nil
        }
    }
}
