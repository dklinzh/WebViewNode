//
//  DLViewNode.swift
//  WebViewNode
//
//  Created by Linzh on 9/15/18.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import AsyncDisplayKit

open class DLViewNode<ViewType: UIView>: ASDisplayNode {
    // MARK: Open

    override open func didLoad() {
        super.didLoad()

        guard let viewAssociations = _viewAssociations else {
            return
        }

        for block in viewAssociations {
            block(nodeView)
        }
        _viewAssociations = nil
    }

    // MARK: Public

    public var nodeView: ViewType {
        return view as! ViewType
    }

    public func appendViewAssociation(_ block: @escaping (ViewType) -> Void) {
        if isNodeLoaded {
            block(nodeView)
        } else {
            if _viewAssociations == nil {
                _viewAssociations = [(ViewType) -> Void]()
            }
            _viewAssociations!.append(block)
        }
    }

    // MARK: Private

    private var _viewAssociations: [(ViewType) -> Void]?
}
