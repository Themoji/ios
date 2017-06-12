//
//  PKHUDProgressVIew.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/12/15.
//  Copyright (c) 2015 NSExceptional. All rights reserved.
//

import UIKit
import QuartzCore

/// PKHUDProgressView provides an indeterminate progress view.
open class PKHUDProgressView: PKHUDImageView, PKHUDAnimating {
    
    public init() {
        super.init(image: PKHUDAssets.progressImage)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func commonInit(image: UIImage?) {
        super.commonInit(image: image)
        
        let progressImage = PKHUDAssets.progressImage
        imageView.image = progressImage
        imageView.alpha = 0.9
    }
    
    let progressAnimation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.values = [
            NSNumber(value: 0.0 as Float),
            NSNumber(value: 1.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 2.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 3.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 4.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 5.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 6.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 7.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 8.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 9.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 10.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 11.0 * Float(M_PI) / 6.0 as Float),
            NSNumber(value: 2.0 * Float(M_PI) as Float)
        ]
        animation.keyTimes = [
            NSNumber(value: 0.0 as Float),
            NSNumber(value: 1.0 / 12.0 as Float),
            NSNumber(value: 2.0 / 12.0 as Float),
            NSNumber(value: 3.0 / 12.0 as Float),
            NSNumber(value: 4.0 / 12.0 as Float),
            NSNumber(value: 5.0 / 12.0 as Float),
            NSNumber(value: 0.5 as Float),
            NSNumber(value: 7.0 / 12.0 as Float),
            NSNumber(value: 8.0 / 12.0 as Float),
            NSNumber(value: 9.0 / 12.0 as Float),
            NSNumber(value: 10.0 / 12.0 as Float),
            NSNumber(value: 11.0 / 12.0 as Float),
            NSNumber(value: 1.0 as Float)
        ]
        animation.duration = 1.2
        animation.calculationMode = "discrete"
        animation.repeatCount = Float(INT_MAX)
        return animation
        }()
    
    func startAnimation() {
        imageView.layer.add(progressAnimation, forKey: "progressAnimation")
    }
    
    func stopAnimation() {
    }
}
