//
//  WebNavigationItemDelegate.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2019/5/14.
//  Copyright (c) 2019 Daniel Lin. All rights reserved.
//

public protocol WebNavigationItemDelegate {
    
    var navigationItemCanClose: Bool { get set }
    
    var navigationItemCloseImage: UIImage { get }
    
    var navigationItemCloseButton: UIBarButtonItem { get }
    
    func navigationItemCloseDidChange(canClose: Bool)
}

private var _navigationItemCanCloseKey: Int = 0
public extension WebNavigationItemDelegate {
    
    var navigationItemCloseImage: UIImage {
        return UIImage(named: "wvn_btn_web_close", in: Bundle(for: DLWebView.self), compatibleWith: nil)!
    }
    
    var navigationItemCloseButton: UIBarButtonItem {
        return UIBarButtonItem(image: self.navigationItemCloseImage, style: .plain, action: { (sender) in
            if let viewController = self as? UIViewController {
                viewController.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func navigationItemCloseDidChange(canClose: Bool) {
        if let viewController = self as? UIViewController {
            if canClose {
                if let navigationController = viewController.navigationController,
                    navigationController.viewControllers.count > 1 {
                    if let leftBarButtonItem = viewController.navigationItem.leftBarButtonItem {
                        viewController.navigationItem.leftBarButtonItems = [leftBarButtonItem, self.navigationItemCloseButton]
                    } else {
                        viewController.navigationItem.leftBarButtonItem = self.navigationItemCloseButton
                    }
                }
            } else {
                viewController.navigationItem.leftBarButtonItem = nil
            }
        }
    }
}
