//
//  Categories.swift
//  Themoji
//
//  Created by Felix Krause on 14/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

// One category
class Category {
    var key: String = ""
    var value: String = ""
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    class func getAll() -> Array<Category> {
        return [
            Category(key: "🍔🍕🍺🍟🌮🍫", value: "🍔🍕🌭🍟🌮🍫🍽🍺"),
            Category(key: "🚑🚂🎡🏥🏝✈️", value: "🚑🚂🎡🏥🏝✈️"),
            Category(key: "✂️✏️📩💵📷🔌", value: "✂️✏️📩💵📷🔌"),
            Category(key: "😈😈😈😈😈😈", value:😈😈😈😈😈😈😴😈")
        ]
    }
}
