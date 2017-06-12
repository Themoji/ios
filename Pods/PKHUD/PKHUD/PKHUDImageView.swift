//
//  PKHUDImageView.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/12/15.
//  Copyright (c) 2015 NSExceptional. All rights reserved.
//

import UIKit

/// PKHUDImageView provides a square view, which you can use to display a single image.
open class PKHUDImageView: PKHUDSquareBaseView {
    
    public init(image: UIImage?) {
        super.init()
        commonInit(image: image)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(image: nil)
    }
    
    func commonInit(image: UIImage?) {
        imageView.image = image
        addSubview(imageView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    open let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.85
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
}
