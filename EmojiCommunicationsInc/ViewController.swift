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

class ViewController: UIViewController {

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var autocompletionTableView: UITableView!

    @IBOutlet var repositionEmojiConstraint: NSLayoutConstraint!

    var autocompletionItemsEmoji: Array<String> = []
    var autocompletionItemsName: Array<String> = []
    var isCategoryOpen = false
    var isFullScreen = false
    
    let defaultAutoCompletionHeight: CGFloat = 94
    let increasedAutoCompletionHeight: CGFloat = 250
    let emojiLabelHeight: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "CategoryButton", bundle:nil)
        self.categoriesCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "Yo")

        setupTable()
        setupLabel()
        resetState()
    }

}

// MARK: - UI Modification

extension ViewController {

    func setupTable() {
        autocompletionTableView.addObserver(self, forKeyPath: "hidden", options: [.New], context: nil)
    }

    func setupLabel() {
        emojiLabel.userInteractionEnabled = true
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongPressEmoji")
        longPressGestureRecognizer.delaysTouchesBegan = true
        emojiLabel.addGestureRecognizer(longPressGestureRecognizer)
    }

    func resetTextField(dismissKeyboard: Bool) {
        self.textInput.text = ""
        if dismissKeyboard {
            self.textInput.resignFirstResponder()
        }
    }

    func setCurrentEmoji(e: String) {
        self.emojiLabel.text = e
    }

    func resetState() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.autocompletionTableView.hidden = true
            self.isCategoryOpen = false
            self.categoriesCollectionView.hidden = false
            self.textInput.resignFirstResponder()
        }
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

}

// MARK: - Actions

extension ViewController {

    @IBAction func didDoubleTapEmoji(sender: AnyObject) {
        if (isFullScreen) {
            didTapEmoji(self) // reset
            return
        }
        // full screen mode
        self.autocompletionTableView.hidden = true
        resetTextField(true)

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

    @IBAction func didTapEmoji(sender: AnyObject) {
        if isFullScreen {
            self.categoriesCollectionView.hidden = false
            self.textInput.hidden = false

            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.categoriesCollectionView.alpha = 1.0
                self.textInput.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            isFullScreen = false
        }
        else {
            // dismiss keyboard and so on
            self.textInput.resignFirstResponder()
            self.resetTextField(true)
            self.autocompletionTableView.hidden = true
            resetState()
        }
    }

    @IBAction func valueDidChange(sender: AnyObject) {
        if (self.textInput.text! != "") {

            let input = self.textInput.text!.characters.last!
            if let _ = emojiToText(input)
            {
                setCurrentEmoji("\(input)")
                resetTextField(false)
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

    func didLongPressEmoji() {
        // Copy to clipboard
        UIPasteboard.generalPasteboard().string = self.emojiLabel.text!

        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Copied \(self.emojiLabel.text!) to clipboard")
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        }
    }

}

// MARK: - KVO 

extension ViewController {

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            print("\n\(self), \n\(object), \n\(self?.repositionEmojiConstraint)")
            if let weakSelf = self,
            object = object as? UITableView where object == weakSelf.autocompletionTableView,
            let constraint = weakSelf.repositionEmojiConstraint {
                constraint.active = object.hidden ? true : false
                weakSelf.view.layoutIfNeeded()
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.autocompletionItemsEmoji.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let str = "\(self.autocompletionItemsEmoji[indexPath.row]) \(self.autocompletionItemsName[indexPath.row].capitalizedString)"
        cell.textLabel?.text = str
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        setCurrentEmoji(self.autocompletionItemsEmoji[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        resetState()
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

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.getAll().count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Yo", forIndexPath: indexPath) as! CategoryButton
        cell.setText(Category.getAll()[indexPath.row].key)
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        let results = Category.getAll()[indexPath.row].value
        self.autocompletionItemsEmoji = []
        self.autocompletionItemsName = []

        for (emoji) in results.characters {
            self.autocompletionItemsEmoji.append("\(emoji)")
            let str = emojiToText(emoji)
            self.autocompletionItemsName.append(str!)
        }
        self.autocompletionTableView.reloadData()
        self.isCategoryOpen = true
        UIView.animateWithDuration(0.25) {
            self.autocompletionTableView.hidden = false
            self.categoriesCollectionView.hidden = true
        }
    }

}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {

    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        resetState()

        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetState()
        resetTextField(true)

        return true
    }

}
