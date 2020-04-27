//
//  Bookmarks.swift
//  nextBookmark
//
//  Created by Kai on 16.12.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Foundation

struct Bookmark: Identifiable {
    let id: Int
    var title: String
    var url: String
    var tags: [String]
    var folder_ids: [Int]
    var description: String
}
