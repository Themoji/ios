//
//  HUD.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/13/14.
//  Copyright (c) 2014 NSExceptional. All rights reserved.
//

import UIKit

/// The PKHUD object controls showing and hiding of the HUD, as well as its contents and touch response behavior.
open class PKHUD: NSObject {
    
    fileprivate struct Constants {
        static let sharedHUD = PKHUD()
    }
    
    fileprivate let window = Window()
    
    open class var sharedHUD: PKHUD {
        return Constants.sharedHUD
    }
    
    public override init () {
        super.init()
        NotificationCenter.default.addObserver(self,
            selector: #selector(PKHUD.willEnterForeground),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil)
        userInteractionOnUnderlyingViewsEnabled = false
        window.frameView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    internal func willEnterForeground() {
        self.startAnimatingContentView()
    }
    
    open var dimsBackground = true
    open var userInteractionOnUnderlyingViewsEnabled: Bool {
        get {
            return !window.isUserInteractionEnabled
        }
        set {
            window.isUserInteractionEnabled = !newValue
        }
    }
    
    open var isVisible: Bool {
        return !window.isHidden
    }
    
    open var contentView: UIView {
        get {
            return window.frameView.content
        }
        set {
            window.frameView.content = newValue
            startAnimatingContentView()
        }
    }
    
    open func show() {
        window.showFrameView()
        if dimsBackground {
            window.showBackground(animated: true)
        }
        
        startAnimatingContentView()
    }
    
    open func hide(animated anim: Bool = true) {
        window.hideFrameView(animated: anim)
        if dimsBackground {
            window.hideBackground(animated: true)
        }
        
        stopAnimatingContentView()
    }
    
    fileprivate var hideTimer: Timer?
    open func hide(afterDelay delay: TimeInterval) {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(PKHUD.hideAnimated), userInfo: nil, repeats: false)
    }
    
    internal func startAnimatingContentView() {
        if isVisible && contentView.conforms(to: PKHUDAnimating.self) {
            let animatingContentView = contentView as! PKHUDAnimating
            animatingContentView.startAnimation()
        }
    }
    
    internal func stopAnimatingContentView() {
        if contentView.conforms(to: PKHUDAnimating.self) {
            let animatingContentView = contentView as! PKHUDAnimating
            animatingContentView.stopAnimation?()
        }
    }
    
    internal func hideAnimated() -> Void {
        hide(animated: true)
    }
}
