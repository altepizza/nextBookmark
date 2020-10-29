//
//  nextBookmarkTests.swift
//  nextBookmarkTests
//
//  Created by Kai on 30.08.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Alamofire
import XCTest
@testable import nextBookmark

class nextBookmarkTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFilterBookmarksWithMultipleFolders() {
        var testableModel = Model()
        testableModel.bookmarks = [
            Bookmark(id: 1, url: "a", title: "",description: "", lastmodified: -1, added: -1, tags: [], folders: [2, -1]),
            Bookmark(id: 2, url: "b", title: "",description: "", lastmodified: -1, added: -1, tags: [], folders: [-1])
        ]
        let testFolder =  Folder(id: 2, title: "asdf", parent_folder_id: -1, full_path: "/adsf")
        
        let bookmarks = testableModel.sorted_filtered_bookmarks_of_folder(searchText: "", folder: testFolder)
        
        XCTAssert(bookmarks.count == 1)
        XCTAssert(bookmarks[0].url == "a")
    }
}
