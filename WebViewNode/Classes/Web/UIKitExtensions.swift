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
