//
//  ViewController.swift
//  EmojiCommunicationsInc
//
//  Created by Felix Krause on 05/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import UIKit
import EmojiKit
import PKHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var autocompletionTableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    @IBOutlet weak var emojiHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var autocompletionItemsHeight: NSLayoutConstraint!
    var autocompletionItemsEmoji: Array<String> = []
    var autocompletionItemsName: Array<String> = []
    var isCategoryOpen = false
    var isFullScreen = false
    
    let defaultAutoCompletionHeight: CGFloat = 94
    let increasedAutoCompletionHeight: CGFloat = 250
    var emojiLabelHeight: CGFloat = 0.0 // this is NOT the font size
    
    let emojiHistoryKey = "emojiHistory"
    
    var emojiFetcher: EmojiFetcher = EmojiFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        let nibName = UINib(nibName: "CategoryButton", bundle:nil)
        self.categoriesCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "Yo")

        self.emojiLabel.font = FontRendering.highResolutionEmojiUIFontSize(384)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        emojiLabelHeight = self.view.bounds.height / 2.0
        self.emojiHeightConstraint.constant = emojiLabelHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.bottomConstraint.constant = contentInsets.bottom + 5.0
            self.categoriesCollectionView.hidden = true
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
    
    @IBAction func didDoubleTapEmoji(sender: AnyObject) {
        if (isFullScreen) {
            didTapEmoji(self) // reset
            return
        }
        // full screen mode
        self.autocompletionTableView.hidden = true
        self.autocompletionItemsHeight.constant = defaultAutoCompletionHeight
        resetTextField(true)
        self.historyButton.hidden = true
        self.searchButton.hidden = true // has to be after resetTextField
        
        self.emojiHeightConstraint.constant = self.view.bounds.height
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.categoriesCollectionView.alpha = 0.0
            self.textInput.alpha = 0.0
            self.view.layoutIfNeeded()
        })
        { (something) -> Void in
            self.categoriesCollectionView.hidden = true
            self.textInput.hidden = true
        }
        isFullScreen = true
    }
    @IBAction func didTapHistory(sender: AnyObject) {
        if let recent = NSUserDefaults.standardUserDefaults().arrayForKey(emojiHistoryKey) as? [String] {
            prefillAutoCompletion(recent.joinWithSeparator(""))
        }
        else {
            
        }
    }
    
    @IBAction func didTapSearch(sender: AnyObject) {
        self.textInput.hidden = false
        self.searchButton.hidden = true
        self.historyButton.hidden = true
        self.textInput.becomeFirstResponder()
    }

    @IBAction func didLongPressEmoji(sender: AnyObject) {
        // Copy to clipboard
        UIPasteboard.generalPasteboard().string = self.emojiLabel.text!
        
        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Copied to clipboard")
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        }
    }
    
    @IBAction func didTapEmoji(sender: AnyObject) {
        if isFullScreen {
            self.emojiHeightConstraint.constant = emojiLabelHeight
            self.categoriesCollectionView.hidden = false
            self.searchButton.hidden = false
            self.historyButton.hidden = false

            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.categoriesCollectionView.alpha = 1.0
                self.textInput.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            isFullScreen = false
        }
        else {
            // dismiss keyboard and so on
            self.resetTextField(true)
            self.autocompletionTableView.hidden = true
            resetState()
        }
    }

    @IBAction func valueDidChange(sender: AnyObject) {
        if (self.textInput.text! != "") {
            let input = self.textInput.text!.characters.last!
            if emojiToText(input) != nil
            {
                setCurrentEmoji("\(input)")
                resetTextField(false)
            }
            else
            {
                let searchString = self.textInput.text!.lowercaseString // all chars since the last match
                
                emojiFetcher.cancelFetches()
                emojiFetcher.query(searchString) { emojiResults in
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
    
    func resetTextField(dismissKeyboard: Bool) {
        self.textInput.text = ""
        if dismissKeyboard {
            dismissSearch()
        }
    }
    
    func prefillAutoCompletion(emojis: String) {
        self.autocompletionItemsEmoji = []
        self.autocompletionItemsName = []
        
        for (emoji) in emojis.characters {
            self.autocompletionItemsEmoji.append("\(emoji)")
            let str = emojiToText(emoji)
            self.autocompletionItemsName.append(str!)
        }
        self.autocompletionTableView.reloadData()
        self.autocompletionItemsHeight.constant = increasedAutoCompletionHeight
        self.isCategoryOpen = true
        self.searchButton.hidden = true
        self.historyButton.hidden = true
        UIView.animateWithDuration(0.25) {
            self.autocompletionTableView.hidden = false
            self.categoriesCollectionView.hidden = true
        }
    }
    
    func dismissSearch() {
        self.textInput.resignFirstResponder()
        self.searchButton.hidden = false
        self.historyButton.hidden = false
        self.textInput.hidden = true
    }
    
    func setCurrentEmoji(e: String) {
        self.textInput.hidden = true
        self.emojiLabel.text = e

        if var recent = NSUserDefaults.standardUserDefaults().objectForKey(emojiHistoryKey) {
            recent = recent.mutableCopy()
            recent.removeObject(e)
            recent.insertObject(e, atIndex: 0)
            NSUserDefaults.standardUserDefaults().setObject(recent, forKey: emojiHistoryKey)
        }
        else {
            NSUserDefaults.standardUserDefaults().setObject([e], forKey: emojiHistoryKey)
        }
    }
    
    func resetState() {
        self.autocompletionTableView.hidden = true
        self.autocompletionItemsHeight.constant = defaultAutoCompletionHeight
        self.isCategoryOpen = false
        self.categoriesCollectionView.hidden = false
        self.searchButton.hidden = false
        self.historyButton.hidden = false
    }
    
    func emojiToText(c: Character) -> String? {
        // From http://nshipster.com/cfstringtransform/

        let cfstr = NSMutableString(string: String(c)) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &range, kCFStringTransformToUnicodeName, Bool(0))
        let str = cfstr as String
        if (str.containsString("{") && str.containsString("}")) {
            return str.stringByReplacingOccurrencesOfString("\\N{", withString: "").stringByReplacingOccurrencesOfString("}", withString: "").capitalizedString
        }
        else {
            return nil // stupid text, no need for dat
        }
    }
    
    // UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.autocompletionItemsEmoji.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "Yoo")
//        let str = "\(self.autocompletionItemsEmoji[indexPath.row]) \(self.autocompletionItemsName[indexPath.row].capitalizedString)"
        cell.textLabel?.text = self.autocompletionItemsEmoji[indexPath.row]
        cell.textLabel?.font = FontRendering.highResolutionEmojiUIFontSize((cell.textLabel?.font.pointSize)!);
        cell.detailTextLabel?.text = self.autocompletionItemsName[indexPath.row].capitalizedString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        setCurrentEmoji(self.autocompletionItemsEmoji[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.isCategoryOpen {
            // We have to close this
            resetState()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let line = UIView()
        line.backgroundColor = UIColor.lightGrayColor()
        return line
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    // UICollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.getAll().count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Yo", forIndexPath: indexPath) as! CategoryButton
        cell.setText(Category.getAll()[indexPath.row].key)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        let results = Category.getAll()[indexPath.row].value
        prefillAutoCompletion(results)
    }

    
    // UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.dismissSearch()
        resetState()
        resetTextField(true)
        return true
    }
}

