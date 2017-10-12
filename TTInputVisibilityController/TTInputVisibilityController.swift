//
//  KeyboardVisibilityController.swift
//  tapptitude-swift
//
//  Created by Alexandru Tudose on 20/04/16.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

public class TTInputVisibilityController: NSObject {
    
    /// this view will be translated up, will make firstResponder visible
    open weak var view: UIView?
    ///when keyboard is visible move this view up, toBeVisibleView == nil --> == firstResponderView
    open weak var toBeVisibleView: UIView?
    
    open var dismissKeyboardTouchRecognizer: TouchRecognizer? { //nil by default
        willSet {
            if let touchRecognizer = self.dismissKeyboardTouchRecognizer {
                touchRecognizer.view?.removeGestureRecognizer(touchRecognizer)
            }
        }
    }
    
    /// you can add extra space between keyboard and toBeVisibleView
    open var extraSpaceAboveKeyboard: CGFloat = 0
    /// instead of firstResponder view
    open var makeFirstRespondeSuperviewVisible: Bool = false
    
    ///view properties to be animated, 0 when returning to original value
    open var additionallAnimatioBlock: ((_ moveUpValue: CGFloat) -> Void)?
    open var disableKeyboardMoveUpAnimation: Bool = false
    open var isKeyboardVisible: Bool = false
    open var applyTransformToVisibleView: Bool = true
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillDisappear),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResign),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    convenience public init(viewToMove moveView: UIView) {
        self.init()
        self.view = moveView
    }
    
    deinit {
        if let touchRecognizer = self.dismissKeyboardTouchRecognizer {
            touchRecognizer.view?.removeGestureRecognizer(touchRecognizer)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - keyboard events
    fileprivate var scrollViewPreviousBottomInset: CGFloat = 0
    @objc func keyboardWillAppear(notification: Notification) {
        self.isKeyboardVisible = true
        self.dismissKeyboardTouchRecognizer?.isEnabled = true
    }
    
    @objc func keyboardWillDisappear(notification: Notification) {
        self.isKeyboardVisible = false
        self.dismissKeyboardTouchRecognizer?.isEnabled = false
    }
    
    @objc func applicationWillResign(notification: Notification) {
        self.view?.endEditing(true)
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        let keyboardEndFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let goingUp = (keyboardEndFrame?.origin.y ?? 0) < UIScreen.main.bounds.height
        self.moveViewUp(up: goingUp, usingKeyboardNotification: notification)
    }
    
    func moveViewUp(up: Bool, usingKeyboardNotification notification: Notification) {
        guard let toMoveView = self.view, let window = toMoveView.window else {
            return //ingore
        }
        
        let userInfo = notification.userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        var toBeVisibleView = self.toBeVisibleView
        
        if toBeVisibleView == nil {
            toBeVisibleView = toMoveView.findFirstResponder()
            if self.makeFirstRespondeSuperviewVisible {
                toBeVisibleView = toBeVisibleView?.superview
            }
        }
        
        // the old way of animation will match the keyboard animation timing and curve
        if !self.disableKeyboardMoveUpAnimation {
            UIView.beginAnimations(nil, context: nil)
            if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                UIView.setAnimationDuration(duration)
            }
            if let animationValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int {
                if let animationCurve = UIViewAnimationCurve(rawValue: animationValue) {
                    UIView.setAnimationCurve(animationCurve)
                }
            }
            UIView.setAnimationBeginsFromCurrentState(true)
        }
        
        var moveUpValue: CGFloat = 0
        if let visibleView = toBeVisibleView, let keyboardEndFrame = keyboardEndFrame, visibleView.window == window {
            let frame = visibleView.superview!.convert(visibleView.frame, to: visibleView.window)
            var deltaY = frame.maxY - (keyboardEndFrame.origin.y - extraSpaceAboveKeyboard) + (-toMoveView.transform.ty)
            deltaY = min(deltaY,keyboardEndFrame.height)
            if applyTransformToVisibleView {
                let shouldMove = deltaY > 0
                print(deltaY)
                moveUpValue += shouldMove ? deltaY : moveUpValue
            } else {
                let key = "previousMoveUpValue"
                let previousMoveUpValue = (toMoveView.layer.value(forKey: key) as? CGFloat) ?? 0
                moveUpValue += deltaY + previousMoveUpValue
                toMoveView.layer.setValue(up ? moveUpValue : 0, forKey: key)
            }
        }
        
        if let scrollView = toMoveView as? UIScrollView {
            // calculate scrollview bottom inset
            let scrollWindowframe = scrollView.superview!.convert(scrollView.frame, to: window)
            let intersectKeyboardHeight = scrollWindowframe.intersection(keyboardEndFrame!).height
            let bottomInsetMoveUpValue = intersectKeyboardHeight - scrollViewPreviousBottomInset
            let insetBottom = scrollView.__contentInset.bottom + bottomInsetMoveUpValue
            scrollViewPreviousBottomInset = intersectKeyboardHeight
            
            
            scrollView.__contentInset.bottom = insetBottom
            scrollView.__scrollIndicatorInsets.bottom = insetBottom
            
            let isInputAccessoryView = toBeVisibleView?.window == nil || toBeVisibleView?.window != scrollView.window
            let reverse: CGFloat = scrollView.__isReversed ? -1.0 : 1.0
            
            // move up content offset - so they can be in sync
            if moveUpValue > 0 {
                scrollView.contentOffset.y += (reverse * moveUpValue)
            } else if bottomInsetMoveUpValue > 0, isInputAccessoryView {
                let availableYSpace = (scrollView.contentSize.height + scrollViewPreviousBottomInset) - scrollView.bounds.height
                moveUpValue = min(bottomInsetMoveUpValue, max(0, availableYSpace))
                moveUpValue += extraSpaceAboveKeyboard
                scrollView.contentOffset.y += (reverse * moveUpValue)
            }
        } else {
            if applyTransformToVisibleView {
                toMoveView.transform = up ? CGAffineTransform(translationX: 0, y: -moveUpValue) : CGAffineTransform.identity
            }
        }
        
        additionallAnimatioBlock?(up ? moveUpValue : 0)
        
        if !self.disableKeyboardMoveUpAnimation {
            UIView.commitAnimations()
        }
    }
    
    @objc func dismissFirstResponder(sender: AnyObject) {
        self.view?.findFirstResponder()?.resignFirstResponder()
    }
}

import ObjectiveC
public extension UIView {
    
    private struct KeyboardAssociatedKey {
        static var viewExtension = "viewExtensionKeyboardVisibilityController"
    }
    
    public var keyboardVisibilityController: TTInputVisibilityController? {
        get {
            return objc_getAssociatedObject(self, &KeyboardAssociatedKey.viewExtension) as? TTInputVisibilityController ?? nil
        }
        set {
            objc_setAssociatedObject(self, &KeyboardAssociatedKey.viewExtension, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @discardableResult
    public func addInputVisibilityController() -> TTInputVisibilityController {
        var keyboardController = self.keyboardVisibilityController
        
        if keyboardController == nil {
            keyboardController = TTInputVisibilityController(viewToMove: self)
            keyboardController?.dismissKeyboardTouchRecognizer = TouchRecognizer(target: keyboardController, action: #selector(TTInputVisibilityController.dismissFirstResponder))
            keyboardController?.dismissKeyboardTouchRecognizer?.ignoreFirstResponder = true
            keyboardController?.dismissKeyboardTouchRecognizer?.isEnabled = false
            
            if let touchKeyboard = keyboardController?.dismissKeyboardTouchRecognizer {
                self.addGestureRecognizer(touchKeyboard)
            }
            
            self.keyboardVisibilityController = keyboardController
        }
        
        return keyboardVisibilityController!
    }
    
    public func removeKeyboardVisibilityController() {
        keyboardVisibilityController = nil
    }
}

public extension UIView {
    
    public func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        
        for subView in subviews {
            if subView.isFirstResponder {
                return subView
            }
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}

fileprivate extension UIScrollView {
    var __isReversed: Bool {
        return self.transform == CGAffineTransform(rotationAngle: .pi)
    }
    
    func __contentInset(from inset: UIEdgeInsets) -> UIEdgeInsets {
        if __isReversed {
            var inset = inset
            let topInset = inset.top
            inset.top = inset.bottom
            inset.bottom = topInset
            return inset
        } else {
            return inset
        }
    }
    var __contentInset: UIEdgeInsets {
        get { return __contentInset(from: contentInset) }
        set { contentInset = __contentInset(from: newValue) }
    }
    
    var __scrollIndicatorInsets: UIEdgeInsets {
        get { return __contentInset(from: scrollIndicatorInsets) }
        set { scrollIndicatorInsets = __contentInset(from: newValue) }
    }
}
