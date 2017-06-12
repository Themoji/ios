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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let nibName = UINib(nibName: "CategoryButton", bundle:nil)
        self.categoriesCollectionView.register(nibName, forCellWithReuseIdentifier: "Yo")

        self.emojiLabel.font = FontRendering.highResolutionEmojiUIFontSize(384)
        if let lastEmoji = history().first {
            self.setEmoji(lastEmoji)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didTriggerEmoji(_:)), name: NSNotification.Name(rawValue: "ShowEmoji"), object: nil)
    }
    
    func didTriggerEmoji(_ noti: Notification) {
        let searchString = (noti.object as! String).lowercased()
        
        emojiFetcher.cancelFetches()
        emojiFetcher.query(searchString) { emojiResults in
            let emoji = emojiResults.last
            self.setEmoji((emoji?.character)!)
        }
    }

    func setEmoji(_ emoji: String) {
        self.emojiLabel.text = emoji
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emojiLabelHeight = self.view.bounds.height / 2.0
        self.emojiHeightConstraint.constant = emojiLabelHeight
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.bottomConstraint.constant = contentInsets.bottom + 5.0
            self.categoriesCollectionView.isHidden = true
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.bottomConstraint.constant = 5.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func didDoubleTapEmoji(_ sender: AnyObject) {
        if (isFullScreen) {
            didTapEmoji(self) // reset
            return
        }
        // full screen mode
        self.autocompletionTableView.isHidden = true
        self.autocompletionItemsHeight.constant = defaultAutoCompletionHeight
        resetTextField(true)
        self.historyButton.isHidden = true
        self.searchButton.isHidden = true // has to be after resetTextField
        
        self.emojiHeightConstraint.constant = self.view.bounds.height
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.categoriesCollectionView.alpha = 0.0
            self.textInput.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: { (something) -> Void in
            self.categoriesCollectionView.isHidden = true
            self.textInput.isHidden = true
        })
        
        isFullScreen = true
    }
    
    
    func history() -> [String] {
        if let recent = UserDefaults.standard.array(forKey: emojiHistoryKey) as? [String] {
            return recent
        }
        else {
            return []
        }
    }
    
    @IBAction func didTapHistory(_ sender: AnyObject) {
        prefillAutoCompletion(history().joined(separator: ""))
    }
    
    @IBAction func didTapSearch(_ sender: AnyObject) {
        self.textInput.isHidden = false
        self.searchButton.isHidden = true
        self.historyButton.isHidden = true
        self.textInput.becomeFirstResponder()
    }

    @IBAction func didLongPressEmoji(_ sender: AnyObject) {
        // Copy to clipboard
        UIPasteboard.general.string = self.emojiLabel.text!
        
        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Copied to clipboard")
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        }
    }
    
    @IBAction func didTapEmoji(_ sender: AnyObject) {
        if isFullScreen {
            self.emojiHeightConstraint.constant = emojiLabelHeight
            self.categoriesCollectionView.isHidden = false
            self.searchButton.isHidden = false
            self.historyButton.isHidden = false

            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.categoriesCollectionView.alpha = 1.0
                self.textInput.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            isFullScreen = false
        }
        else {
            // dismiss keyboard and so on
            self.resetTextField(true)
            self.autocompletionTableView.isHidden = true
            resetState()
        }
    }

    @IBAction func valueDidChange(_ sender: AnyObject) {
        if (self.textInput.text! != "") {
            let input = self.textInput.text!.characters.last!
            if emojiToText(input) != nil
            {
                setCurrentEmoji("\(input)")
                resetTextField(false)
            }
            else
            {
                let searchString = self.textInput.text!.lowercased() // all chars since the last match
                
                emojiFetcher.cancelFetches()
                emojiFetcher.query(searchString) { emojiResults in
                    self.autocompletionItemsName = []
                    self.autocompletionItemsEmoji = []
                    for (emoji) in emojiResults {
                        self.autocompletionItemsEmoji.append(emoji.character)
                        self.autocompletionItemsName.append(emoji.name)
                    }
                    self.autocompletionTableView.reloadData()
                    self.autocompletionTableView.isHidden = (emojiResults.count == 0)
                    self.autocompletionTableView.flashScrollIndicators()
                }
            }
        }
    }
    
    // Modifying the UI
    
    func resetTextField(_ dismissKeyboard: Bool) {
        self.textInput.text = ""
        if dismissKeyboard {
            dismissSearch()
        }
    }
    
    func prefillAutoCompletion(_ emojis: String) {
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
        self.searchButton.isHidden = true
        self.historyButton.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.autocompletionTableView.isHidden = false
            self.categoriesCollectionView.isHidden = true
        }) 
    }
    
    func dismissSearch() {
        self.textInput.resignFirstResponder()
        self.searchButton.isHidden = false
        self.historyButton.isHidden = false
        self.textInput.isHidden = true
    }
    
    func setCurrentEmoji(_ e: String) {
        self.textInput.isHidden = true
        self.emojiLabel.text = e

        if var recent = UserDefaults.standard.object(forKey: emojiHistoryKey) {
            recent = (recent as AnyObject).mutableCopy()
            (recent as AnyObject).remove(e)
            (recent as AnyObject).insert(e, at: 0)
            UserDefaults.standard.set(recent, forKey: emojiHistoryKey)
        }
        else {
            UserDefaults.standard.set([e], forKey: emojiHistoryKey)
        }
    }
    
    func resetState() {
        self.autocompletionTableView.isHidden = true
        self.autocompletionItemsHeight.constant = defaultAutoCompletionHeight
        self.isCategoryOpen = false
        self.categoriesCollectionView.isHidden = false
        self.searchButton.isHidden = false
        self.historyButton.isHidden = false
    }
    
    func emojiToText(_ c: Character) -> String? {
        // From http://nshipster.com/cfstringtransform/

        let cfstr = NSMutableString(string: String(c)) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &range, kCFStringTransformToUnicodeName, Bool(0))
        let str = cfstr as String
        if (str.contains("{") && str.contains("}")) {
            return str.replacingOccurrences(of: "\\N{", with: "").replacingOccurrences(of: "}", with: "").capitalized
        }
        else {
            return nil // stupid text, no need for dat
        }
    }
    
    // UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.autocompletionItemsEmoji.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Yoo")
//        let str = "\(self.autocompletionItemsEmoji[indexPath.row]) \(self.autocompletionItemsName[indexPath.row].capitalizedString)"
        cell.textLabel?.text = self.autocompletionItemsEmoji[indexPath.row]
        cell.textLabel?.font = FontRendering.highResolutionEmojiUIFontSize((cell.textLabel?.font.pointSize)!);
        cell.detailTextLabel?.text = self.autocompletionItemsName[indexPath.row].capitalized
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setCurrentEmoji(self.autocompletionItemsEmoji[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.isCategoryOpen {
            // We have to close this
            resetState()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        return line
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    // UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.getAll().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Yo", for: indexPath) as! CategoryButton
        cell.setText(Category.getAll()[indexPath.row].key)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let results = Category.getAll()[indexPath.row].value
        prefillAutoCompletion(results)
    }

    
    // UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissSearch()
        resetState()
        resetTextField(true)
        return true
    }
}

