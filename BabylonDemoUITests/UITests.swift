//
//  UITests.swift
//  BabylonDemoUITests
//
//  Created by Hesham Mohamed on 12/30/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import XCTest

class UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
        app = XCUIApplication()
    }

    func testNonEmptyPostsTableView() {
        let myTable = app.tables.matching(identifier: "PostsTableView")
        sleep(5)
        let cellCount = myTable.cells.count
        XCTAssert(cellCount > 0)
    }

    func testOpenPostDetails() {
        let myTable = app.tables.matching(identifier: "PostsTableView")
        sleep(5)
        let cell = myTable.cells.element(matching: .cell, identifier: "MyCell_4")
        cell.tap()
        XCTAssert(app.otherElements["PostDetailsViewController"].exists)
        XCTAssertFalse(app.staticTexts["AuthorName"].label.isEmpty)
        XCTAssertFalse(app.staticTexts["Description"].label.isEmpty)
        XCTAssertFalse(app.staticTexts["CommentsCount"].label.isEmpty)
    }

    func testBackToPostsViewController() {
        let myTable = app.tables.matching(identifier: "PostsTableView")
        sleep(5)
        let cell = myTable.cells.element(matching: .cell, identifier: "MyCell_4")
        cell.tap()
        app.navigationBars["BabylonDemo.PostDetailsView"].buttons["Posts"].tap()
        XCTAssert(app.tables["PostsTableView"].exists)
    }
}

