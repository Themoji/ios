//
//  ViewController.swift
//  EmojiCommunicationsInc
//
//  Created by Felix Krause on 05/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var textInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        self.textInput.becomeFirstResponder()
    }

    @IBAction func valueDidChange(sender: AnyObject) {
        if (self.textInput.text! != "") {
            let input = self.textInput.text!.characters.last!
            if emojiToText(input) != nil
            {
                self.emojiLabel.text = "\(input)"
                resetTextField()
            }
            else
            {
                let searchString = self.textInput.text!.lowercaseString // all chars since the last match
                let dic = allEmojis()
                for (emoji, text) in dic {
                    if (text.lowercaseString.containsString(searchString)) {
                        self.emojiLabel.text = "\(emoji)"
                        //                    resetTextField()
                    }
                }
            }
        }
    }
    
    func resetTextField() {
        self.textInput.text = ""
    }
    
    func emojiToText(c: Character) -> String? {
//        From http://nshipster.com/cfstringtransform/

        let cfstr = NSMutableString(string: String(c)) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &range, kCFStringTransformToUnicodeName, Bool(0))
        let str = cfstr as String
        if (str.containsString("{") && str.containsString("}")) {
            return str // Actual emoji
        }
        else {
            return nil // stupid text, no need for dat
        }
    }
    
    func allEmojis() -> NSDictionary {
        let result = NSMutableDictionary()
        
        let emojiRanges = [
            0x1F601...0x1F64F,
            0x2702...0x27B0,
            0x1F680...0x1F6C0,
            0x1F170...0x1F251
        ]
        
        for range in emojiRanges {
            for i in range {
                let c = String(UnicodeScalar(i))
                let str = emojiToText(c.characters.last!)
                if (str != nil) {
                    result[c] = str
                }
            }
        }
        print("Found \(result.count) emojis")
        return result
    }
}

