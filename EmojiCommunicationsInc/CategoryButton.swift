//
//  CategoryButton.swift
//  Themoji
//
//  Created by Felix Krause on 14/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import UIKit

class CategoryButton: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        self.layer.cornerRadius = 9.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1.0
    }
    
    func setText(str: String) {
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(10.0), range: NSRange(location: 0, length: attributedString.length))
        
        self.titleLabel.attributedText = attributedString
    }
}