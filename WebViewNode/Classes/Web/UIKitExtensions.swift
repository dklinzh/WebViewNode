//
//  UIKitExtensions.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/9/4.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import UIKit

extension UIView {
    
    public var dl_closestViewController: UIViewController? {
        for responder in self.dl_responderChainEnumerator {
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        
        return nil
    }
    
}

extension UIResponder {
    
    public var dl_responderChainEnumerator: NSEnumerator {
        return DLResponderChainEnumerator(responder: self)
    }
}

class DLResponderChainEnumerator: NSEnumerator {
    
    private var _currentResponder: UIResponder?
    
    init(responder: UIResponder) {
        super.init()
        
        _currentResponder = responder
    }
    
    override func nextObject() -> Any? {
        let next = _currentResponder?.next
        _currentResponder = next
        return next
    }
}

public protocol DLNavigationControllerDelegate {
    
    func navigationConroller(_ navigationConroller: UINavigationController, shouldPop item: UINavigationItem) -> Bool
}

extension UINavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let items = navigationBar.items,
            self.viewControllers.count < items.count {
            return true
        }
        
        var shouldPop = true
        if let delegate = self.topViewController as? DLNavigationControllerDelegate {
            shouldPop = delegate.navigationConroller(self, shouldPop: item)
        }
        if shouldPop {
            DispatchQueue.main.async {
                self.popViewController(animated: true)
            }
        } else {
            // FIXME: The subviews of navigation bar would be translucent in some cases.
            for view in navigationBar.subviews {
                if view.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25) {
                        view.alpha = 1.0
                    }
                }
            }
        }
        
        return false
    }
}
