//
//  ViewController.swift
//  EmojiCommunicationsInc
//
//  Created by Felix Krause on 05/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import UIKit
import EmojiKit

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
                let fetcher = EmojiFetcher()
                
                fetcher.query(searchString) { emojiResults in
                    for (emoji) in emojiResults {
                        NSLog("Joo: \(emoji)")
                        self.emojiLabel.text = emoji.character
                        break
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
}

