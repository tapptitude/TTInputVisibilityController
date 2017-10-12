//
//  TouchRecognizer.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/14.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

open class TouchRecognizer: UIGestureRecognizer {
    open var callback: () -> Void
    open var ignoreViews: [UIView]?
    open var canPreventOtherGestureRecognizers: Bool = true
    /// enable touches on view which is firstResponder
    open var ignoreFirstResponder: Bool = false
    
    public init(callback: @escaping () -> Void, ignoreViews views: [UIView]?) {
        self.callback = callback
        self.ignoreViews = views
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(TouchRecognizer.touchRecongized(_:)))
    }
    
    override init(target: Any?, action: Selector?) {
        self.callback = {}
        super.init(target: target, action: action)
    }
    
    @objc func touchRecongized(_ sender: UIGestureRecognizer) {
        callback()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        if ignoreFirstResponder && touch.view?.isFirstResponder == true {
            return
        }
        
        for view in (ignoreViews ?? []) {
            if view.bounds.contains(touch.location(in: view)) {
                self.state = .failed
                return
            }
        }
        
        self.state = .recognized
    }
    
    open override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return canPreventOtherGestureRecognizers
    }
}
