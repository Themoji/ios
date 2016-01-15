//
//  ViewController.swift
//  EmojiCommunicationsInc
//
//  Created by Felix Krause on 05/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import UIKit
import EmojiKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var autocompletionTableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var autocompletionItemsEmoji: Array<String> = []
    var autocompletionItemsName: Array<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.bottomConstraint.constant = contentInsets.bottom + 5.0
            UIView.animateWithDuration(0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 5.0
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func didTapEmoji(sender: AnyObject) {
        self.textInput.resignFirstResponder()
        self.resetTextField()
        self.autocompletionTableView.hidden = true
    }

    @IBAction func valueDidChange(sender: AnyObject) {
        if (self.textInput.text! != "") {
            let input = self.textInput.text!.characters.last!
            if emojiToText(input) != nil
            {
                setCurrentEmoji("\(input)")
                resetTextField()
            }
            else
            {
                let searchString = self.textInput.text!.lowercaseString // all chars since the last match
                let fetcher = EmojiFetcher()
                
                fetcher.query(searchString) { emojiResults in
                    self.autocompletionItemsName = []
                    self.autocompletionItemsEmoji = []
                    for (emoji) in emojiResults {
                        self.autocompletionItemsEmoji.append(emoji.character)
                        self.autocompletionItemsName.append(emoji.name)
                    }
                    self.autocompletionTableView.reloadData()
                    self.autocompletionTableView.hidden = (emojiResults.count == 0)
                    self.autocompletionTableView.flashScrollIndicators()
                }
            }
        }
    }
    
    // Modifying the UI
    
    func resetTextField() {
        self.textInput.text = ""
    }
    
    func setCurrentEmoji(e: String) {
        self.emojiLabel.text = e
    }
    
    func emojiToText(c: Character) -> String? {
        // From http://nshipster.com/cfstringtransform/

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
    
    // Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.autocompletionItemsEmoji.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let str = "\(self.autocompletionItemsEmoji[indexPath.row]) \(self.autocompletionItemsName[indexPath.row])"
        cell.textLabel?.text = str
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        setCurrentEmoji(self.autocompletionItemsEmoji[indexPath.row])
        self.autocompletionTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let line = UIView()
        line.backgroundColor = UIColor.lightGrayColor()
        return line
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
}

