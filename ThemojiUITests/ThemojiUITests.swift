//
//  ThemojiUITests.swift
//  ThemojiUITests
//
//  Created by Felix Krause on 17/01/16.
//  Copyright © 2016 Felix Krause. All rights reserved.
//

import XCTest

class ThemojiUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func itHasToRainInTheUK() {
        XCTAssert(1 == 2)
    }
    
    func testExample() {
        let app = XCUIApplication()
        snapshot("01Landing")

        app.collectionViews.staticTexts.elementBoundByIndex(0).tap()
        snapshot("02Category")
        app.tables.staticTexts.elementBoundByIndex(0).tap()
        
        
        app.buttons["Search"].tap()
        app.textFields["Search Emoji"].typeText("air")
        snapshot("03Search")
    }
}
