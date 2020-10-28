//
//  nextBookmarkUITests.swift
//  nextBookmarkUITests
//
//  Created by Kai on 30.08.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import XCTest

class nextBookmarkUITests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSmokeOpenDummyBookmark() {
        let app = XCUIApplication()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Go to Settings..."]/*[[".cells[\"Go to Settings..., ...to..., safari, ...setup your credentials\"].staticTexts[\"Go to Settings...\"]",".staticTexts[\"Go to Settings...\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Bookmark"].staticTexts["Bookmark"].swipeDown()
    }
    
}
